#!/bin/bash
## https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install vault-enterprise-1.13.2+ent-1.x86_64


sudo tee /etc/vault.d/vault.hcl -<<EOF
# Full configuration options can be found at https://www.vaultproject.io/docs/configuration

ui = true

#mlock = true
disable_mlock = true
cluster_addr  = "http://{{ GetInterfaceIP \"eth0\" }}:8201"
api_addr      = "http://{{ GetInterfaceIP \"eth0\" }}:8200"

#storage "file" {
#  path = "/opt/vault/data"
#}

storage "raft" {
  node_id = "node-${INSTANCE_ID}"
  path = "/opt/vault/data"
  retry_join {
    auto_join = "provider=aws tag_key=service tag_value=${TAG}"
    auto_join_scheme = "http"
  }
}

# HTTP listener
listener "tcp" {
  address = "0.0.0.0:8200"
  tls_disable = 1
}

# HTTPS listener
#listener "tcp" {
#  address       = "0.0.0.0:8200"
#  tls_cert_file = "/opt/vault/tls/tls.crt"
#  tls_key_file  = "/opt/vault/tls/tls.key"
#}

# Enterprise license_path
# This will be required for enterprise as of v1.8
license_path = "/etc/vault.d/vault.hclic"
#disable_performance_standby = false

# Example AWS KMS auto unseal
seal "awskms" {
  region = "ca-central-1"
  kms_key_id = "mrk-316b5f6f66ae4b898c8db08abb53eef9"
}

# reporting disable
reporting {
  license {
    enabled = false
  }
}

EOF

sudo tee /etc/vault.d/vault.hclic -<<EOF
${vault_license}
EOF


sudo systemctl enable vault
sudo systemctl start vault