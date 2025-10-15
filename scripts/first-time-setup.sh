#!/bin/bash
source .env
bash dfst env user-setup
bash dfst env on 
bash dfst env get-ca 
bash dfst env register-ca