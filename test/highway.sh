#!/bin/bash

printf "=================================\nDocker Login\n\nLog in to docker.atlnz.lc\n\n"

# Todo - check login status

# Login to docker
docker login docker.atlnz.lc

printf "\nStopping existing highway container...\n"
# Todo - check if highway is running
docker rm -vf highway >/dev/null

printf "Done.\n"

printf "\n=================================\nPull Docker Image\n\n"

# Pull and run the image with name 'highway' and add volume. Todo - Need to update the directory (/tmp)

printf "Pulling image...\n"

docker pull docker.atlnz.lc/marvint/highway >/dev/null

printf "Done.\n"

printf "\n=================================\nRun Docker Image\n\nRunning docker image..."

# Get the source directory of a Bash script from within the script itself
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Detached run the image with container name 'highway' and mount volume to source directory of script
docker run --name highway -td -v $DIR:/root/highway/db/devices docker.atlnz.lc/marvint/highway /bin/bash

printf "Done.\n"

printf "\n=================================\nGenerate Device Certificate\n\n"

# Get MAC address. # Todo - Validation and allow AW+ 'show system mac' format
read -p 'Enter device MAC address (xx:xx:xx:xx:xx:xx): ' mac

# Get Serial Number. Todo - Validation by length
read -p 'Enter device serial number: ' serial


while true;
do
    read -r -p "Generate another certificate? [y/n] " response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
    then
      # Create certificate from container

      printf "\nGenerating certificate...\n"
      docker exec -it --user=root highway rake highway:signmic EUI64=$mac PRODUCTID=$serial >/dev/null

      # Prompt user where to get the certificate. Todo - Need to update the directory (/tmp)
      printf "Done.\n\nFiles saved to $DIR/$mac\n"
    else
        exit 0
    fi
done

# # Create certificate from container
#
# printf "\nGenerating certificate...\n"
# docker exec -it --user=root highway rake highway:signmic EUI64=$mac PRODUCTID=$serial >/dev/null
#
# # Prompt user where to get the certificate. Todo - Need to update the directory (/tmp)
# printf "Done.\n\nFiles saved to $DIR/$mac\n"

# Todo - Ask if user will create another cert. If yes, go back to line 18

printf "\nStopping highway container...\n"
# Todo - check if highway is running
docker rm -vf highway >/dev/null

printf "Done.\n"

printf "=================================\nDocker Logout\n\n"
docker logout docker.atlnz.lc
