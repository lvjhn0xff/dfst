#!/bin/bash

# Load configuration.
echo "Loading configuration..."
source .env 

# Creating data directory for user. 
echo "Removing data directory for user...."
rm -rf ${DFST_DATA_DIR}

# Program finished. 
echo "Done."
