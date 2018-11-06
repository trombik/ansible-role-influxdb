# ansible-role-influxdb

Install and configure `influxdb`. SSL/TLS has not been supported.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `influxdb_user` | User name of the service | `{{ __influxdb_user }}` |
| `influxdb_group` | Group name of the service | `{{ __influxdb_group }}` |
| `influxdb_package` | Package name `influxdb` | `{{ __influxdb_package }}` |
| `influxdb_db_dir` | Path to database directory | `{{ __influxdb_db_dir }}` |
| `influxdb_service` | Service name of `influxdb` | `{{ __influxdb_service }}` |
| `influxdb_conf_dir` | Path to base directory of the configuration file | `{{ __influxdb_conf_dir }}` |
| `influxdb_conf_file_name` | File name of the configuration file | `{{ __influxdb_conf_file_name }}` |
| `influxdb_conf_file` | Path to the configuration file | `{{ influxdb_conf_dir }}/{{ influxdb_conf_file_name }}` |
| `influxdb_flags` | Flags to pass to `influxd` daemon | `""` |
| `influxdb_bind_address` | Address and port number the daemon listens on | `localhost:8088` |
| `influxdb_databases` | List of databases to create or remove (see below) | `[]` |

## `influxdb_databases`

This is a list of dict of databases to create or remove. The keys of the dict
are any keys supported by `influxdb_database` `ansible` module. An example:

```yaml
influxdb_databases:
  - database_name: mydatabase
    state: present
```

`database_name` and `state` are mandatory. Others are optional.

## Debian

| Variable | Default |
|----------|---------|
| `__influxdb_user` | `influxdb` |
| `__influxdb_group` | `influxdb` |
| `__influxdb_package` | `influxdb` |
| `__influxdb_db_dir` | `/var/lib/influxdb` |
| `__influxdb_conf_dir` | `/etc/influxdb` |
| `__influxdb_conf_file_name` | `influxdb.conf` |
| `__influxdb_service` | `influxdb` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__influxdb_user` | `influxd` |
| `__influxdb_group` | `influxd` |
| `__influxdb_package` | `influxdb` |
| `__influxdb_db_dir` | `/var/db/influxdb` |
| `__influxdb_conf_dir` | `/usr/local/etc` |
| `__influxdb_conf_file_name` | `influxd.conf` |
| `__influxdb_service` | `influxd` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__influxdb_user` | `_influx` |
| `__influxdb_group` | `_influx` |
| `__influxdb_package` | `influxdb` |
| `__influxdb_db_dir` | `/var/influxdb` |
| `__influxdb_conf_dir` | `/etc/influxdb` |
| `__influxdb_conf_file_name` | `influxdb.conf` |
| `__influxdb_service` | `influxdb` |

# Dependencies

None

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - trombik.apt_repo
    - ansible-role-influxdb
  vars:
    apt_repo_keys_to_add:
      - https://repos.influxdata.com/influxdb.key
    apt_repo_to_add: "deb https://repos.influxdata.com/{{ ansible_distribution | lower }} {{ ansible_distribution_release }} stable"
    apt_repo_enable_apt_transport_https: yes
    influxdb_bind_address: 127.0.0.1:8088
    influxdb_databases:
      - database_name: mydatabase
        state: present
    influxdb_config: |
      reporting-disabled = true
      bind-address = "{{ influxdb_bind_address }}"
      [meta]
        dir = "{{ influxdb_db_dir }}/meta"
      [data]
        dir = "{{ influxdb_db_dir }}/data"
        wal-dir = "{{ influxdb_db_dir }}/wal"
      [coordinator]
      [retention]
      [shard-precreation]
      [monitor]
      [http]
      [ifql]
      [logging]
      [subscriber]
      [[graphite]]
      [[collectd]]
      [[opentsdb]]
      [[udp]]
      [tls]
```

# License

```
Copyright (c) 2018 Tomoyuki Sakurai <y@trombik.org>

Permission to use, copy, modify, and distribute this software for any
purpose with or without fee is hereby granted, provided that the above
copyright notice and this permission notice appear in all copies.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
```

# Author Information

Tomoyuki Sakurai <y@trombik.org>

This README was created by [qansible](https://github.com/trombik/qansible)
