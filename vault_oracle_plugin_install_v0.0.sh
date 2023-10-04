#!/bin/bash
cd
# oracle instance client install version
oic_version=19.10

# work dir path
work_dir="/home/ec2-user/vault_oracle_plugin_script"

# log file path
log_file=${work_dir}/script.log

rm -rf $work_dir
mkdir $work_dir

# required install package
libaio_version=$(yum list installed libaio 2> /dev/null | grep libaio | awk '{print $2}')
if [[ $libaio_version == "" ]]; then
    sudo yum install -y libaio >> $log_file
fi
shasum_version=$(shasum -v 2> /dev/null)
if [[ $shasum_version == "" ]]; then
    sudo yum install -y perl-Digest-SHA >> $log_file
fi
go_version=$(go version 2> /dev/null)
if [[ $go_version == "" ]]; then
    sudo yum install -y golang >> $log_file
fi
git_version=$(git version 2> /dev/null)
if [[ $git_version == "" ]]; then
    sudo yum install -y git >> $log_file
fi

oic_basic_url="https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient/aarch64/getPackage/oracle-instantclient${oic_version}-basic-${oic_version}.0.0.0-1.aarch64.rpm"
oic_sdk_url="https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient/aarch64/getPackage/oracle-instantclient${oic_version}-devel-${oic_version}.0.0.0-1.aarch64.rpm"
oic_basic_file="oic-basic-${oic_version}.aarch64.rpm"
oic_sdk_file="oic-sdk-${oic_version}.aarch64.rpm"

# download oic-basic
wget "$oic_basic_url" -O ${work_dir}/$oic_basic_file >> $log_file
# download oic-sdk
wget "$oic_sdk_url" -O ${work_dir}/$oic_sdk_file >> $log_file

# install oic-basic
sudo yum install -y ${work_dir}/$oic_basic_file >> $log_file
# install oic-sdk
sudo yum install -y ${work_dir}/$oic_sdk_file >> $log_file

mkdir ${work_dir}/go_work
export GOPATH=${work_dir}/go_work

# build file install
git clone https://github.com/hashicorp/vault-plugin-database-oracle.git ${work_dir}/go_work/vault-plugin-database-oracle >> $log_file

# pkg config setting
pkg_config_path="$(pkg-config --variable pc_path pkg-config | cut -d':' -f1)/oci8.pc"
sudo tee $pkg_config_path -<<EOF
## ${pkg_config_path}
libdir=/usr/lib/oracle/${oic_version}/client64/lib
includedir=/usr/include/oracle/${oic_version}/client64/

Name: oci8
Description: oci8 library
Libs: -L\${libdir} -lclntsh
Cflags: -I\${includedir}
Version: ${oic_version}
EOF
cat $pkg_config_path >> $log_file

# binary build
cd ${work_dir}/go_work/vault-plugin-database-oracle
sudo go build -o vault-plugin-database-oracle ./plugin >> $log_file && ls

# Vault Plugin Permission settings
sudo mkdir /etc/vault.d/plugin/
sudo chown vault:vault /etc/vault.d/plugin

sudo cp ${work_dir}/go_work/vault-plugin-database-oracle/vault-plugin-database-oracle /etc/vault.d/plugin
sudo chown vault:vault /etc/vault.d/plugin/vault-plugin-database-oracle

check_plugin_directory=$(cat /etc/vault.d/vault.hcl | grep "plugin_directory = \"/etc/vault.d/plugin/\"")
if [[ $check_plugin_directory == "" ]]; then
    echo -e "plugin_directory = \"/etc/vault.d/plugin/\"" | sudo tee -a /etc/vault.d/vault.hcl
fi

# sha256sum check
sha256sum /etc/vault.d/plugin/vault-plugin-database-oracle >> $log_file