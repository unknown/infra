# infra

My HashiStack (Consul, Vault, Nomad) cluster setup on Hetzner Cloud.

## Components

- Consul: A distributed service mesh
- Vault: A secret management system
- Nomad: A cluster management system
- Traefik: A reverse proxy and load balancer

## Architecture

The cluster consists of machines acting as "servers" and "clients", with the following roles:

- Servers: Consul, Vault, Nomad, Traefik
- Clients: Consul, Vault, Nomad

Note: Consul, Vault, Nomad, and Traefik all run directly on the hosts, while Nomad jobs (e.g. Postgres, Redis) run as containers.

## Requirements

- Hetzner Cloud account
- Terraform
- Ansible

## Usage

### Provisioning

1. Enter the `terraform` directory and create a `variables.hcl` file:

```bash
cd terraform
cp variables.hcl.example variables.hcl
```

2. Edit the `variables.hcl` file to match your Hetzner Cloud project and desired cluster configuration.

3. Run the Terraform commands to provision the cluster:

```bash
terraform init
terraform apply
```

### Configuring

1. Enter the `ansible` directory:

```bash
cd ansible
```

2. Run the playbooks:

```bash
ansible-playbook -i inventory 01-common.yml 02-consul.yml 03-vault.yml 04-nomad.yml 05-traefik.yml
```

### Deploying jobs to the cluster

1. Enter the `nomad` directory:

```bash
cd nomad
```

2. Run the Terraform commands to deploy the jobs:

```bash
terraform init
terraform apply
```
