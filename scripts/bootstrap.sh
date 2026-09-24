#!/usr/bin/env bash
set -euo pipefail

command -v ansible-playbook >/dev/null || {
  echo "Ansible is not installed."
  exit 1
}

ansible-galaxy collection install -r requirements.yml

echo "Bootstrap complete."
echo "Edit inventory/production/hosts.yml and group_vars/all.yml first."
