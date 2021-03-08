# set base image (host OS)
FROM ubuntu:latest

# set the working directory in the container
WORKDIR /code

# copy the dependencies file to the working directory
COPY pip-packages.txt .

# install packages
RUN apt-get update && apt-get install -y \
	git \
	python3 \
	python3-dev \
	libffi-dev \
	libssl-dev \
	libsqlite3-dev \
	python3-pip \
	python-setuptools 

# install pip packages
RUN pip3 install -r pip-packages.txt

# checkout code from github
RUN git clone https://github.com/rzerr/PyKMIP.git

# set directory to python app directory
WORKDIR /code/PyKMIP

#build the python application
RUN python3 setup.py install

# set directory back to the working directory
WORKDIR /code

# copy predefined server config
COPY server.conf .

# generate self signed cert required by the app
RUN openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /code/selfsigned.key -out \
 /code/selfsigned.crt -subj "/C=SG/ST=Singapore/L=Singapore/O=local/CN=www.example.com"

# command to run on container start
CMD [ "/usr/bin/python3", "PyKMIP/bin/run_server.py","-f" , "server.conf" ]
