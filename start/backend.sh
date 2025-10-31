#!/bin/sh
cd /home/project/source 

echo "PROJECT_SHELL_MODE=$PROJECT_SHELL_MODE"

# Load secrets file.
set -a 
source /run/secrets/.env.secrets 
set +a

# Determine which mode to run.
if [ "$PROJECT_SHELL_MODE" = "cli" ] ; then
    echo "CLI mode active..."
    sleep infinity
elif [ "$PROJECT_SHELL_MODE" = "main" ] ; then
    echo "Running dev server..."
    HOST=0.0.0.0 PORT=80 node ace serve --hmr 
else 
    echo "Unknown CLI mode..."
fi 