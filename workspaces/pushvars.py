#!/usr/bin/env python3
import hcl
import json
import os
import argparse
import requests
import yaml


def parse_args():
    parser = argparse.ArgumentParser(description='Add variables to workspace')
    parser.add_argument('varfiles', nargs='+', help='HCL files that hold variables')
    parser.add_argument('--org', default='gcp-landing-zone', required=True, help='terraform cloud secrets file')
    args = parser.parse_args()
    return args


def get_token():
    if os.environ.get('TF_TOKEN'):
        return os.environ.get('TF_TOKEN')
    if os.path.isfile(os.path.expanduser('~/.terraformrc')):
        with open(os.path.expanduser('~/.terraformrc'), 'r') as fp:
            obj = hcl.load(fp)
            try:
                return obj['credentials']["app.terraform.io"]["token"]
            except KeyError:
                pass
    else:
        error_message = 'You need to define terraform cloud API token either through TF_TOKEN variable or ~/.terraformrc. ' \
                        'See: https://www.terraform.io/docs/commands/cli-config.html#available-settings'
        raise Exception(error_message)


def load_variables_file(variables_file):
    with open(variables_file, 'r') as fp:
        obj = hcl.load(fp)
    return obj


def get_workspace_id(workspace, org, token):
    url = 'https://app.terraform.io/api/v2/organizations/{}/workspaces/{}'.format(org, workspace)
    session = requests.session()
    headers = {
        'Authorization': 'Bearer {}'.format(token),
        'Content-Type': 'application/vnd.api+json'
    }
    res = session.get(url, headers=headers)
    if res.status_code != 200:
        message = 'workspace {} does not exists'.format(workspace)
        raise Exception(message)
    response = json.loads(res.content)
    return response['data']['id']


def get_variables_for_workspace(org, workspace, token):
    url = 'https://app.terraform.io/api/v2/vars'
    headers = {
        'Authorization': 'Bearer {}'.format(token),
        'Content-Type': 'application/vnd.api+json'
    }
    params = {'filter[organization][name]': org, 'filter[workspace][name]': workspace}
    session = requests.Session()
    res_get_var = session.get(url, headers=headers, params=params)
    if res_get_var.status_code != 200:
        message = 'workspace={} in org={} doesn\'t exists. Error code={}. Error response={} '\
            .format(org, workspace, res_get_var.status_code, res_get_var.text)
        raise Exception(message)
    variables = {}
    for var in json.loads(res_get_var.content)['data']:
        variables[var['attributes']['key']] = var['id']
    return variables


def set_variable(key, value, current_variables, workspace_id, token, sensitive=False):
    url = 'https://app.terraform.io/api/v2/vars'
    if isinstance(value, str):
        hcl_type = False
    else:
        hcl_type = True
        # Converting to hcl
        value = json.dumps(value, indent=2).replace('": ', '" = ')
    if 'credentials' in key.lower() or 'password' in key.lower():
        sensitive=True
    if key == 'credentials':
        with open(value, 'r') as cred_file:
            value = cred_file.read()
    body = {
        "data": {
            "type": "vars",
            "attributes": {
                "key": key,
                "value": value,
                "category": "terraform",
                "hcl": hcl_type,
                "sensitive": sensitive
            },
            "relationships": {
                "workspace": {
                    "data": {
                        "id": workspace_id,
                        "type": "workspaces"
                    }
                }
            }
        }
    }
    headers = {
        'Authorization': 'Bearer {}'.format(token),
        'Content-Type': 'application/vnd.api+json'
    }

    session = requests.Session()
    if key in current_variables:
        res = session.patch(url + '/' + current_variables[key], headers=headers, data=json.dumps(body))
    else:
        res = session.post(url, headers=headers, data=json.dumps(body))
    if res.status_code not in [200, 201]:
        message = 'Status code: {}, {}'.format(res.status_code, res.text)
        raise Exception(message)


def get_workspace(variables):
    if 'workspace' in variables:
        return variables['workspace']
    raise Exception('You have to define workspace variable in your variables file')


if __name__ == '__main__':
    args = parse_args()
    token = get_token()
    org = args.org

    for variable_file in args.varfiles:
        variables = load_variables_file(variable_file)
        workspace = get_workspace(variables)
        workspace_id = get_workspace_id(workspace, org, token)
        current_variables = get_variables_for_workspace(org, workspace, token)
        for key, value in variables.items():
            if key == 'workspace':
                continue
            print('Setting {}'.format(key))
            set_variable(key, value, current_variables, workspace_id, token)
