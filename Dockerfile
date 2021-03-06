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

RUN git clone https://github.com/openkmip/pykmip.git

WORKDIR /code/pykmip

RUN python3 setup.py install

WORKDIR /code

COPY server.conf .

RUN openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /code/selfsigned.key -out \
 /code/selfsigned.crt -subj "/C=SG/ST=Singapore/L=Singapore/O=local/CN=www.example.com"

# command to run on container start
CMD [ "/usr/bin/python3", "pykmip/bin/run_server.py","-f" , "server.conf" ]
#CMD [ "ls", "-lah"]
