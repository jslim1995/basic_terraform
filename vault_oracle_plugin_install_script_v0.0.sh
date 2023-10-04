#!/bin/bash
init() {
    echo -e "####################################################################"
    echo -e "################ Vault Oracle plugin install Script ################"
    echo -e "####################################################################"

    ID=""
    processor=$(uname -p)
    glibc_version=""
    libaio_version=""
    work_dir="$(pwd)/vault_oracle_plugin_script"
    info_log_file=${work_dir}/info.log
    error_log_file=${work_dir}/error.log
    create_dir $work_dir
    check_proccessor
    check_os
    check_required_package
    install_oracle_instant_client
}

create_dir() {
    if [[ ! -d $1 ]]; then
        mkdir $1
    fi
}

check_proccessor() {
    if [[ $processor == "x86_64" || $processor == "aarch64" ]]; then
        echo "proccessor : ${processor}" > $info_log_file
    else
        echo "The $processor is not supported in the script." > $error_log_file
        exit 1
    fi
}

#Linux OS Version Check
check_os() {
    # if /etc/os-release file exits
    if [ -f /etc/os-release ]; then
        # Read ID value from /etc/os-release
        source /etc/os-release

        if [[ $ID == "ubuntu" ]]; then
            # Ubuntu
            version=$(lsb_release -rs)
            echo -e "Ubuntu version: ${version}\n" > $info_log_file
        elif [[ $ID == "rhel" || $ID == "centos" ]]; then
            # Red Hat Linux or CentOS
            version=$(cat /etc/redhat-release)
            echo -e "Red Hat Linux or CentOS : ${version}\n" > $info_log_file
        elif [[ $ID == "amzn" ]]; then
            # Amazon Linux
            version=$(cat /etc/system-release)
            echo -e "Amazon Linux : ${version}\n" > $info_log_file
        else
            echo "$ID is Unsupported." > $error_log_file
            exit 1
        fi
    else
        echo "Can not find /etc/os-release" > $error_log_file
        exit 1
    fi
}

# Check required package installed
check_required_package() {
    if [[ $ID == "amzn" || $ID == "rhel" || $ID == "centos" ]]; then
        glibc_version=$(yum list installed glibc 2>/dev/null | grep glibc | awk '{print $2}')
        libaio_version=$(yum list installed libaio 2>/dev/null | grep libaio | awk '{print $2}')
        if [[ $libaio_version == "" ]]; then
            sudo yum install -y libaio
            echo "libaio has been installed" > $info_log_file
        fi
    elif [[ $ID == "ubuntu" ]]; then
        # todo : ubuntu일 경우
    else
    fi
}

install_oracle_instant_client() {
    # glibc_version check
    if [[ $processor == "x86_64" ]]; then
        # check_oic_version "2.27" "19.10" "19.19"
    elif [[ $processor == "aarch64" ]]; then
        check_oic_version "2.27" "19.10" "19.19"
    else

    fi

    oic_basic_url="https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient/aarch64/getPackage/oracle-instantclient${oic_version}-basic-${oic_version}.0.0.0-1.aarch64.rpm"
    oic_sdk_url="https://yum.oracle.com/repo/OracleLinux/OL8/oracle/instantclient/aarch64/getPackage/oracle-instantclient${oic_version}-devel-${oic_version}.0.0.0-1.aarch64.rpm"
    oic_basic_file="oic-basic-${oic_version}.aarch64.rpm"
    oic_sdk_file="oic-sdk-${oic_version}.aarch64.rpm"

    # download oic-basic
    wget "$oic_basic_url" -O ${work_dir}/$oic_basic_file
    # download oic-sdk
    wget "$oic_sdk_url" -O ${work_dir}/$oic_sdk_file

    # install oic-basic
    sudo yum install -y ${work_dir}/$oic_basic_file
    # install oic-sdk
    sudo yum install -y ${work_dir}/$oic_sdk_file
}

