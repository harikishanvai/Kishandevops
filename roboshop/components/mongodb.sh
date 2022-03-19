#!/bin/bash

source components/common.sh

Print " Setup YUM Repos"
curl -s -o /etc/yum.repos.d/mongodb.repo https://raw.githubusercontent.com/roboshop-devops-project/mongodb/main/mongo.repo &>>$LOG_FILE
STATCHECK $?

Print "Install MongoDB"
yum install -y mongodb-org &>>$LOG_FILE
STATCHECK $?

Print "Update MongoDB Listen Address"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf
STATCHECK $?

Print "Start MondoDB"
systemctl enable mongod &>>$LOG_FILE && systemctl restart mongod &>>$LOG_FILE
STATCHECK $?


