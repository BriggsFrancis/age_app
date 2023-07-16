FROM python:3.10.6-slim-bullseye

ENV PYTHONUNBUFFERED=1
RUN apt-get update
WORKDIR /age_app


COPY . .

RUN pip3 install -r requirements.txt 
RUN chmod +x entrypoint.sh 
RUN chmod +x function.sh 
RUN chmod +x migrate.sh 

CMD [ "bash" "entrypoint.sh" ]


