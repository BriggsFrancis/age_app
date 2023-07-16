#!/usr/bin/env bash 
set -e 

source function.sh 

# This script is for handling migrations 


#load environment variables 
SUPERUSER=francis
SUPERUSER_EMAIL=briggsf22@gmail.com

# create a superuser 

notify info "===========Creating Superuser========"
python3 manage.py createsuperuser \
                    --username "${SUPERUSER}" \
                    --email "${SUPERUSER_EMAIL}" \
                    --noinput \
                    || true 

notify info "==========Migrating=========="
python3 manage.py makemigrations 
python3 manage.py migrate --noinput && notify success "====Migrations complete===="

exit 0 

