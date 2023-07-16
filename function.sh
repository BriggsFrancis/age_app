#!/usr/bin/env bash 
set -e 

cyan="\e[0;36m"
blue="\e[0;34m"
red="\e[0;31m"
endd="\e[m"
custom_exit=115

notify() {
    if [ $# -lt 2 ]; then
     echo -e "${red} 2 postional arguments required ${end}"

    fi

    case $1 in 
    error)
        echo -e "${red} $2 ${endd}" ;;
    success)
        echo -e "${blue} $2 ${endd}" ;;
    info)
        echo -e "${cyan} $2 ${endd}" ;;
    *)
        echo -e "${red} Parameter required in script ${end}" ;;
    esac
}

error_message(){
    local error_message=$1
    notify error "${error_message}"
    exit "${custom_exit}"
}

