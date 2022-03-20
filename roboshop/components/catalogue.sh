#!/bin/bash

source components/common.sh

Print "Configure YUM repos"
curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash - &>>${LOG_FILE}
STATCHECK $?

Print "Install Nodejs"
yum install nodejs gcc-c++ -y &>>${LOG_FILE}

id ${APP_USER} &>>${LOG_FILE}
if [ $? -ne 0 ]; then
  Print "Add Application user"
  useradd ${APP_USER} &>>${LOG_FILE}
fi
STATCHECK $?

Print "Download App content"
curl -f -s -L -o /tmp/catalogue.zip "https://github.com/roboshop-devops-project/catalogue/archive/main.zip" &>>${LOG_FILE}
STATCHECK $?

Print "Cleanup old content"
rm -rf /home/${APP_USER}/catalogue &>>${LOG_FILE}
STATCHECK $?

Print "Extract App Content "
cd /home/${APP_USER} &>>${LOG_FILE} && unzip -o /tmp/catalogue.zip &>>${LOG_FILE} && mv catalogue-main catalogue &>>${LOG_FILE}
STATCHECK $?

Print "Install App Dependencies"
cd /home/${APP_USER}/catalogue &>>${LOG_FILE} && npm install &>>${LOG_FILE}
STATCHECK $?

Print "Fix App User Persmissions"
chown -R ${APP_USER}:${APP_USER} /home/${APP_USER}
STATCHECK $?

Print "setup systemd file"
sed -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/'
/home/roboshop/catalogue/systemd.service &>>${LOG_FILE} && mv /home/roboshop/catalogue/systemd.service /etc/systemd/system/catalogue.service &>>${LOG_FILE}
STATCHECK $?

Print "restart Catalogue Service"
systemctl daemon-reload &>>${LOG_FILE} && systemctl restart catalogue &>>${LOG_FILE} && systemctl enable catalogue &>>${LOG_FILE}
STATCHECK $?
