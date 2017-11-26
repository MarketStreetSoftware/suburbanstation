#!/bin/sh
#setup.sh

#Detect docker service, then exit if dockerd is not running.
servicedocker="[/]dockerd"
if ps aux | grep  "$servicedocker"; then
    echo "Docker is running"
else
    echo "Docker is not running"
    echo "Please install Docker: sudo apt install docker.io\n\n"
    echo "https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-16-04"
    exit
fi

#Setup dynamodb
file=./dynamodb_local_latest.tar.gz
if [ -e "$file" ]; then
    echo "File $file exists"
else
    echo "\n\nFile $file does not exist, downloading from repo storage.\n\n"
    wget https://s3.ap-south-1.amazonaws.com/dynamodb-local-mumbai/dynamodb_local_latest.tar.gz
fi


service="[.]/DynamoDBLocal"
if ps aux | grep  "$service"; then
    echo "running"
else
    echo "not running"
    dr=./dynamodb
    if [ -e "$dr" ]; then
        echo "Directory $dr exists"
        cd dynamodb
        java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb -port 8000 &
        cd ..
    else
        echo "Directory does not exist"
        mkdir dynamodb
        tar -zxvf $file -C ./dynamodb
        cd dynamodb
        java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb -port 8000 &
        cd ..
    fi
fi


#
#clone diagnostic
dr=../inventory
if [ -e "$dr" ]; then
  echo "Directory $dr exists"
else
  echo "Directory $dr does not exists"
  cd ..
  git clone https://github.com/MarketStreetSoftware/inventory
fi

cd inventory
./gradlew clean build -x test
if ps aux | grep  "$servicedocker"; then
    echo "Docker is running"
#    ./gradlew buildDocker -x itest
fi
cd ..
