#!/usr/bin/python

# (c) 2017, Vitaliy Zhhuta <zhhuta () gmail.com>
# insipred by Kamil Szczygiel <kamil.szczygiel () intel.com> influxdb_database module
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

# obtained from https://github.com/ansible/ansible/pull/46216

from __future__ import absolute_import, division, print_function

__metaclass__ = type

ANSIBLE_METADATA = {'metadata_version': '1.1',
                    'status': ['preview'],
                    'supported_by': 'community'}

DOCUMENTATION = '''
---
module: influxdb_user_with_grants
short_description: Manage InfluxDB users
description:
  - Manage InfluxDB users
version_added: 2.5
author: "Vitaliy Zhhuta (@zhhuta)"
requirements:
  - "python >= 2.6"
  - "influxdb >= 0.9"
options:
  user_name:
    description:
      - Name of the user.
    required: True
  user_password:
    description:
      - Password to be set for the user.
    required: false
  admin:
    description:
      - Whether the user should be in the admin role or not.
    default: no
    type: bool
  state:
    description:
      - State of the user.
    choices: [ present, absent ]
    default: present
  grants:
    description:
      - Privileges to grant to this user. Takes a list of dicts containing the
        "database" and "privilege" keys.
    default: []
    version_added: 2.8
extends_documentation_fragment: influxdb
'''

EXAMPLES = '''
- name: Create a user on localhost using default login credentials
  influxdb_user_with_grants:
    user_name: john
    user_password: s3cr3t

- name: Create a user on localhost using custom login credentials
  influxdb_user_with_grants:
    user_name: john
    user_password: s3cr3t
    login_username: "{{ influxdb_user_with_grantsname }}"
    login_password: "{{ influxdb_password }}"

- name: Create an admin user on a remote host using custom login credentials
  influxdb_user_with_grants:
    user_name: john
    user_password: s3cr3t
    admin: yes
    hostname: "{{ influxdb_hostname }}"
    login_username: "{{ influxdb_user_with_grantsname }}"
    login_password: "{{ influxdb_password }}"

- name: Create a user on localhost with privileges
  influxdb_user_with_grants:
    user_name: john
    user_password: s3cr3t
    login_username: "{{ influxdb_user_with_grantsname }}"
    login_password: "{{ influxdb_password }}"
    grants:
      - database: 'collectd'
        privilege: 'WRITE'
      - database: 'graphite'
        privilege: 'READ'

- name: Destroy a user using custom login credentials
  influxdb_user_with_grants:
    user_name: john
    login_username: "{{ influxdb_user_with_grantsname }}"
    login_password: "{{ influxdb_password }}"
    state: absent
'''

RETURN = '''
#only defaults
'''

import ansible.module_utils.urls
from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils._text import to_native
import ansible.module_utils.influxdb as influx


def find_user(module, client, user_name):
    name = None

    try:
        names = client.get_list_users()
        for u_name in names:
            if u_name['user'] == user_name:
                name = u_name
                break
    except ansible.module_utils.urls.ConnectionError as e:
        module.fail_json(msg=to_native(e))
    except influx.exceptions.InfluxDBClientError as e:
        if not (e.code == 401 and "create admin user first" in e.message):
            module.fail_json(msg=to_native(e))
    return name


def check_user_password(module, client, user_name, user_password):
    try:
        client.switch_user(user_name, user_password)
        client.get_list_users()
    except influx.exceptions.InfluxDBClientError as e:
        if e.code == 401:
            return False
    except ansible.module_utils.urls.ConnectionError as e:
        module.fail_json(msg=to_native(e))
    finally:
        # restore previous user
        client.switch_user(module.params['username'], module.params['password'])
    return True


def set_user_password(module, client, user_name, user_password):
    if not module.check_mode:
        try:
            client.set_user_password(user_name, user_password)
        except ansible.module_utils.urls.ConnectionError as e:
            module.fail_json(msg=to_native(e))


def create_user(module, client, user_name, user_password, admin):
    if not module.check_mode:
        try:
            client.create_user(user_name, user_password, admin)
        except ansible.module_utils.urls.ConnectionError as e:
            module.fail_json(msg=to_native(e))


def drop_user(module, client, user_name):
    if not module.check_mode:
        try:
            client.drop_user(user_name)
        except influx.exceptions.InfluxDBClientError as e:
            module.fail_json(msg=e.content)

    module.exit_json(changed=True)


def set_user_grants(module, client, user_name, grants):
    changed = False

    try:
        current_grants = client.get_list_privileges(user_name)

        # check if the current grants are included in the desired ones
        for current_grant in current_grants:
            if current_grant not in grants:
                if not module.check_mode:
                    client.revoke_privilege(current_grant['privilege'],
                                            current_grant['database'],
                                            user_name)
                changed = True

        # check if the desired grants are included in the current ones
        for grant in grants:
            if grant not in current_grants:
                if not module.check_mode:
                    client.grant_privilege(grant['privilege'],
                                           grant['database'],
                                           user_name)
                changed = True

    except influx.exceptions.InfluxDBClientError as e:
        module.fail_json(msg=e.content)

    return changed


def main():
    argument_spec = influx.InfluxDb.influxdb_argument_spec()
    argument_spec.update(
        state=dict(default='present', type='str', choices=['present', 'absent']),
        user_name=dict(required=True, type='str'),
        user_password=dict(required=False, type='str', no_log=True),
        admin=dict(default='False', type='bool'),
        grants=dict(default=[], type='list')
    )
    module = AnsibleModule(
        argument_spec=argument_spec,
        supports_check_mode=True
    )

    state = module.params['state']
    user_name = module.params['user_name']
    user_password = module.params['user_password']
    admin = module.params['admin']
    grants = module.params['grants']
    influxdb = influx.InfluxDb(module)
    client = influxdb.connect_to_influxdb()
    user = find_user(module, client, user_name)

    changed = False

    if state == 'present':
        if user:
            if not check_user_password(module, client, user_name, user_password):
                set_user_password(module, client, user_name, user_password)
                changed = True
        else:
            create_user(module, client, user_name, user_password, admin)
            changed = True

        if grants:
            changed = changed and set_user_grants(module, client, user_name, grants)

        module.exit_json(changed=changed)

    if state == 'absent':
        if user:
            drop_user(module, client, user_name)
        else:
            module.exit_json(changed=False)


if __name__ == '__main__':
    main()
