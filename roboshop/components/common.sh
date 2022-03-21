STATCHECK() {
if [ $1 -eq 0 ]; then
  echo -e "\e[32mSUCCESS\e[0m"
  else
  echo -e "\e[31mFAILURE\e[0m"
  exit 2
fi
}

Print() {
  echo -e "\n----------$1----------" &>>$LOG_FILE
  echo -e "\e[35m $1 \e[0m"
}

USER_ID=$(id -u)
if [ "$USER_ID" -ne 0 ]; then
  echo You Should run your script as sudo or root user
  exit 1
fi

LOG_FILE=/tmp/roboshop.log
rm -f $LOG_FILE

APP_USER=roboshop

NODEJS() {
 Print "Configure yum repos"
 curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash - &>>${LOG_FILE}
 STATCHECK $?

 Print "Install Nodejs"
 yum install nodejs gcc-c++ -y &>>${LOG_FILE}
 STATCHECK $?

 id ${APP_USER} &>>${LOG_FILE}
 if [ $? -ne 0 ]; then
   Print "Add Application user"
   useradd ${APP_USER} &>>${LOG_FILE}
 fi
 STATCHECK $?

 Print "Download App content"
 curl -f -s -L -o /tmp/${COMPONENT}.zip "https://github.com/roboshop-devops-project/${COMPONENT}/archive/main.zip" &>>${LOG_FILE}
 STATCHECK $?

 Print "Cleanup old content"
 rm -rf /home/${APP_USER}/${COMPONENT} &>>${LOG_FILE}
 STATCHECK $?

 Print "Extract App Content "
 cd /home/${APP_USER} &>>${LOG_FILE} && unzip -o /tmp/${COMPONENT}.zip &>>${LOG_FILE} && mv ${COMPONENT}-main ${COMPONENT} &>>${LOG_FILE}
 STATCHECK $?

 Print "Install App Dependencies"
 cd /home/${APP_USER}/${COMPONENT} &>>${LOG_FILE} && npm install &>>${LOG_FILE}
 STATCHECK $?

 Print "Fix App User Persmissions"
 chown -R ${APP_USER}:${APP_USER} /home/${APP_USER}
 STATCHECK $?

Print "setup systemd file"
sed -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/'
/home/roboshop/${COMPONENT}/systemd.service &>>${LOG_FILE} && mv /home/roboshop/${COMPONENT}/systemd.service /etc/systemd/system/${COMPONENT}.service &>>${LOG_FILE}
STATCHECK $?

Print "restart ${COMPONENT} Service"
systemctl daemon-reload &>>${LOG_FILE} && systemctl restart ${COMPONENT} &>>${LOG_FILE} && systemctl enable ${COMPONENT} &>>${LOG_FILE}
STATCHECK $?
}