#!/bin/bash

source components/common.sh

Print "Configure YUM repos"
curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash - &>>${LOG_FILE}
STATCHECK $?

Print "Install Nodejs"
yum install nodejs gcc-c++ -y &>>${LOG_FILE}


Print "Add Apllication user"
useradd ${APP_USER} &>>${LOG_FILE}
STATCHECK $?

Print "Download App content"
curl -f -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>${LOG_FILE}
STATCHECK $?

Print "Cleanup old content"
rm -rf /home/${APP_USER}/catalouge &>>${LOG_FILE}
STATCHECK $?

Print "Extract App Content "
cd /home/${APP_USER} &>>${LOG_FILE} && unzip /tmp/catalogue.zip &>>${LOG_FILE} && mv catalogue-main catalogue &>>${LOG_FILE}
STATCHECK $?

Print "Install App Dependencies"
cd /home/${APP_USER}/catalogue &>>${LOG_FILE} && npm install &>>${LOG_FILE}
STATCHECK $?




