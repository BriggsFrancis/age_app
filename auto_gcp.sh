#!/usr/bin/env bash 

set -e 

count(){
   num=$1
   sleep_time=$2
   for (( i = 1; i <= $num; i++));do
     echo $i
     sleep $sleep_time
     done
}

cat <<EOF
USAGE: ENUSRE  YOU HAVE PYTHON INSTALLED
AND HAVE A REQUIREMENTS.TXT

Create a GCP PROJECT 
Enable billing 
Enable cloud sql,GKE,Compute Engine Api

Install  gloud cli 
 
EOF
read -p "Enter your deployment.yaml file path: " deployment_file
read -p "Enter cloud sql instance name you want to make: " CLOUD_SQL_INSTANCE_NAME 
read -p "Enter Project id: " PROJECT_ID 
read -p "Enter your region: " REGION
read -p "Which zone do you want your gke cluster in: " zone
read -p  "Enter the name you want to call your database: " DATABASE_NAME
read -p "Enter password for your db: " DATABASE_PASSWORD
read -p "Enter username for your db: " DATABASE_USERNAME
read -p "Enter the name for your app superuser: " SUPERUSER
read -p "Enter the email for your app superuser: "SUPERUSER_EMAIL

cat >  .envv.prod <<EOF 
DATABASE_NAME=${DATABASE_NAME}
DATABASE_USER=${DATABASE_USERNAME}
DATABASE_PASSWORD=${DATABASE_PASSWORD}
EOF

cat .env >> .envv.prod

export DATABASE_NAME=${DATABASE_NAME}
export DATABASE_USER=${DATABASE_USERNAME}
export DATABASE_PASSWORD=${DATABASE_PASSWORD}
export GOOGLE_CLOUD_PROJECT=${PROJECT_ID}

MEDIA_BUCKET="${PROJECT_ID}_bucket"


echo  "Intailizing google cloud"
gcloud init 

# echo "clone repo with https"
# read -p "Enter git repo: " repo
# git clone  ${repo}

read -p "Enter working directory (absolute path): " directory
echo "Going into ${directory}"
cd ${directory}

echo "Make virtual envirnoment (venv)"
python3 -m venv venv
echo "Activating venv"
source  venv/bin/activate

echo "Upgrading pip and Installing requirements "
pip install --upgrade pip 
pip install -r requirements.txt

echo  "Downloading cloud sql auth proxy"
cat <<EOF
If you're testing your app locally this is important 
By now you should have a project with a project id 

EOF
echo "Auth and acquire credentials for the API"
gcloud auth application-default login


echo "For a 64bit linux system"
curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.6.0/cloud-sql-proxy.linux.amd64
chmod +x cloud-sql-proxy

echo "rememeber the location of this download"
echo "making postres instance"
gcloud sql instances create ${CLOUD_SQL_INSTANCE_NAME} \
     --project ${PROJECT_ID} \
    --database-version POSTGRES_13 \
     --tier db-f1-micro \
    --region ${REGION}

echo "Create a database"
gcloud sql databases create ${DATABASE_NAME} \
    --instance ${CLOUD_SQL_INSTANCE_NAME}

echo "Creating a user for db"
gcloud sql users create ${DATABASE_USERNAME} \
     --instance ${CLOUD_SQL_INSTANCE_NAME} \
     --password ${DATABASE_PASSWORD}


echo "This will sleep for 15 mins to give you time"
cat <<EOF 
Make  cloud sql service
In the Google Cloud console, go to the Service accounts page.

Go to Service accounts
Select the project that contains your Cloud SQL instance.
Click Create service account.
In the Service account name field, enter a descriptive name fo the service account.
Change the Service account ID to a unique, recognizable value and thhen click Create and continu.
Click the Select a role field and selet one of the following roles:

     Cloud SQL > Cloud SQL Client
     Cloud SQL > Cloud SQL Editor
     Cloud SQL > Cloud SQL Admin

Click Done to finish creating the service account.
Click the action menu forr your new service account and thenn seelect Manage keys.
Click the Add key drop-down menu and thenn click Create new key.
Confirm that the key type is JSON and thenn click Create.

The private key file is downloaded to your machine. You can move it to another location. Keep the key file secure.

EOF

#count 15 60

