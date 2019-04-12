#!/bin/bash

printf "=================================\nCheck Docker Installation\n\n"

# Check docker installation
docker --version >> /dev/null

if [ $? -eq 0 ]
then
    docker --version | grep "Docker version"
    if [ $? -eq 0 ]
    then
        printf "Docker installed.\n"
    else
        printf "Docker is currently not installed. Please install it first before running the script.\n\nhttps://docs.docker.com/install/\n\n"
        exit 0
    fi
else
    exit 0
fi

printf "\n=================================\nDocker Login\n\nLog in to docker.atlnz.lc\n\n"

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

docker pull docker.atlnz.lc/marvint/highway

printf "Done.\n"

printf "\n=================================\nRun Docker Image\n\nRunning docker image..."

# Get the source directory of a Bash script from within the script itself
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Detached run the image with container name 'highway' and mount volume to source directory of script
docker run --name highway -td -v $DIR:/root/highway/db/devices docker.atlnz.lc/marvint/highway /bin/bash

printf "Done.\n"

printf "\n=================================\nGenerate Device Certificate\n\n"

while true;
do

  # Get MAC address. # Todo - Validation and allow AW+ 'show system mac' format
  # 001a.eb93.7b1e
  read -p 'Enter device MAC address (xx:xx:xx:xx:xx:xx): ' mac

  # Get Serial Number. Todo - Must be 16 digits
  read -p 'Enter device serial number: ' serial

  # Create certificate from container.
  printf "\nGenerating certificate...\n"
  docker exec -it --user=root highway rake highway:signmic EUI64=$mac PRODUCTID=$serial >/dev/null

  # Prompt user where to get the certificate.
  printf "Done.\n\nFiles saved to $DIR\n\n"

  # Ask user to generate another certificate.
  read -r -p "Generate another certificate? [y/n] " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
  then
      printf "\n ------- \n"
    else
      break
    fi
done

printf "\nStopping highway container...\n"
# Todo - check if highway is running
docker rm -vf highway >/dev/null

printf "Done.\n"

printf "\n=================================\nDocker Logout\n\n"

# Logout
docker logout docker.atlnz.lc
