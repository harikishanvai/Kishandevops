#!/bin/bash

source components/common.sh

Print "Setup YUM Repos"
curl -L https://raw.githubusercontent.com/roboshop-devops-project/redis/main/redis.repo -o /etc/yum.repos.d/redis.repo &>>${LOG_FILE}
STATCHECK $?

Print "Install Redis"
# yum install redis -y &>>${LOG_FILE}
STATCHECK $?

Print "Update Redis config"
if [ -f /etc/redis/conf ]; then
  sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis/conf
fi
if [ -f /etc/redis/redis.conf ]; then
  sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis/redis.conf
fi
STATCHECK $?

Print "Start Redis Service"
systemctl enable redis &>>${LOG_FILE} && systemctl start redis &>>${LOG_FILE}
STATCHECK $?
