#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


LOGS_FOLDER="/var/log/roboshop-shell"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log
mkdir -p $LOGS_FOLDER
echo $LOG_FILE

echo "script execution start time : $( date +%s) | tee -a $LOG_FILE
USERID=$( id -u)

if [ $USERID -ne 0 ]; then
    echo -e "$Y run with super user $N"
    exit 1
fi


VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$R installation failed $N"
    else
        echo -e "$G  $2 ..  success $N"
    fi
}


cp mongodb.repo /etc/yum.repos.d/mongodb.repo &>> $LOG_FILE
VALIDATE $? "copied "

dnf install mongodb-org  -y  &>>$LOG_FILE
VALIDATE $? "mongodb installed"

systemctl enable mongod &>> $LOG_FILE 
VALIDATE $? "ENABLING mongodb"

systemctl start mongod &>> $LOG_FILE
VALIDATE $? "started mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>> $LOG_FILE
VALIDATE $? "config file changed"

systemctl restart mongod &>> $LOG_FILE
VALIDATE $? "restarting mongoDB"


