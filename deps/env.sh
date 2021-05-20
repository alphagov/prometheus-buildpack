

setup_app(){

    export APP_ROOT="${HOME}"
    export PROMETHEUS_FLAGS="${PROMETHEUS_FLAGS:-}"
    export AUTO_DB_SETUP="${AUTO_DB_SETUP:-fale}"
    export PROMETHEUS_DB_SERVICE_NAME="${PROMETHEUS_DB_SERVICE_NAME:-null}"
    
    local db=''

    if [ "${PROMETHEUS_DB_SERVICE_NAME}" != null ] 
    then 
        export AUTO_DB_SETUP=false
        db=$(jq -r --arg instance_name $PROMETHEUS_DB_SERVICE_NAME '.[][] | select(.instance_name == $instance_name)' <<<  "${VCAP_SERVICES}")
        #if DB is not found , let user know 
        if [ -z "${db}" ]
        then
            echo "Service ${PROMETHEUS_DB_SERVICE_NAME} not found"
        fi
    fi

    if [[ "${AUTO_DB_SETUP}" == true || "${AUTO_DB_SETUP}" == True || "${AUTO_DB_SETUP}" == TRUE || "${AUTO_DB_SETUP}" == 1 ]] 
    then
        db=$(jq -r '.[][] | select(.label == "influxdb" )' <<<  "${VCAP_SERVICES}")
        #if DB is not found , let user know 
        if [ -z "${db}" ]
        then
            echo "AUTO_DB_SETUP did not find any supported databases"
        fi
    fi

    remote_read=$(jq -r '.credentials.prometheus.remote_read' <<< "${db}")
    remote_write=$(jq -r '.credentials.prometheus.remote_write' <<< "${db}")

    remote_read_url=$(jq -r '.[].url' <<< "${remote_read}")
    remote_read_user=$(jq -r '.[].basic_auth.username' <<< "${remote_read}")
    remote_read_password=$(jq -r '.[].basic_auth.password' <<< "${remote_read}")

    remote_write_url=$(jq -r '.[].url' <<< "${remote_write}")
    remote_write_user=$(jq -r '.[].basic_auth.username' <<< "${remote_write}")
    remote_write_password=$(jq -r '.[].basic_auth.password' <<< "${remote_write}")

  
    declare -r file="${HOME}/prometheus.yml"
    declare -x remote_readwrite_done="${remote_readwrite_done:-false}"

    echo "" >> "${file}"

    if  [[ ! -z $remote_read ]] && [[ ! -z $remote_write ]]
    then
        if [[ $remote_readwrite_done == false ]]
        then 
            echo "remote_read:" >> "${file}"
            echo "  - url: \"${remote_read_url}?u=${remote_read_user}&p=${remote_read_password}\"" >> "${file}"
            
            echo "" >> "${file}" 

            echo "remote_write:" >> "${file}"
            echo "  - url: \"${remote_write_url}&u=${remote_write_user}&p=${remote_write_password}\"" >> "${file}"

            export remote_readwrite_done=true
        fi
    fi

}

main(){
    setup_app
}

main