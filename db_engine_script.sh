#!/bin/bash
#
#
#
echo -e "############################################################"
echo -e "############## Vault Database Engine Script ################"
echo -e "############################################################"

# Create Job Choice (Engine, Connection)

# Namespace Typing

# DB Engine Name Typing

# 




# Prompt for confirmation
read -p "This script installs vault-ssh-helper, disables selinux, and changes the /etc/pam.d/sshd and /etc/sshd_config/ files.. Are you sure you want to proceed? (y/n): " choice

# Convert the choice to lowercase
choice=${choice,,}

# Check if the user confirmed to proceed
if [[ "$choice" != "y" ]]; then
    echo "Script execution canceled."
    exit 0
fi

# Check if SELinux is enabled
if [[ $(getenforce) == "Enforcing" ]]; then
    # Disable SELinux temporarily (will be enabled again after a reboot)
    setenforce 0

    # Modify the SELinux configuration file to disable SELinux permanently
    sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config

    echo "SELinux has been disabled. Please reboot the system for the changes to take effect."
else
    echo "SELinux is already disabled."
fi

#Vault-ssh-helper values
echo "Type Vault External Address"
echo "Example : http://nlb.vault.com:8200"
read vault
echo "Type Allowed Role Name"
echo "Example : ssh-otp-role"
read Role
echo "Type Namespace to apply"
echo "Example : empty or Namespace_Name"
read NS

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