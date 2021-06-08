#!/bin/bash

for i in `cat FlavorData.json| jq -M '.["All"][]' | tr -d '"' | tr ' ' '-'`; do
  filename=`echo -n $i | tr '-' ' '`;
  if [ ! -f "./web/static/img/${filename}.jpeg" ] && [ ! -f "./web/static/img/${filename}Icon.jpeg" ]; then
     echo $filename
  fi
done
