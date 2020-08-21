# `trombik.influxdb`

Install and configure `influxdb`. Supports SSL/TLS.

## Notes

This role includes `influxdb_user_with_grants` `ansible` module, which is a
patched version of `influxdb_user`, found in `ansible` [PR 46216](https://github.com/ansible/ansible/pull/46216).
This module has an additional keyword `grants`. Until the PR is merged to
release version, and subsequently to available `ansible` packages, the module
will be used.

# Requirements

None

# Role Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `influxdb_user` | User name of the service | `{{ __influxdb_user }}` |
| `influxdb_group` | Group name of the service | `{{ __influxdb_group }}` |
| `influxdb_package` | Package name `influxdb` | `{{ __influxdb_package }}` |
| `influxdb_extra_packages` | A list of extra packages to install | `{{ __influxdb_extra_packages }}` |
| `influxdb_db_dir` | Path to database directory | `{{ __influxdb_db_dir }}` |
| `influxdb_log_dir` | Path to log directory | `"{{ __influxdb_log_dir }}"` |
| `influxdb_service` | Service name of `influxdb` | `{{ __influxdb_service }}` |
| `influxdb_conf_dir` | Path to base directory of the configuration file | `{{ __influxdb_conf_dir }}` |
| `influxdb_conf_file_name` | File name of the configuration file | `{{ __influxdb_conf_file_name }}` |
| `influxdb_conf_file` | Path to the configuration file | `{{ influxdb_conf_dir }}/{{ influxdb_conf_file_name }}` |
| `influxdb_flags` | Flags to pass to `influxd` daemon | `""` |
| `influxdb_bind_address` | Address and port number the daemon listens on | `localhost:8088` |
| `influxdb_databases` | List of databases to create or remove (see below) | `[]` |
| `influxdb_users` | List of users to create or remove (see below) | `[]` |
| `influxdb_admin_username` | User name of admin user, which is used to manage databases, and users. This user is created at initial installation | `""` |
| `influxdb_admin_password` | Password of admin user | `""` |
| `influxdb_include_x509_certificate` | If `true`, include [`trombik.x509_certificate`](https://github.com/trombik/ansible-role-x509_certificate) role during the play | `no` |
| `influxdb_tls` | If `true`, use TLS transport | `no` |
| `influxdb_tls_validate_certs` | If `true`, validate server's certificate during TLS handshake | `yes` |
| `influxdb_management_packages` | List of packages to install for database management by `ansible` | `{{ __influxdb_management_packages }}` |

## `influxdb_databases`

This is a list of dict of databases to create or remove. The keys of the dict
are any keys supported by
[`influxdb_database`](https://docs.ansible.com/ansible/latest/modules/influxdb_database_module.html)
`ansible` module. An example:

```yaml
influxdb_databases:
  - database_name: mydatabase
    state: present
```

`database_name` and `state` are mandatory. Others are optional.

## `influxdb_users`

This is a list of dict of users to create or remove. The keys of the dict are
any keys supported by
[`influxdb_user`](https://docs.ansible.com/ansible/latest/modules/influxdb_user_module.html)
`ansible` module.

Also, `influxdb_user_with_grants` supports `grants` keyword.

```yaml
influxdb_users:
  - user_name: foo
    user_password: PassWord
    grants:
      - database: mydatabase
        privilege: ALL
  - user_name: write
    user_password: write
    grants:
      - database: mydatabase
        privilege: WRITE
  - user_name: read
    user_password: read
    grants:
      - database: mydatabase
        privilege: READ
  - user_name: none
    user_password: none
  - user_name: bar
    state: absent
```

If a key is missing, the key will be omitted by `default(omit)` except the
following keys.

| Key | Default value |
|-----|---------------|
| `state` | `present` |
| `login_username` | `influxdb_admin_username` |
| `login_password` | `influxdb_admin_password` |
| `hostname` | `influxdb_bind_address.split(':')[0]` |
| `port` | `influxdb_bind_address.split(':')[1]` |

## `influxdb_include_x509_certificate`

When this variable is `true` value, the role includes
`trombik.x509_certificate` during a play. To make this work, the following
line must be in `requirements.yml`.

```yaml
- name: trombik.x509_certificate
```

## Debian

| Variable | Default |
|----------|---------|
| `__influxdb_user` | `influxdb` |
| `__influxdb_group` | `influxdb` |
| `__influxdb_package` | `influxdb` |
| `__influxdb_extra_packages` | `[]` |
| `__influxdb_db_dir` | `/var/lib/influxdb` |
| `__influxdb_log_dir` | `/var/log/influxdb` |
| `__influxdb_conf_dir` | `/etc/influxdb` |
| `__influxdb_conf_file_name` | `influxdb.conf` |
| `__influxdb_service` | `influxdb` |
| `__influxdb_management_packages` | `["python-influxdb", "python-requests"]` |

## FreeBSD

| Variable | Default |
|----------|---------|
| `__influxdb_user` | `influxd` |
| `__influxdb_group` | `influxd` |
| `__influxdb_package` | `influxdb` |
| `__influxdb_extra_packages` | `[]` |
| `__influxdb_db_dir` | `/var/db/influxdb` |
| `__influxdb_log_dir` | `/var/log/influxdb` |
| `__influxdb_conf_dir` | `/usr/local/etc` |
| `__influxdb_conf_file_name` | `influxd.conf` |
| `__influxdb_service` | `influxd` |
| `__influxdb_management_packages` | `["databases/py-influxdb", "www/py-requests"]` |

## OpenBSD

| Variable | Default |
|----------|---------|
| `__influxdb_user` | `_influx` |
| `__influxdb_group` | `_influx` |
| `__influxdb_package` | `influxdb` |
| `__influxdb_extra_packages` | `[]` |
| `__influxdb_db_dir` | `/var/influxdb` |
| `__influxdb_log_dir` | `/var/log/influxdb` |
| `__influxdb_conf_dir` | `/etc/influxdb` |
| `__influxdb_conf_file_name` | `influxdb.conf` |
| `__influxdb_service` | `influxdb` |
| `__influxdb_management_packages` | `["py3-influxdb", "py3-requests"]` |

# Dependencies

* `trombik.x509_certificate` if `influxdb_include_x509_certificate` is true

# Example Playbook

```yaml
- hosts: localhost
  roles:
    - trombik.apt_repo
    - ansible-role-influxdb
  vars:
    x509_certificate_debug_log: yes
    tls_cert_path: "{{ influxdb_conf_dir }}/tls/influxdb.pem"
    tls_key_path: "{{ influxdb_conf_dir }}/tls/influxdb.key"
    x509_certificate:
      - name: influxdb
        state: present
        secret:
          path: "{{ tls_key_path }}"
          group: "{{ influxdb_group }}"
          mode: "0640"
          key: |
            -----BEGIN PRIVATE KEY-----
            MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCkNNkBIJ+8atZ1
            nkSUetBCxz9o7nYmGFdw5y+jYMjkBuFnepDDAhiv9yyUSjtsyoVyEEjD9WG5Jm4S
            z78HjU2/n/9/2EBfbQWbrEr/KJ9YKtJLcZJRwlCBmps7dTqJPzJzn0ac3TawowyH
            vBAYTpV/XnS5nZwUwfU9ws2X4STmNxanDsbhT9uH+NBnlh07umkUbNgm8NVr9hn0
            I3BCX3241iCR9HpnotaqG/V7SubxuOzzPvTZbiFhAB5rOMR7tusgB6eZENudEvaV
            7mJAR2tHbGAKxwyf9x8WIvNWQ3qSIfdo6QQuMG2ySdSww2TZI9/k15PNS14ubDPO
            4fqeT3TzAgMBAAECggEAXS/Alus0u3DGFCmlMb4gwkTgr2PkmOnndaM9XbJnT0C4
            WkksLf7ak8HqAp2965di88BaCxsOQkyU2wgamOaP4Nej36GRppXwQNAeH3+mLhrf
            DQF+z/c+SM68mZmFhq3eq88P+6Vui/979Ou9Fo5COO4Zv9y53u3ThyEuG6shjaN8
            9phvJAf+f9xHWpERCHKp05gHdzO7Kf7rZxZ1aSs5re61KaF23f2NGJOKCQXa+EXf
            I9VTcqs/dakKWAcXsSgSlwnCX7CBtsGo6raPor9AB8A8XagdrG7ibEvFksujsfNG
            0BUq2si9ic2xqT24wFPVfmLSyJHUjxk/9w9ARB7zQQKBgQDPKmYadvJBd4xDjKqk
            SIJRlObTQSQHeDyLV0lG3edVZU4QkjWDzeYv9WEPw3OUmIIOFxY9CeZHKvdDLeZv
            wd8uAmi29+mguQWwsEituDwAwqkqnpPu1Db2GZ2trBl+r6d9EETNejVwsyJqQhVF
            kLOWXN+a1tjGRELS17uhO/1yrQKBgQDK6gl+kfa4yrEcv+E0mm2LenHYFF0PYrkG
            OpozFilk4/dGEjPPH0uwvaV1doi3L76ATPUueiIFfIPfeOSINeg7jW3d5bCqBK66
            RpD7/2EiVZ/iH3ZiNg0KILYMIYmyxi6JhW/9w/rSI11pSIYhf798j8kooEsTebuV
            myP8aP0aHwKBgHfas8/D2Ux++atrCp6ZRKwmVZULLukTaxPCoCZb46bIQW3c6REk
            YnSEpm8USR5DTZsRSFBwFcY+2WcIezVVGOXphuO0cnoGEYCzvJik6jIWbQC3Vibq
            qBGhqFP+KZHd1izI6MVoWtqlCNgo+12P5hasDMHsYuXyQCbzoR4bMvrRAoGAJwr1
            HLd1I4VMot2AtaBpJ4c91HfGmClEtKAd/2pqOJFsiL0D3vyEkdNLvNg74hN7sjAc
            lP7HAQs+TId0YYkN0DecRi/l2DDiddESIIq44+RZySaInskLpUE6BgeF+TIMzkUw
            kUFeR4SqepGLzXJJI+x+piSBjZPEtjqNqAmDeb0CgYBxGua7JnSfoiJQnIOnFaX3
            YHp9WFyyfTKA2xUfE7rvX4DvyGGlVTtJNtLqN4+pnU4OfnnuQWoWrYiGkavLNk0e
            qT8tqILjvkLDp+COUvBvOkLUWB4MCQ5zqzPS8i2rUVfkkf4Ggl8sng5Fh3zGiW/6
            6BlD9CUifPiM3aTyAcZLzA==
            -----END PRIVATE KEY-----
        public:
          path: "{{ tls_cert_path }}"
          group: "{{ influxdb_group }}"
          mode: "0640"
          key: |
            -----BEGIN CERTIFICATE-----
            MIIDhTCCAm2gAwIBAgIJAOaHu1Fdx8xyMA0GCSqGSIb3DQEBCwUAMFkxCzAJBgNV
            BAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
            aWRnaXRzIFB0eSBMdGQxEjAQBgNVBAMMCWxvY2FsaG9zdDAeFw0xODExMDcwODA4
            MTZaFw0yODExMDQwODA4MTZaMFkxCzAJBgNVBAYTAkFVMRMwEQYDVQQIDApTb21l
            LVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBXaWRnaXRzIFB0eSBMdGQxEjAQBgNV
            BAMMCWxvY2FsaG9zdDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKQ0
            2QEgn7xq1nWeRJR60ELHP2judiYYV3DnL6NgyOQG4Wd6kMMCGK/3LJRKO2zKhXIQ
            SMP1YbkmbhLPvweNTb+f/3/YQF9tBZusSv8on1gq0ktxklHCUIGamzt1Ook/MnOf
            RpzdNrCjDIe8EBhOlX9edLmdnBTB9T3CzZfhJOY3FqcOxuFP24f40GeWHTu6aRRs
            2Cbw1Wv2GfQjcEJffbjWIJH0emei1qob9XtK5vG47PM+9NluIWEAHms4xHu26yAH
            p5kQ250S9pXuYkBHa0dsYArHDJ/3HxYi81ZDepIh92jpBC4wbbJJ1LDDZNkj3+TX
            k81LXi5sM87h+p5PdPMCAwEAAaNQME4wHQYDVR0OBBYEFLlFbMoqiB87C++97460
            1wl2neRzMB8GA1UdIwQYMBaAFLlFbMoqiB87C++974601wl2neRzMAwGA1UdEwQF
            MAMBAf8wDQYJKoZIhvcNAQELBQADggEBAFAPS2iqL1NQvq0wCyb0A5zYw1+c4UbF
            yNAqMVQKzEFIfQ8rfGnFGTCnsV6a977a60O86dZn7PsoaAyXs9FQvn9od/WmUJn8
            eIuSNOT4v0FwGuZgnFkUggski1Wt789TywWbd9q8jaD1gsp333Lx8ItWTu8V8lMb
            DeTKP3ikJlN+Ap2oNqVGHi5uv83HIkVjO9XbF2NOCHXT4gV5IDzoM5069ovRT7O6
            eTIPW1GdjHpjAvQoKJ+vVLcum2HEwgr75SrFOprxNCaz0cfQEjTpKz3iuvkSkTHS
            mep8rM3Zp1alBNlqhPBVyuBO54fhgA6C7QcT8zuEjBJ8MjWyIR+D1+E=
            -----END CERTIFICATE-----
    apt_repo_keys_to_add:
      - https://repos.influxdata.com/influxdb.key
    apt_repo_to_add: "deb https://repos.influxdata.com/{{ ansible_distribution | lower }} {{ ansible_distribution_release }} stable"
    apt_repo_enable_apt_transport_https: yes
    influxdb_admin_username: admin
    influxdb_admin_password: PassWord
    influxdb_tls: yes
    influxdb_include_x509_certificate: yes
    # the cert is self-signed, do not validate
    influxdb_tls_validate_certs: no
    influxdb_bind_address: 127.0.0.1:8086
    influxdb_databases:
      - database_name: mydatabase
        state: present
    influxdb_users:
      - user_name: foo
        user_password: PassWord
        grants:
          - database: mydatabase
            privilege: ALL
      - user_name: write_only
        user_password: write_only
        grants:
          - database: mydatabase
            privilege: WRITE
      - user_name: read_only
        user_password: read_only
        grants:
          - database: mydatabase
            privilege: READ
      - user_name: none
        user_password: none
      - user_name: bar
        state: absent
    influxdb_config: |
      reporting-disabled = true
      # this one is bind address for backup process
      bind-address = "127.0.0.1:8088"
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
        auth-enabled = true
        bind-address = "{{ influxdb_bind_address }}"
        https-enabled = true
        https-certificate = "{{ tls_cert_path }}"
        https-private-key = "{{ tls_key_path }}"
        access-log-path = "{{ influxdb_log_dir }}/access.log"
      [ifql]
      [logging]
      [subscriber]
      [[graphite]]
      [[collectd]]
      [[opentsdb]]
      [[udp]]
      [tls]
      # https://docs.influxdata.com/influxdb/v1.7/administration/config/#recommended-server-configuration-for-modern-compatibility
      min-version = "tls1.2"
      max-version = "tls1.2"
      ciphers = [ "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305",
                  "TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305",
                  "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
                  "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256",
                  "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
                  "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384"
      ]
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
