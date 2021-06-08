#!/bin/bash


cd $(dirname $(realpath $0))

docker-compose up -d --build --force-recreate
