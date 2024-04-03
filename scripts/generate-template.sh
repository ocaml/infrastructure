#!/bin/bash

# Script to quickly generate a template for a new machine
# NOTE: The script needs to be run on the machine

# Get system information
hostname=$(hostname)
ip=$(hostname -I | awk '{print $1}')
fqdn=$(hostname --fqdn)
model=$(dmidecode -s system-product-name)
processor=$(grep -m 1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ *//')
memory=$(free -mh | awk '/^Mem:/{print $2"B"}')
disks=$(lsblk -d -n -o NAME,SIZE | grep -v '^loop' | awk '{print "  - "$1": "$2"B"}')
os=$(lsb_release -d | cut -f2)
threads=$(grep -c ^processor /proc/cpuinfo)
location="TODO: Caelum"
notes="TODO: User visible description"
serial=$(dmidecode -s system-serial-number)
ssh="${USER}@${fqdn}"
use="TODO: use?"
service="TODO: service name?"

# Create the template
template=$(cat <<EOF
---
name: $hostname
ip: $ip
fqdn: $fqdn
model: $model
processor: $processor
memory: $memory
disks:
$disks
os: $os
threads: $threads
location: $location
notes: $notes
serial: $serial
ssh: $ssh
use: $use
service: $service
---
{% include details.html %}
EOF
)

# Write the template to a file
echo "$template" > "${hostname}.md"

echo "Template saved as ${hostname}.md"
