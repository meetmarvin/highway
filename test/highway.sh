#!/bin/bash

printf "=================================\nCheck Docker Installation\n\n"

# Check docker installation

if [[ $(which docker) && $(docker --version) ]]; then
    docker --version | grep version
    printf "\nDocker installed.\n"

    printf "\nTest Docker installation...\n"
    docker run hello-world > /dev/null

    if [ $? -eq 0 ]; then
        printf "\nDocker working properly.\n"
    else
        printf "\nDocker not working properly. Make sure it is working properly before running this script.\n\n"
        exit 0
    fi

  else
    printf "Docker is currently not installed.\n\nInstall it first before running this script.\n\nSee https://docs.docker.com/install/\n\n"
    exit 0
fi

printf "\n=================================\nDocker Login\n\nLog in to docker.atlnz.lc\n\n"

# Login

until docker login docker.atlnz.lc
do
  printf "\nLog in to docker.atlnz.lc\n\n"
done

printf "\n=================================\nCheck Existing Container\n\n"

printf "Stopping any existing highway container...\n"
# Todo - check if highway is running
docker rm -vf highway >/dev/null

printf "Done.\n"

printf "\n=================================\nPull Docker Image\n\n"

# Pull and run the image with name 'highway' and add volume
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

  # Get and validate MAC address
  while true;
  do
    read -p 'Enter device MAC address (xx:xx:xx:xx:xx:xx): ' mac
    if [ `echo $mac | egrep "^([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}$"` ]
    then
        break
      else
        printf "Invalid MAC address. Please try again.\n\n"
      fi
  done

  # Get and validate serial number
  while true;
  do
    read -p 'Enter device serial number: ' serial
    if [ $(echo ${#serial}) -eq 16 ]
    then
        break
      else
        printf "Invalid Serial number. Please try again.\n\n"
      fi
  done

  # Create certificate from container.
  printf "\nGenerating certificate...\n"
  docker exec -it --user=root highway rake highway:signmic EUI64=$mac PRODUCTID=$serial >/dev/null

  # Remove colon and make uppercase
  mac="$( echo $mac | sed -e 's/://g' | awk '{print toupper($0)}' )"

  # Change permission to current user
  sudo chown -R $USER $DIR/$mac

  # Prompt user where to get the certificate
  printf "Done.\n\nFiles saved to $DIR/$mac\n\n"

  # Ask user to generate another certificate
  read -r -p "Generate another certificate? [y/n] " response
  if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]
  then
      printf "\n=================================\nGenerate Device Certificate\n\n"
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