# Check the version of oracle_instant_client to install.
# x86_64 : 2.14
# aarch64 : 2.27
check_oic_version() {
    version="$glibc_version"
    target_version="$1"
    previous_version="$2"
    latest_version="$3"

    # '.'을 기준으로 분할하여 주요 버전과 하위 버전을 얻음
    main_version=$(echo $version | cut -d'.' -f1)
    sub_version=$(echo $version | cut -d'.' -f2 | cut -d'-' -f1)

    # 타겟 버전도 분할
    target_main_version=$(echo $target_version | cut -d'.' -f1)
    target_sub_version=$(echo $target_version | cut -d'.' -f2)

    # 주요 버전과 하위 버전을 비교
    if [[ $main_version -lt $target_main_version ]]; then
        oic_version="$previous_version"
    elif [[ $main_version -eq $target_main_version && $sub_version -lt $target_sub_version ]]; then
        oic_version="$previous_version"
    else
        oic_version="$latest_version"
    fi
    echo "oracle_instant_client_version : ${oic_version}" > $info_log_file
}

get_vault_plugin_database_oracle_binary() {
    if [[ $processor == "x86_64" ]]; then
        # arch="amd"
        # x86은 vault에서 제공하는 바이너리 설치
    elif [[ $processor == "aarch64" ]]; then
        install_golang
    else
    fi
}

install_golang() {
    if [[ $processor == "x86_64" ]]; then
        # arch="amd"
        # x86은 vault에서 제공하는 바이너리 설치
    elif [[ $processor == "aarch64" ]]; then
        arch="arm"
        wget https://dl.google.com/go/go1.20.7.linux-arm64.tar.gz -O ${work_dir}/go1.20.7.linux-arm64.tar.gz
        sudo tar -C /usr/local -xzf ${work_dir}/go1.20.7.linux-arm64.tar.gz
        export PATH=$PATH:/usr/local/go/bin

        # golang installed check
        check_go=$(go version 2> /dev/null)
        if [[ $check_go == "" ]]l then
            echo "golang install error" > $error_log_file
            exit 1
        else
            # golang work dir setting
            mkdir ${work_dir}/go_work
            export GOPATH=${work_dir}/go_work
        fi
    fi
}

build_binary() {
    check_git=$(git version 2> /dev/null)
    if [[ $ID == "amzn" || $ID == "rhel" || $ID == "centos" ]]; then
        if [[ $check_git == "" ]]; then
            sudo yum install -y git
        else
        fi
        git clone https://github.com/hashicorp/vault-plugin-database-oracle.git ${work_dir}/go_work/vault-plugin-database-oracle
        pkg_config_path="$(pkg-config --variable pc_path pkg-config | cut -d':' -f1)/oci8.pc"
        sudo tee $pkg_config_path -<<EOF
        libdir=/usr/lib/oracle/${oic_version}/client64/lib
        includedir=/usr/lib/oracle/${oic_version}/client64/sdk/include/

        Name: oci8
        Description: oci8 library
        Libs: -L${libdir} -lclntsh
        Cflags: -I${includedir}
        Version: 19.10
EOF
    elif [[ $ID == "ubuntu" ]]; then
        # todo : ubuntu일 경우
    else
    fi
}






# download_





sleep 1

#if [ -f /etc/os-release ] && grep -q "Amazon Linux" /etc/os-release; then
#    AMAZON_LINUX_VERSION=$(grep -oP 'VERSION_ID="\K[^"]+' /etc/os-release)
#    echo "Amazon Linux version: $AMAZON_LINUX_VERSION"
#fi

# Prompt for confirmation
read -p "This script installs vault-ssh-helper, disables selinux, and changes the /etc/pam.d/sshd and /etc/sshd_config/ files.. Are you sure you want to proceed? (y/n): " choice

# Convert the choice to lowercase
choice=${choice,,}

# Check if the user confirmed to proceed
if [[ "$choice" != "y" ]]; then
    echo "Script execution canceled."
    exit 0
fi


#Download vault-ssh-helper
cpu=$(uname -p)
if [[ $cpu == "x86_64" ]]; then
    if [ ! -f "vault-ssh-helper_0.2.1_linux_amd64.zip" ]; then
        echo "File not found. Downloading..."
        wget https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_amd64.zip
    else
        echo "Helper File already exists."
    fi
