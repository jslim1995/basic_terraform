#!/bin/bash
## https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
# export REGION=$(curl -s http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | sed 's/.*: "\(.*\)".*/\1/')
# export INSTANCE_ID=$(ec2-metadata --instance-id | cut -d " " -f 2)
# export TAG=$(aws ec2 describe-instances \
# --region $REGION \
# --instance-ids $INSTANCE_ID \
# --query "Reservations[].Instances[].Tags[?Key=='service'].Value[]" | grep \" | awk -F\" '{print $2}')

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
# x86
sudo yum -y install consul-enterprise-1.15.3+ent-1.x86_64
sudo yum -y install vault-enterprise-1.13.2+ent-1.x86_64
# arm
# sudo yum -y install consul-enterprise-1.15.3+ent-1.aarch64
# sudo yum -y install vault-enterprise-1.13.4+ent-1.aarch64

sudo tee /etc/consul.d/consul.hcl -<<EOF
# Fullconfiguration options can be found at https://www.consul.io/docs/agent/options.html
# datacenter
datacenter = "dc1"

# data_dir
data_dir = "/opt/consul"

# client_addr
#client_addr = "0.0.0.0"

# ui
#ui_config{
#  enabled = true
#}

# server
#server = true

# Bind addr

bind_addr = "{{ GetInterfaceIP \"eth0\" }}"

# Enterprise License
license_path = "/etc/consul.d/consul.hclic"

# bootstrap_expect
#bootstrap_expect=3

# encrypt
encrypt = "moikosStCf56OR/Dvuy4mqY7ABKP2J76BBA8GF9qJF8="


# retry_join
retry_join = ["provider=aws tag_key=auto_join tag_value=${tag}"]

performance {
  raft_multiplier = 1
}

reporting {
  license {
    enabled = false
  }
}

EOF
sudo tee /etc/consul.d/consul.hclic -<<EOF
${consul_license}
EOF

sudo systemctl enable consul
sudo systemctl start consul

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

storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault"
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

# Example AWS KMS auto unseal
#seal "awskms" {
#  region = "us-east-1"
#  kms_key_id = "REPLACE-ME"
#}

# (option) license reporting disable
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