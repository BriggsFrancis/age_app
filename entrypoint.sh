#!/usr/bin/env bash 
set -e 
source function.sh 

PORT=${PORT:-8000}
workers=4
project_name=age_calc
error_msg="Couldn't runserver"

# This script is for running the server 

notify info "===========Running Server==========="
gunicorn --bind=0.0.0.0:${PORT} \
         --workers=${workers} \
         ${project_name}.wsgi:application \
         || error_message "${error_msg}" 

exit 0