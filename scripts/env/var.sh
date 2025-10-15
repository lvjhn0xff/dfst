#!/bin/bash
source .env
VAR_TO_PRINT=$1
echo "${!VAR_TO_PRINT}"
