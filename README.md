# ansible-docker

[![version)](https://img.shields.io/docker/v/crashvb/ansible/latest)](https://hub.docker.com/repository/docker/crashvb/ansible)
[![image size](https://img.shields.io/docker/image-size/crashvb/ansible/latest)](https://hub.docker.com/repository/docker/crashvb/ansible)
[![linting](https://img.shields.io/badge/linting-hadolint-yellow)](https://github.com/hadolint/hadolint)
[![license](https://img.shields.io/github/license/crashvb/ansible-docker.svg)](https://github.com/crashvb/ansible-docker/blob/master/LICENSE.md)

## Overview

This docker image contains [ansible](https://ansible.com/).

## Entrypoint Scripts

### ansible

The embedded entrypoint script is located at `/etc/entrypoint.d/ansible` and performs the following actions:

1. A new ansible configuration is imported / generated.

## Helper Scripts

* <tt>ansible-bootstrap</tt> - Assists with bootstrapping targets.
* <tt>ansible-role</tt> - Assists with applying one-off roles to targets.
* <tt>ansible-ssh</tt> - Assists with troubleshooting SSH connectivity.

## Standard Configuration

### Container Layout

```
/
└─ etc/
│  └─ ansible/
└─ run/
   └─ secrets/
      ├─ id_rsa.ansible
      └─ id_rsa.ansible.pub
```

### Exposed Ports

None.

### Volumes

None.

## Development

[Source Control](https://github.com/crashvb/ansible-docker)

