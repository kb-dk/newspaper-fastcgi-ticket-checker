#!/bin/bash

PROJECT=$1

BASE_URL="http://image-server.$PROJECT..svc.cluster.local"


HTTP_CODE=${curl -sS -w '{http_code}\n' -o /tmp/content $BASE_URL/tv-thumbnail/371157ee-b120-4504-bfaf-364c15a4137c?ticket=3d2bda8b-8b7c-47e9-85ce-f42d2e4fc12d}

echo $HTTP_CODE

if [ $HTTP_CODE -ne "200" ]
then
    echo "Http response code was not 200, good case test failed"
    exit 1
fi


