#!/bin/bash
init() {
    # jq install check
    if ! command -v jq 1> /dev/null; then
        echo "jq could not be found, please install it first."
        exit
    fi

    echo -e "##############################################################"
    echo -e "################ Vault Database Engine Script ################"
    echo -e "##############################################################"

    # init
    connection_name=""
    plugin_name=""
    role_name=""
    username=""
    password=""
    rotation_period=""
    flag=""
    SelectNamespace
}

# Namespace Typing
SelectNamespace() {
    echo -e "\nPlease enter the namespace you will be working on"
    read -p "Enter the namespace: " namespace

    namespace=${namespace// /}
    CheckDatabaseEngine
    SelectJob
}

# Create Job Choice (Connection, Role)
SelectJob() {
    echo -e "\nPlease select the type of work you will be doing"
    echo "1. create connection"
    echo "2. create role(dynamic/static)"
    echo "0. exit"
    read -p "Enter a number: " work_num

    if [[ "$work_num" == "1" ]]; then
        echo "selected job : create connection"

        ConnectionJob

    elif [[ "$work_num" == "2" ]]; then
        echo "selected job : create role(dynamic/static)"
        
        RoleJob

    elif [[ "$work_num" == "0" ]]; then
        echo "Exiting the Vault Database Engine script."
        exit 1
    else
        echo "'$work_num' is not allowed."
        SelectJob
    fi
}

### connection job start
ConnectionJob() {
    # input connection info
    flag="n"
    while [[ $flag != "y" ]]; do
        # DB Engine Config name Typing
        while [[ $connection_name == "" ]]; do
            echo -e "\nPlease enter the connection name"
            read -p "Enter the connection name(ex: mysql-test): " connection_name
        done
        
        # connection name validation check
        connection=($(vault read -ns=$namespace -format=json database/config/$connection_name 2> /dev/null | jq -r '.data'))
        if [[ "$connection" == "" ]]; then
            flag="y"
        else
            echo -e "\n'$connection_name' is already in use in namespace($namespace/)."
            ehco -e "**If the connection information changes, roles linked to that connection may become unusable."
            read -p "Do you still want to overwrite with this '$connection_name'? (y/n): " flag
            flag=${flag,,}
        fi
    done

    # Plugin Type Select
    SelectPlugin

    # connection url
    echo -e "\nPlease enter the DB connection url"
    echo "SAMPLE--"
    if [[ "$plugin_name" == *"mysql"* ]]; then
        echo -e "MySQL     \t>> {{username}}:{{password}}@tcp(127.0.0.1:3306)/"
        read -p "Enter the DB connection url: {{username}}:{{password}}@" connection_url
        connection_url="{{username}}:{{password}}@$connection_url"
    elif [[ "$plugin_name" == *"postgresql"* ]]; then
        echo -e "PostgreSQL\t>> postgresql://{{username}}:{{password}}@localhost:5432/postgres"
        read -p "Enter the DB connection url: postgresql://{{username}}:{{password}}@" connection_url
        connection_url="postgresql://{{username}}:{{password}}@$connection_url"
    elif [[ "$plugin_name" == *"oracle"* ]]; then
        echo -e "ORACLE    \t>> {{username}}/{{password}}@localhost:1521/orcl"
        read -p "Enter the DB connection url: {{username}}/{{password}}@" connection_url
        connection_url="{{username}}/{{password}}@$connection_url"
    else
        echo -e "The '$plugin_name' is not supported by the db_engine_script."
        read -p "Enter the DB connection url: " connection_url
    fi


    # username
    while [[ $username == "" ]]; do
        echo -e "\nPlease enter the DB username"
        read -p "Enter the DB username: " username
    done
    
    # password
    while [[ $password == "" ]]; do
        echo -e "\nPlease enter the DB password"
        read -s -p "Enter the DB password: " password
    done

    # allowed_roles
    echo -e "\n\nPlease enter the allowed roles. (ex: * or mysql-dynamic, mysql-static, ...)"
    read -p "Enter the allowed roles: " allowed_roles
    allowed_roles=${allowed_roles// /}

    echo -e "\nWould you like to create a DB connection with this information?"
    echo -e "connection name\t: $connection_name"
    echo -e "plugin name\t: $plugin_name"
    echo -e "connection url\t: $connection_url"
    echo -e "DB username\t: $username"
    echo -e "DB password\t: ${password//?/*}"
    echo -e "allowed roles\t: $allowed_roles"
    read -p "Enter (y/n): " flag
    flag=${flag,,}
    if [[ "$flag" != "y" ]]; then
        echo "Cancel the 'connection create' operation."
        init
    else
        CreateConnection
    fi
}

SelectPlugin() {
    plugin_count=1

    # pulgin search
    plugin_list=($(vault read -ns=$namespace -format=json sys/plugins/catalog | jq -r '.data.database[]' | grep 'mysql\|postgresql\|oracle'))
    echo -e "\nPlease select a plugin"
    for item in "${plugin_list[@]}"
    do
        echo "$plugin_count. $item"
        ((plugin_count++))
    done
    read -p "Enter a number: " plugin_num

    # validation
    if [[ "$plugin_num" -ge 1 && "$plugin_num" -le "$plugin_count" ]]; then
        ((plugin_num--))
        plugin_name=${plugin_list[$plugin_num]}
        echo "selected plugin : $plugin_name"
    else
        echo "'$plugin_num' is not in the range of 1 to $plugin_count."
        SelectPlugin
    fi
}

CheckDatabaseEngine() {
    echo -e "\nChecking for the existence of Database Engine in namespace($namespace/)."
    engine=($(vault read -ns=$namespace -format=json sys/mounts/database 2> /dev/null | jq -r '.data.type'))
    if [[ "$engine" == "" ]]; then
        read -p "Database Engine does not exist in the specified namespace($namespace/). Would you like to create Database Engine? (y/n): " flag
        flag=${flag,,}
        if [[ "$flag" == "y" ]]; then
            echo "Create Database Engine in namespace($namespace)."
            error_log_file="create_Engine_error_$(date '+%Y%m%d_%H%M%S').txt"
            result=($(vault secrets enable -ns=$namespace -path=database database 2> $error_log_file))
            if [[ "$result" != "" ]]; then
                CheckDatabaseEngine
            else
                echo "use command : vault secrets enable -ns=$namespace -path=database database" >> $error_log_file
                cat $error_log_file
                echo "Failed to create Database Engine. Saving the error message to a file($error_log_file)."
                ContinueOperation
            fi
        else
            echo "Cancel the 'Create Database Engine' operation."
            init
        fi
    elif [[ "$engine" != "database" ]]; then
        echo "A different secrets_engine exists at the 'database' path."
        init
    else
        echo "Database Engine is ready."
    fi
}

CreateConnection() {
    # vault create connection
    echo ""
    error_log_file="create_connection_error_$(date '+%Y%m%d_%H%M%S').txt"
    result=($(vault write -ns=$namespace -f database/config/$connection_name plugin_name=$plugin_name connection_url=$connection_url username=$username password=$password allowed_roles=$allowed_roles 2> $error_log_file))    
    if [[ "$result" == "" ]]; then
        echo "use command : vault write -ns=$namespace -f database/config/$connection_name plugin_name=$plugin_name connection_url=$connection_url username=$username password=$password allowed_roles=$allowed_roles" >> $error_log_file
        cat $error_log_file
        echo "Failed to create connection. Saving the error message to a file($error_log_file)."
    else
        echo -e "\nInformation on the created connection."
        echo -e "Namespace : $namespace\nPath : database/config/$connection_name"
        vault read -ns=$namespace database/config/$connection_name
    fi

    ContinueOperation
}
### connection job end

### role job start
RoleJob() {
    flag="n"

    # connection list check
    connection_list=($(vault list -ns=$namespace -format=json database/config | jq -r '.[]'))
    if [[ "$connection_list" == "" ]]; then
        echo -e "\nThere is no connection information in the batabase/ of the specified namespace($namespace/). Please create a connection first."
        SelectJob
    else
        # connection choice
        connection_name=""
        plugin_name=""
        SelectConnection
        if [[ "$connection_name" != "" ]]; then
            # Specify the Role Name
            SpecifyRoleName
            flag="n"
            while [[ $flag != "y" ]]; do
                # role type choice
                echo -e "\nPlease select the type of Role you will be creating"
                echo "1. dynamic role"
                echo "2. static role"
                echo "0. exit"
                read -p "Enter a number: " type_num

                if [[ "$type_num" == "1" ]]; then
                    flag="y"
                    DynamicRoleJob
                elif [[ "$type_num" == "2" ]]; then
                    flag="y"
                    StaticRoleJob
                elif [[ "$type_num" == "0" ]]; then
                    flag="y" 
                    echo "Cancel the 'select role type' operation."
                    init
                else
                    echo "'$type_num' is not allowed."
                fi
            done
        else
            echo "The connection_name value is missing."
            RoleJob
        fi
    fi
}

# connection choice
SelectConnection() {
    echo -e "\nPlease select the connection"
    connection_count=1
    for item in "${connection_list[@]}"
    do
        echo "$connection_count. $item"
        ((connection_count++))
    done
    
    connection_num=""
    while [[ $connection_num == "" ]]; do
        read -p "Enter a number: " connection_num
    done

    # validation
    if [[ "$connection_num" -ge 1 && "$connection_num" -le "$connection_count" ]]; then
        ((connection_num--))
        connection_name=${connection_list[$connection_num]}
        echo "selected connection : $connection_name"
        plugin_name=`vault read -ns=$namespace -format=json database/config/$connection_name | jq -r '.data.plugin_name'`
    else
        echo "'$connection_num' is not in the range of 1 to $connection_count."
        SelectConnection
    fi
}

# Specify the Role Name
SpecifyRoleName() {
    echo -e "\nList of roles name available in the connection($connection_name)."
    vault read -ns=$namespace -format=json database/config/$connection_name 2> /dev/null| jq -r '.data.allowed_roles[]'
    read -p "Please enter the Role Name : " role_name
    role_name=${role_name// /}
    if [[ "$role_name" == "" ]];then
        echo "The Role Name is a required value."
        SpecifyRoleName
    else
        # Check for duplicate role_name 
        dynamic_role_name_check=($(vault read -ns=$namespace -format=json database/roles/$role_name 2> /dev/null | jq -r '.data[]'))
        static_role_name_check=($(vault read -ns=$namespace -format=json database/static-roles/$role_name 2> /dev/null | jq -r '.data.username'))
        if [[ "$dynamic_role_name_check" != "" || "$static_role_name_check" != "" ]]; then
            echo "'$role_name' already exists."
            read -p "Do you want to overwrite with this '$role_name'? (y/n): " flag
            flag=${flag,,}
            if [[ "$flag" != "y" ]]; then
                SpecifyRoleName
            else
                # Skip selecting role_type 
                if [[ "$dynamic_role_name_check" != "" ]]; then
                    DynamicRoleJob
                fi
                if [[ "$static_role_name_check" != "" ]]; then
                    StaticRoleJob "$static_role_name_check"
                fi
            fi
        fi
    fi
}

# dynamic role job
DynamicRoleJob() {
    echo "selected type : dynamic role"

    if [[ "$plugin_name" == *"mysql"* ]]; then
        while [[ "$user_ip" == "" ]]; do
            echo -e "\nPlease enter the allowed host name (IP) for the account to be created. (ex: 192.168.0.%)"
            read -p "Enter the IP: " user_ip
        done
    fi

    # creation_statements
    echo -e "\nPlease enter the creation_statements"
    echo "SAMPLE--"
    if [[ "$plugin_name" == *"mysql"* ]]; then
        echo -e "MySQL     \t>> CREATE USER '{{name}}'@'$user_ip' IDENTIFIED BY '{{password}}'; GRANT SELECT ON *.* TO '{{name}}'@'$user_ip';"
        read -p "Enter the creation_statements: CREATE USER '{{name}}'@'$user_ip' IDENTIFIED BY '{{password}}'; " creation_statements
        creation_statements="CREATE USER '{{name}}'@'$user_ip' IDENTIFIED BY '{{password}}'; $creation_statements"
    elif [[ "$plugin_name" == *"postgresql"* ]]; then
        echo -e "PostgreSQL\t>> CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";"
        read -p "Enter the creation_statements: CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; " creation_statements
        creation_statements="CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}'; $creation_statements"

    elif [[ "$plugin_name" == *"oracle"* ]]; then
        echo -e "ORACLE    \t>> CREATE USER {{username}} IDENTIFIED BY \"{{password}}\"; GRANT CONNECT TO {{username}}; GRANT CREATE SESSION TO {{username}};"
        read -p "Enter the creation_statements: CREATE USER {{username}} IDENTIFIED BY \"{{password}}\"; " creation_statements
        creation_statements="CREATE USER {{username}} IDENTIFIED BY \"{{password}}\"; $creation_statements"
    else
        echo "The $plugin_name associated with the $connection_name is not supported by the db_engine_script."
        read -p "Enter the creation_statements: " creation_statements
    fi

    # creation_statements check
    if [[ "$creation_statements" == "" ]]; then
        DynamicRoleJob
    fi

    # default_ttl
    echo -e "\nPlease enter the default_ttl"
    read -p "Enter the default_ttl(optional): " default_ttl
    
    # max_ttl
    echo -e "\nPlease enter the max_ttl"
    read -p "Enter the max_ttl(optional): " max_ttl

    echo "Would you like to create the Dynamic Role with this information?"
    echo -e "connection name\t\t: $connection_name"
    echo -e "role name\t\t: $role_name"
    echo -e "creation_statements\t: $creation_statements"
    echo -e "default ttl\t\t: $default_ttl"
    echo -e "max ttl\t\t\t: $max_ttl"
    read -p "Enter (y/n): " flag
    flag=${flag,,}
    if [[ "$flag" != "y" ]]; then
        echo "Cancel the 'dynamic role create' operation."
        init
    else
        CreateDynamicRole
    fi
}

CreateDynamicRole() {
    # Vault create Dynamic Role
    echo ""
    echo "$creation_statements" | tee creation_statements.sql > /dev/null
    error_log_file="create_dynamic_role_error_$(date '+%Y%m%d_%H%M%S').txt"
    result=($(vault write -ns=$namespace -f database/roles/$role_name db_name=$connection_name creation_statements=@creation_statements.sql default_ttl=$default_ttl max_ttl=$max_ttl 2> $error_log_file))
    if [[ "$result" == "" ]]; then
        echo -e "use command : vault write -ns=$namespace -f database/roles/$role_name db_name=$connection_name creation_statements=@creation_statements.sql default_ttl=$default_ttl max_ttl=$max_ttl \n@creation_statements.sql : `cat creation_statements.sql`" >> $error_log_file
        cat $error_log_file
        echo "Failed to create dynamic role. Saving the error message to a file($error_log_file)."
    else
        echo -e "\nInformation on the created dynamic role."
        echo -e "Namespace : $namespace\nPath : database/roles/$role_name"
        vault read -ns=$namespace database/roles/$role_name
    fi
    rm creation_statements.sql

    ContinueOperation
}

StaticRoleJob() {
    echo "selected type : static role"

    if [[ "$plugin_name" == *"mysql"* ]]; then
        while [[ "$user_ip" == "" ]]; do
            echo -e "\nPlease enter the allowed host name (IP) for the account to be created. (ex: 192.168.0.%)"
            read -p "Enter the IP: " user_ip
        done
    fi

    # default rotation_statements
    flag="y"
    echo -e "\nDefault value for rotation_statements :"
    if [[ "$plugin_name" == *"mysql"* ]]; then
        echo -e "MySQL     \t>> ALTER USER '{{name}}'@'$user_ip' IDENTIFIED BY '{{password}}';"
        rotation_statements="ALTER USER '{{name}}'@'$user_ip' IDENTIFIED BY '{{password}}';"
    elif [[ "$plugin_name" == *"postgresql"* ]]; then
        echo -e "PostgreSQL\t>> ALTER USER \"{{name}}\" WITH PASSWORD '{{password}}';"
        rotation_statements="ALTER USER \"{{name}}\" WITH PASSWORD '{{password}}';"
    elif [[ "$plugin_name" == *"oracle"* ]]; then
        echo -e "ORACLE    \t>> ALTER USER {{username}} IDENTIFIED BY \"{{password}}\";"
        rotation_statements="ALTER USER {{username}} IDENTIFIED BY \"{{password}}\";"
    else
        echo "The $plugin_name associated with the $connection_name is not supported by the db_engine_script."
        flag="n"
    fi

    # default use check
    if [[ "$flag" == "y" ]]; then
        read -p "Do you want to use the default value for the rotation_statements? (y/n): " flag
        flag=${flag,,}
    fi

    # custom rotation_statements
    if [[ "$flag" != "y" ]]; then
        read -p "Enter the rotation_statements: " rotation_statements
    fi
    
    # rotation_statements check
    if [[ "$rotation_statements" == "" ]]; then
        StaticRoleJob
    fi


    # user_name
    if [[ $1 == ""  ]]; then
        # create
        while [[ $username == "" ]]; do 
            echo -e "\nPlease enter the DB username that password will be rotated"
            read -p "Enter the DB username: " username
        done
    else
        # update
        echo -e "\nThe Database username($1) set in the role cannot be modified."
        username=$1
        echo -e "DataBase username: $username"
    fi
    
    # rotation_period
    while [[ $rotation_period == "" ]]; do
        echo -e "\nPlease enter the rotation period"
        read -p "Enter the rotation_period(The minimum is 5s): " rotation_period
    done

    echo -e "\nWould you like to create the Static Role with this information?"
    echo -e "connection name\t\t: $connection_name"
    echo -e "role name\t\t: $role_name"
    echo -e "rotation_statements\t: $rotation_statements"
    echo -e "username\t\t: $username"
    echo -e "rotation_period\t\t: $rotation_period"
    read -p "Enter (y/n): " flag
    flag=${flag,,}
    if [[ "$flag" != "y" ]]; then
        echo "Cancel the 'static role create' operation."
        init
    else
        CreateStaticRole
    fi
}

CreateStaticRole() {
    # Vault create Static Role
    echo ""
    echo "$rotation_statements" | tee rotation_statements.sql > /dev/null
    error_log_file="create_static_role_error_$(date '+%Y%m%d_%H%M%S').txt"
    result=($(vault write -ns=$namespace -f database/static-roles/$role_name db_name=$connection_name rotation_statements=@rotation_statements.sql username=$username rotation_period=$rotation_period 2> $error_log_file))
    if [[ "$result" == "" ]]; then
        echo -e "use command : vault write -ns=$namespace -f database/static-roles/$role_name db_name=$connection_name rotation_statements=@rotation_statements.sql username=$username rotation_period=$rotation_period \n@rotation_statements.sql : `cat rotation_statements.sql`" >> $error_log_file
        cat $error_log_file
        echo "Failed to create static role. Saving the error message to a file($error_log_file)."
    else
        echo -e "\nInformation on the created static role."
        echo -e "Namespace : $namespace\nPath : database/static-roles/$role_name"
        vault read -ns=$namespace database/static-roles/$role_name
    fi
    rm rotation_statements.sql

    ContinueOperation
}

ContinueOperation() {
    read -p "continue with the operation (y/n): " flag
    flag=${flag,,}
    if [[ "$flag" == "y" ]]; then
        init
    else
        exit 1
    fi
}
### role job end

init