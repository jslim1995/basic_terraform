#!/bin/bash
sudo yum install -y yum-utils shadow-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
# sudo yum -y install consul-enterprise-1.15.3+ent-1.x86_64
sudo yum -y install consul-enterprise-1.15.3+ent-1.aarch64

sudo tee /etc/consul.d/consul.hcl -<<EOF
# Fullconfiguration options can be found at https://www.consul.io/docs/agent/options.html
# datacenter
datacenter = "dc1"

# data_dir
data_dir = "/opt/consul"

# client_addr
client_addr = "0.0.0.0"

# ui
#ui_config{
#  enabled = true
#}

# server
server = true

# Bind addr

bind_addr = "{{ GetInterfaceIP \"eth0\" }}"

# Enterprise License
license_path = "/etc/consul.d/consul.hclic"

# bootstrap_expect
bootstrap_expect=3

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