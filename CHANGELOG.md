## Release 1.2.4

* ee2aa5c bugfix: update __influxdb_management_packages for Debian
* b9d14ac bugfix: support Devuan, drop influxdb_user_with_grants
* 62b27ef bugfix: workaround a bug in ansible influxdb module

## Release 1.2.3

* ef6e30c bugfix: update python on Ubuntu, support Ubuntu 20.04
* 2293495 bugfix: add Publish on Ansible Galaxy

## Release 1.2.2

* 02efcab bugfix: QA and update bump box versions

## Release 1.2.1

* 15de982 bugfix: QA
* 2175799 bugfix: update boxes

## Release 1.2.0

* 5dda33c bugfix: QA
* 22869dd feature: support influxdb_extra_packages
* 5e847db bugfix: add no_proxy
* 9478714 bugfix: use `is search()`, which works in newer ansible

## Release 1.1.2

* 7a24e44 bugfix: introduce influxdb_log_dir

## Release 1.1.1

* 36f3e9b bugfix: remove ansible warnings, drop Ubuntu 16.04 support
* ff56371 bugfix: s/python/python3/
* 7bb97ca QA

## Release 1.1.0

* 96f079d bugfix: install python-influxdb from pip only when the platform is older Ubuntu
* ca048f8 feature: support TLS
* 4f4fa52 feature: support grants
* 8354e0f documentation: update README
* d79451a feature: manage users
* 17dfd5d feature: support database creation and removal

## Release 1.0.0

* Initial release