read -p "Enter the absolute path to the private key file:" PATH_TO_CREDENTIAL_FILE

echo "We have gotten to kuberentes"
echo "Finding out connection name"
CONNECTION_NAME=$(gcloud sql instances describe ${CLOUD_SQL_INSTANCE_NAME} --format "value(connectionName)")
echo "Connection name: ${CONNECTION_NAME}"


echo "./cloud-sql-proxy ${PROJECT_ID}:${REGION}:${CLOUD_SQL_INSTANCE_NAME}" > ${directory}/run.sh

chmod +x ${directory}/run.sh  

echo "Run run.sh to start in a separate terminal" 

echo "counting to 20"
count 20 2

echo "Making Migrations and collecting static"
chmod +x migrate.sh
chmod +x entrypoint.sh

python3 manage.py collectstatic --noinput
 # create a superuser 


python3 manage.py createsuperuser \
                    --username "${SUPERUSER}" \
                    --email "${SUPERUSER_EMAIL}" \
                    --noinput \
                    || true 

./migrate.sh
./entrypoint.sh

echo "Creating storge bucket to serve static files"
gsutil mb gs://"${MEDIA_BUCKET}"
gsutil defacl set public-read gs://"${MEDIA_BUCKET}"

echo "Collecting static files"
python3 manage.py collectstatic

echo "Uploading static to cloud storaage"
gsutil -m rsync -r ./static gs://"${MEDIA_BUCKET}"/static

settings=$(find . -name "settings.py")

echo  "Replacing Settings.py STATIC URL"

sed -i "s#'/static/'#'http://storage.googleapis.com/${MEDIA_BUCKET}/static/'#g" ${settings}

echo "Creating gke cluster"
read -p "How many nodes do you want: " number_of_nodes
read -p "Name your cluster: " Cluster_name
read -p "Enter the name you want for your secrets: " SECRETS_FILE_NAME
SECRETS_FILE_NAME=${SECRETS_FILE_NAME:-cloudsql-oauth-credentials}

gcloud container clusters create ${Cluster_name} \
  --scopes "https://www.googleapis.com/auth/userinfo.email","cloud-platform" \
  --num-nodes "${number_of_nodes}" --zone "${zone}"

gcloud container clusters get-credentials "${Cluster_name}" --zone "${zone}"

kubectl create secret generic ${SECRETS_FILE_NAME} --from-file=credentials.json="${PATH_TO_CREDENTIAL_FILE}"
kubectl create secret generic cloudsql --from-env-file=.envv.prod

echo "Pulling docker image of cloud sql proxy"

sudo docker pull b.gcr.io/cloudsql-docker/gce-proxy

echo "Build a Docker image."
read -p "Provide an Image name:" IMAGE_NAME
read -p "Provide a tag: " TAG
# read -p "What is the name for your repo: " REPO_NAME
# read -p "Give a description: " DESCRIPTION

gcloud services enable artifactregistry.googleapis.com

# echo "Create Artficat registry"
# gcloud artifacts repositories create "${REPO_NAME}" --repository-format=docker \
#                                       --location "${REGION}" --description="${DESCRIPTION}"
sudo docker build -t gcr.io/"${PROJECT_ID}"/"${IMAGE_NAME}:${TAG}" .

echo "Configure Docker to use gcloud as a credential helper, so that you can push the image to Container Registry"

gcloud auth configure-docker

echo "Push the Docker image"

sudo docker push gcr.io/"${PROJECT_ID}"/"${IMAGE_NAME}:${TAG}" 
# "${REPO_NAME}"/

sed -i  "s/'<your-project-id>'/${PROJECT_ID}/g" "${deployment_file}"

sed -i  "s/'<SECRETS_FILE_NAME>'/${SECRETS_FILE_NAME}/g" "${deployment_file}"
sed -i  "s/<IMAGE_NAME>/${IMAGE_NAME}:${TAG}/g" "${deployment_file}"
sed -i  "s/'<your-cloudsql-connection-string>'/${CONNECTION_NAME}/g" "${deployment_file}"
sudo docker build -t gcr.io/"${PROJECT_ID}"/"${IMAGE_NAME}:${TAG}" .


echo "Creating Gke resource"
kubectl create -f "${deployment_file}"


