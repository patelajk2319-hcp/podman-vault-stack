# podman-vault-stack

## Description
This repository contains a Podman Compose stack with the following services:
- grafana
- loki
- prometheus
- promtail
- vault enterprise with raft backend
- Redis
- Elasticsearch and Kibana
- Elastic Agent and Fleet Server for Log Vault Aggregation
- DUO MFA

## Pre-requisites

Install `Podman` and `podman-compose` with the following commands:
```shell
  brew install podman podman-compose
  podman machine init
  podman machine start
```
Install `taskfile` and `jq` with the following command:
```shell
  brew install go-task jq
```
Install `terraform` with the following command:
```shell
  brew install terraform
```

Clone git repository:
```shell
git clone https://github.com/patelajk2319-hcp/vault-database.git
```

**IMPORTANT:** Create a `.env` file in the root folder (this file is required for the stack to work). Add the following content:
```shell
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_LICENSE=INSERT_LICENSE_HERE
```

If you do not have an enterprise license, you can request a trial license from the following link:
https://www.hashicorp.com/products/vault/trial

Alternatively, you can use the Vault BSL container image by changing the [podman-compose.yml](podman-compose.yml) file to use the `hashicorp/vault-enterprise:1.19` image.

If you do not have a DUO licence, you can request a trial from the following link:
https://signup.duo.com/

**IMPORTANT:** To use DUO MFA integration, create a `terraform.tfvars` file in the `labs/mfa/duo/` directory with the following content (obtain these values from the DUO Admin Portal):
```hcl
duo-integration-key = "YOUR_DUO_INTEGRATION_KEY"
duo-secret-key      = "YOUR_DUO_SECRET_KEY"
duo-api-hostname    = "YOUR_DUO_API_HOSTNAME"

username             = "your_username"
user-password        = "your_password"
username-not-exists  = "nonexistent_user"
```

To get these values:
1. Log in to the DUO Admin Portal (https://admin.duosecurity.com/)
2. Navigate to **Applications** → **Protect an Application**
3. Search for **Web SDK** and click **Protect**
4. Copy the **Integration key**, **Secret key**, and **API hostname** values

## Usage
[Taskfile.yml](Taskfile.yml) contains automation commands to manage the stack.

Launch the Podman Compose stack with the following command:
```bash
task up
```

Initialise vault and unseal.
```shell
task init
task unseal
```

Add the VAULT_TOKEN to the `.env` file and load.
```shell
source .env
vault token lookup
```

## Post initialisation
```shell
source .env
task up unseal
```

Navigate to the following urls:
- http://localhost:3000/ - Grafana
- http://localhost:9090/ - Prometheus
- http://localhost:8200/ - Vault
- http://localhost:6379/ - Redis
- https://localhost:5601/ - Kibana
- https://localhost:9200/ - Elasticsearch

Execute vault benchmark to test the performance of the vault and generate vault metrics.
(requires `vault-benchmark` cli tool)
```shell
vault namespace create vault-benchmark
task benchmark
```
Execute Redis Terraform to create dynamic users, and migrate static users from Redis to Vault
```shell
task redis
```
Execute Elasticsearch Terraform to create dynamic users, and migrate static users from Elasticsearch to Vault
```shell
task elk
```
Execute DUO Terraform to create a userpass user with MFA, you will need to have a user setup in DUO which matches the Vault Userpass user for this to work
```shell
task duo
```
To enable log aggregation so that Vault logs are sent to Elasticsearch.
```shell
task audit-logs
```
To completely delete the Podman Compose stack, e.g. there is a need to start from scratch
```shell
task rm
```
