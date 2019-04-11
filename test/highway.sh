#!/bin/bash

# Todo - Check if docker is installed

# Login to docker. Todo - add URL
docker login

# Todo - check if highwayd is running
docker rm -vf highwayd

# Pull and run the image with name 'highwayd' and add volume. Todo - Need to update the directory (/tmp)
docker pull meetmarvin/highway && docker run --name highwayd -td -v /tmp:/root/highway/db/devices meetmarvin/highway /bin/bash

# Get MAC address. # Todo - Validation and allow AW+ 'show system mac' format
read -p 'Enter device MAC address (xx:xx:xx:xx:xx:xx): ' mac

# Get Serial Number. Todo - Validation by length
read -p 'Enter device serial number: ' serial

# Create certificate from container
docker exec -it --user=root highwayd rake highway:signmic EUI64=$mac PRODUCTID=$serial

# Prompt user where to get the certificate. Todo - Need to update the directory (/tmp)
echo 'Check /tmp'

# Todo - Ask if user will create another cert. If yes, go back to line 18

# Stop container and remove volume
docker rm -vf highwayd

# Todo - logout user
docker logout
