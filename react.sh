#!/bin/bash
sudo yum update -y
# install git and curl packages 
sudo yum install -y git curl
# add nodejs yum repository to the system
curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
# install nodejs
sudo yum install -y nodejs
# clone git repo
git clone https://github.com/hothaifa96/node-october.git
# cd to the cloned repo
cd node-october
# checkout to the react-b branch
git checkout react-b
# cd to the relevant folder
cd counters-app
# install npm dependencies
npm i
# fix all found vulnerabilities
npm fix
# start the application
npm start