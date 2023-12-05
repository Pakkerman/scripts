#!/bin/bash

# this script is to sent dev sever ip to phone using ntfy.sh
# to use this create .env and set NTFY_TOPIC="your ntfy topic"

source .env
# getting broadcasting ip
ip=$(ifconfig | grep "inet\s.*netmask.*broadcast" | awk '{print $2}')

curl -d "
Dev sever ready at:
$ip:3000
make sure you are on the same wifi
" \
"ntfy.sh/$NTFY_TOPIC"
