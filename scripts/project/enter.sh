#!/bin/bash
cd $PROJECT_PATH
PROJECT_RAW_CLI="true" bash docker-compose up -d $1 > /dev/null 2>&1
bash docker-compose exec -e PROJECT_RAW_CLI="true" -it $1 sh