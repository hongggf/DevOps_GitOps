# Project Two — Ansible + Kubespray + Kubernetes + ArgoCD + GitHub Actions

This project automates a lab Kubernetes platform with Ansible. Kubespray provisions the
Kubernetes cluster; Ansible installs Helm, Traefik, cert-manager, Headlamp and ArgoCD.
GitHub Actions builds the React image and updates a GitOps repository; ArgoCD deploys it.

## 1. Configure inventory

Edit `inventory/production/hosts.yml` and replace the example IPs.

Default topology:
- master01, master02, master03: control plane + etcd
- worker01, worker02: workers

Add worker03 if you have it.

Set `base_domain` in `inventory/production/group_vars/all.yml`.

## 2. Configure secrets

Copy:
```bash
cp inventory/production/group_vars/vault.yml.example inventory/production/group_vars/vault.yml
ansible-vault encrypt inventory/production/group_vars/vault.yml
```

Set the ArgoCD admin password and optional GitHub/Docker values.

## 3. Run

```bash
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i inventory/production/hosts.yml site.yml --ask-vault-pass
```

The first run:
1. prepares Ubuntu nodes
2. clones Kubespray
3. creates the Kubespray inventory
4. runs Kubespray
5. installs Helm
6. installs Traefik
7. installs cert-manager
8. installs Headlamp
9. installs ArgoCD
10. creates the ArgoCD GitOps Application

## 4. Verify

```bash
ansible-playbook -i inventory/production/hosts.yml verify.yml --ask-vault-pass
```

## 5. CI/CD

GitHub Actions should:
- test/build the React application
- build and push `docker.io/<user>/react-app:<commit-sha>`
- update the image tag in the GitOps repository

ArgoCD then detects the GitOps change and deploys it.

The application is NOT deployed by `kubectl` from GitHub Actions.

## 6. DNS

Create DNS records pointing to the IP that exposes Traefik:
- `reactjs.<base_domain>`
- `argocd.<base_domain>`
- `headlamp.<base_domain>`

For a cloud load balancer, use its external IP. For a lab NodePort setup, use the chosen public node IP.

## 7. Destroy

Application/platform cleanup:
```bash
ansible-playbook -i inventory/production/hosts.yml destroy.yml --ask-vault-pass
```

Kubernetes cluster reset is deliberately separate. Do not run it accidentally.
Use Kubespray's `reset.yml` from the cloned Kubespray directory only when you intentionally
want to remove the cluster.
