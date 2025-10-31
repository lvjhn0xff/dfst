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
    npm run dev -- --host 0.0.0.0 --port 80
else 
    echo "Unknown CLI mode..."
fi 