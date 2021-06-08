# Python
MAIN_NAME=dev.py
ENV_NAME=venv
PYTHON_VERSION=`which python3`

# Docker
DOCKER_IMAGE_NAME=flasq
DOCKER_OPTIONS=--rm -it -p 5000:5000
DOCKER=docker
DOCKER_COMPOSE=docker-compose

.PHONY: all deploy buildall build buildbase rund killd setup cun cleand

all: build rund 
buildall: buildbase build

############################################################
#      _            _                   _          __  __  #
#   __| | ___   ___| | _____ _ __   ___| |_ _   _ / _|/ _| #
#  / _` |/ _ \ / __| |/ / _ \ '__| / __| __| | | | |_| |_  #
# | (_| | (_) | (__|   <  __/ |    \__ \ |_| |_| |  _|  _| #
#  \__,_|\___/ \___|_|\_\___|_|    |___/\__|\__,_|_| |_|   #
#                                                          #
############################################################

deploy:
	if [ -n "`docker image list -q | nice grep jmc1283/flasq-base`" ]; then \
		${DOCKER} pull jmc1283/flasq-base; \
	fi
	${DOCKER_COMPOSE} kill
	${DOCKER_COMPOSE} rm -f
	${DOCKER_COMPOSE} up --build -d

build:
	if [ -n "`docker image list -q | nice grep jmc1283/flasq-base`" ]; then \
		${DOCKER} pull jmc1283/flasq-base; \
	fi
	${DOCKER} build -t ${DOCKER_IMAGE_NAME} .

buildbase:
	${DOCKER} build -t jmc1283/flasq-base base

rund: killd
	${DOCKER} run ${DOCKER_OPTIONS} --name ${DOCKER_IMAGE_NAME} ${DOCKER_IMAGE_NAME}

cleand: killd
	echo 'y' | ${DOCKER} system prune
	if [ -n "`${DOCKER} image list -q | grep ${DOCKER_IMAGE_NAME}`" ]; then \
		${DOCKER} rmi ${DOCKER_IMAGE_NAME}; \
		${DOCKER} rmi jmc1283/flasq-base; \
	fi

killd:
	if [ -z "$(${DOCKER} ps -q) | grep ${DOCKER_IMAGE_NAME}" ]; then \
		${DOCKER} kill ${DOCKER_IMAGE_NAME}; \
	fi



##########################################################
#      _      _                       _          __  __  #
#   __| | ___| |__  _   _  __ _   ___| |_ _   _ / _|/ _| #
#  / _` |/ _ \ '_ \| | | |/ _` | / __| __| | | | |_| |_  #
# | (_| |  __/ |_) | |_| | (_| | \__ \ |_| |_| |  _|  _| #
#  \__,_|\___|_.__/ \__,_|\__, | |___/\__|\__,_|_| |_|   #
#                         |___/                          #
#							 #
##########################################################

setup:
	if [ -d ${ENV_NAME} ]; then \
		rm -rf ${ENV_NAME}; \
	fi
	if [ -a base/requirements.txt ]; then \
		touch base/requirements.txt; \
	fi
	which virtualenv && pip install virtualenv || true
	virtualenv -p ${PYTHON_VERSION} ${ENV_NAME}
	./${ENV_NAME}/bin/pip install -r base/requirements.txt

run: 
	if [ ! -d ${ENV_NAME} ]; then \
		make setup; \
	fi
	./${ENV_NAME}/bin/python ${MAIN_NAME}

clean:
	if [ -d ${ENV_NAME} ]; then \
		rm -rf ${ENV_NAME}; \
	fi
	if [ -n "`find . -name __pycache__`" ]; then \
		rm -rf `find . -name __pycache__`; \
	fi
