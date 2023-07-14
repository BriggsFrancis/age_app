#!/usr/bin/env bash 
set -e 


# This script is for handling migrations 

cyan="\e[0;36m"
blue="\e[0;34m"
red="\e[0;31m"
end="\e[m"
custom_exit=115

#load environment variables 
SUPERUSER=francis
SUPERUSER_EMAIL=briggsf22@gmail.com


notify() {
    if [ '$#' -lt 2 ]; then
     echo -e "${red} 2 postional arguments required ${end}"

    fi

    case $1 in 
    error)
        echo -e "${red} $2 ${end}" ;;
    success)
        echo -e "${blue} $2 ${end}" ;;
    info)
        echo -e "${cyan} $2 ${end}" ;;
    *)
        echo -e "${red} Parameter required in script ${end}" ;;
    esac
}

error_message(){
    local error_message=$1
    notify error "${error_message}"
    exit "${custom_exit}"
}
# create a superuser 

notify info "====Creating Superuser===="
python3 manage.py createsuperuser \
                    --username "${SUPERUSER}" \
                    --email "${SUPERUSER_EMAIL}" \
                    --noinput \
                    || true 

notify info "====Migrating===="
python3 manage.py makemigrations 
python3 manage.py migrate --noinput 

exit 0 

