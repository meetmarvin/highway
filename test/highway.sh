#!/bin/bash

printf "=================================\nCheck Docker Installation\n\n"

# Check docker installation

if [[ $(which docker) && $(docker --version) ]]; then
    docker --version | grep version
    printf "\nDocker installed.\n"

    printf "\nTest Docker installation\n\n'docker run hello-world'\n"
    docker run hello-world

    if [ $? -eq 0 ]; then
        printf "Docker working properly.\n"
    else
        printf "\nDocker not working properly. Make sure it is working properly before running this script.\n\n"
        exit 0
    fi

  else
    printf "Docker is currently not installed.\n\nInstall it first before running this script.\n\nSee https://docs.docker.com/install/\n\n"
    exit 0
fi

printf "\n=================================\nDocker Login\n\nLog in to docker.atlnz.lc\n\n"

# Todo - check login status

# Login to docker
docker login docker.atlnz.lc

printf "\n=================================\nCheck Existing Container\n\n"

printf "Stopping any existing highway container...\n"
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
  printf "Done.\n\nFiles saved to $DIR/$mac\n\n"

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
# Stop container
docker rm -vf highway >/dev/null

printf "Done.\n"

printf "\n=================================\nDocker Logout\n\n"

# Logout
docker logout docker.atlnz.lc
