#!/bin/bash

# Load configuration.
echo "Loading configuration..."
source .env 

# Creating data directory for user. 
echo "Creating data directory for user...."

mkdir -p ${DFST_DATA_DIR}
mkdir -p ${DFST_DATA_DIR}/dns
mkdir -p ${DFST_DATA_DIR}/dns/mappings
mkdir -p ${DFST_DATA_DIR}/certs 

chown $USER:$USER -R  ${DFST_DATA_DIR}

# Program finished. 
echo "Done."