elif [[ $cpu == "aarch64" ]]; then
    if [[ ! -f "vault-ssh-helper_0.2.1_linux_arm.zip"  ]]; then
        if [[ $ID == "rhel" ]]; then
            if [[ ! -f "vault-ssh-helper-arm-rhel" ]]; then
                echo "File not found. Downloading..."
                if [[ $VERSION_ID == 7.* ]]; then
                    echo "GO Install Process"
                    sleep 1
                    wget https://go.dev/dl/go1.20.4.linux-arm64.tar.gz	
                    tar -xzvf go1.20.4.linux-arm64.tar.gz
                    export PATH=$PATH:$(pwd)/go/bin
                fi
                sudo yum install -y go git
                git clone https://github.com/hashicorp/vault-ssh-helper.git
                cd vault-ssh-helper
                echo "GO Build Process"
                sleep 1
                go build .
            else
                echo "Helper File already exists."
            fi
        else
            echo "File not found. Downloading..."
            wget https://releases.hashicorp.com/vault-ssh-helper/0.2.1/vault-ssh-helper_0.2.1_linux_arm.zip
        fi
    else
        echo "Helper File already exists."
    fi
else
    echo "Unspecified processor information."
fi

sleep 1

#unzip vault-ssh-helper.zip
if [[ $cpu == "x86_64" ]]; then
                unzip -q vault-ssh-helper_0.2.1_linux_amd64.zip -d /usr/local/bin
elif [[ $cpu == "aarch64" ]]; then
                if [[ $ID == "rhel" ]]; then
			if [[ -f "vault-ssh-helper-arm-rhel" ]]; then
               		sudo mv vault-ssh-helper-arm-rhel /usr/local/bin/vault-ssh-helper
			else
			sudo mv vault-ssh-helper /usr/local/bin/
			fi
                else
               		unzip -q vault-ssh-helper_0.2.1_linux_arm.zip -d /usr/local/bin
                fi
else
                echo "Unspecified processor information."
fi

#Change vault-ssh-helper permission
chmod 0755 /usr/local/bin/vault-ssh-helper
chown root:root /usr/local/bin/vault-ssh-helper

#Create vault-ssh-helper Cofig Directory
mkdir /etc/vault-ssh-helper.d

#Create vault-ssh-helper Config File
tee /etc/vault-ssh-helper.d/config.hcl <<EOF
vault_addr = "${vault}"
tls_skip_verify = true
ssh_mount_point = "ssh"
namespace = "${NS}"
allowed_roles = "${Role}"
allowed_cidr_list = "0.0.0.0/0"
EOF
sleep 1

echo "Modifying /etc/ssh/sshd_config"
sleep 1

# Check if the file exists
if [ -f "/etc/ssh/sshd_config.d/50-redhat.conf" ]; then
#Backup /etc/ssh/sshd_config File
cp /etc/ssh/sshd_config.d/50-redhat.conf /etc/ssh/sshd_config.d/50-redhat.conf.orig
        #Parameter Check
        # Check if the parameter PasswordAuthentication exists in the configuration file
        if grep -q "^PasswordAuthentication" "/etc/ssh/sshd_config.d/50-redhat.conf"; then
        # If the parameter exists, update its value
                sed -i "s/^PasswordAuthentication.*/PasswordAuthentication no/" "/etc/ssh/sshd_config.d/50-redhat.conf"
        else
        # If the parameter doesn't exist, add it with the new value
                echo "PasswordAuthentication no" >> "/etc/ssh/sshd_config.d/50-redhat.conf"
        fi

        # Check if the parameter UsePAM exists in the configuration file
        if grep -q "^UsePAM" "/etc/ssh/sshd_config.d/50-redhat.conf"; then
        # If the parameter exists, update its value
                sed -i "s/^UsePAM.*/UsePAM yes/" "/etc/ssh/sshd_config.d/50-redhat.conf"
        else
        # If the parameter doesn't exist, add it with the new value
                echo "UsePAM yes" >> "/etc/ssh/sshd_config.d/50-redhat.conf"
        fi
        # Check if the parameter KbdInteractiveAuthentication or ChallengeResponseAuthentication exists in the configuration file
        if grep -q "^KbdInteractiveAuthentication" "/etc/ssh/sshd_config.d/50-redhat.conf"; then
        # If the parameter KbdInteractiveAuthentication exists, update its value
                sed -i "s/^KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/" "/etc/ssh/sshd_config.d/50-redhat.conf"
        elif grep -q "^ChallengeResponseAuthentication" "/etc/ssh/sshd_config.d/50-redhat.conf"; then
        # If the parameter doesn't exist but ChallengeResponseAuthentication exists, update its value
                sed -i "s/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/" "/etc/ssh/sshd_config.d/50-redhat.conf"
        fi
