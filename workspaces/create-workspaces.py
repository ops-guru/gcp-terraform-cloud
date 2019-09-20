#!/usr/bin/env python3
import hcl
import json
import os
import argparse
import requests
import yaml


def parse_args():
    parser = argparse.ArgumentParser(description='Create workspaces')
    parser.add_argument('--workspaces', default='workspaces.yaml', help='Yaml file with workspaces\' definitions')
    parser.add_argument('--org', required=True, default='gcp-landing-zone', help='Terraform cloud organization')
    parser.add_argument('--oauth_token_id', default=None, help='Terraform vcs oauth token id. Set this variable if'
                                                               'you are setting vcs_repo for your workspace in '
                                                               'workspaces.yaml')
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


def create_workspace(name, org, token, working_directory='', oauth_token_id=None, vcs_repo={}):
    url = 'https://app.terraform.io/api/v2/organizations/{}/workspaces'.format(org)
    if oauth_token_id and "identifier" in vcs_repo:
        vcs_repo["oauth-token-id"] = oauth_token_id
    if oauth_token_id in vcs_repo and not oauth_token_id:
        message = 'Workspace {} has vcs-repo.identifier defined but no oauth-token-id.'.format(name)
        raise Exception(message)
    body = {
        "data": {
            "attributes": {
                "name": name,
                "working-directory": working_directory,
                "queue-all-runs": True,
                "vcs-repo": vcs_repo
            },
            "type": "workspaces"
        }
    }

    session = requests.session()
    headers = {
        'Authorization': 'Bearer {}'.format(token),
        'Content-Type': 'application/vnd.api+json'
    }

    res = session.get(url + '/' + name, headers=headers)
    if res.status_code != 200:
        res = session.post(url, headers=headers, data=json.dumps(body))
    elif res.status_code == 200:
        res = session.patch(url + '/' + name, headers=headers, data=json.dumps(body))
    if res.status_code not in [200, 201]:
        raise Exception('Status code: {}. Exception: {}'.format(res.status_code, res.content))


def load_workspaces(workspaces):
    with open(workspaces, 'r') as workspaces:
        return yaml.load(workspaces)


if __name__ == '__main__':
    args = parse_args()
    token = get_token()
    workspaces = load_workspaces(args.workspaces)
    org = args.org
    oauth_token_id = args.oauth_token_id

    for workspace in workspaces:
        print('Creating/Modifying {}'.format(workspace['name']))
        working_directory = ''
        vcs_repo = {}
        if 'working_directory' in workspace:
            working_directory = workspace['working_directory']
        if 'vcs_repo' in workspace:
            vcs_repo = workspace['vcs_repo']
        create_workspace(workspace['name'], org, token, working_directory=working_directory,
                         oauth_token_id=oauth_token_id, vcs_repo=vcs_repo)