else
        cp /etc/ssh/sshd_config /etc/ssh/sshd_config.orig
        #Parameter Check
        # Check if the parameter PasswordAuthentication exists in the configuration file
        if grep -q "^PasswordAuthentication" "/etc/ssh/sshd_config"; then
        # If the parameter exists, update its value
                sed -i "s/^PasswordAuthentication.*/PasswordAuthentication no/" "/etc/ssh/sshd_config"
        else
        # If the parameter doesn't exist, add it with the new value
                echo "PasswordAuthentication no" >> "/etc/ssh/sshd_config"
        fi

        # Check if the parameter UsePAM exists in the configuration file
        if grep -q "^UsePAM" "/etc/ssh/sshd_config"; then
        # If the parameter exists, update its value
                sed -i "s/^UsePAM.*/UsePAM yes/" "/etc/ssh/sshd_config"
        else
        # If the parameter doesn't exist, add it with the new value
                echo "UsePAM yes" >> "/etc/ssh/sshd_config"
        fi
        # Check if the parameter KbdInteractiveAuthentication or ChallengeResponseAuthentication exists in the configuration file
        if grep -q "^KbdInteractiveAuthentication" "/etc/ssh/sshd_config"; then
        # If the parameter KbdInteractiveAuthentication exists, update its value
                sed -i "s/^KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/" "/etc/ssh/sshd_config"
        elif grep -q "^ChallengeResponseAuthentication" "/etc/ssh/sshd_config"; then
        # If the parameter doesn't exist but ChallengeResponseAuthentication exists, update its value
                sed -i "s/^ChallengeResponseAuthentication.*/ChallengeResponseAuthentication yes/" "/etc/ssh/sshd_config"
        else
    # If the parameter doesn't exist, add it with the new value
                if [ "$UBUNTU_VERSION" = "22.04" ]; then
                        echo "KbdInteractiveAuthentication yes" >> "/etc/ssh/sshd_config"
                else
                        echo "ChallengeResponseAuthentication yes" >> "/etc/ssh/sshd_config"
                fi
        fi

fi

echo "Modifying /etc/pam.d/ssh"
sleep 1

# Check if the file exists
if [ -f "/etc/pam.d/sshd" ]; then
    # Create a backup of the original file
cp /etc/pam.d/sshd /etc/pam.d/sshd.orig

    # Modify the file
    sed -i '/^auth       substack     password-auth/s/^/#/' /etc/pam.d/sshd
    sed -i '/^password   include      password-auth/s/^/#/' /etc/pam.d/sshd
    sed -i '/^@include common-auth/s/^/#/' /etc/pam.d/sshd
    #if the parameter doesn't exit, add it
    if ! grep -q "auth        requisite   pam_exec.so quiet expose_authtok log=/var/log/vaultssh.log /usr/local/bin/vault-ssh-helper -config=/etc/vault-ssh-helper.d/config.hcl -dev" "/etc/pam.d/sshd"; then
    echo "auth        requisite   pam_exec.so quiet expose_authtok log=/var/log/vaultssh.log /usr/local/bin/vault-ssh-helper -config=/etc/vault-ssh-helper.d/config.hcl -dev" >> "/etc/pam.d/sshd"
    fi
    #if the parameter doesn't exit, add it
    if ! grep -q "auth        optional    pam_unix.so not_set_pass use_first_pass nodelay" "/etc/pam.d/sshd";then
    echo "auth        optional    pam_unix.so not_set_pass use_first_pass nodelay" >> "/etc/pam.d/sshd"
    fi
else
    echo "File /etc/pam.d/sshd does not exist."
fi

echo -e "\n\n/etc/ssh/sshd_config File Changes"
if [ -f /etc/ssh/sshd_config.d/50-redhat.conf ]; then
diff /etc/ssh/sshd_config.d/50-redhat.conf.orig /etc/ssh/sshd_config.d/50-redhat.conf
else
diff /etc/ssh/sshd_config.orig /etc/ssh/sshd_config
fi

echo -e "\n\n/etc/pam.d/sshd File Changes"
diff /etc/pam.d/sshd.orig /etc/pam.d/sshd
sleep 1

#Restart sshd Service
if [ "$version" = "Amazon Linux AMI release 2018.03" ]; then
  service sshd restart
  echo -e "\nRestarted sshd service."
else
  systemctl restart sshd
  echo -e "\nRestarted sshd service."
fi