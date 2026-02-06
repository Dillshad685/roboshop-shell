#!/bin/bash

R="\e[31m"
G="\n[32m"
Y="\n[33m"
N="\n[0m"

LOGS_FOLDER="/var/log/roboshop-shell"
SCRIPT_PATH="$( echo $0 | cut -d "." -f1 )"
LOGS_FOLDER="$LOGS_FOLDER/$SCRIPT_PATH.log"
mkdir -p $LOGS_FOLDER

echo "script execution start time: $(date)" | tee -a $LOG_FILE
START_TIME=$(date +%s)

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo -e "$R run with super user $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e  "$R $1 .. failed"
        exit 1
    else
        echo -e "$G $2 ... SUCCESS"
    fi
}

cp rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOG_FILE
VALIDATE $? "copied to repo"
dnf install rabbitmq-server -y  &>>$LOG_FILE
VALIDATE $? "installed rabbitmq"
systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "enabling rabbitmq"
systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "start rabbitmq"

rabbitmqctl add_user roboshop roboshop123 &>>$LOG_FILE
VALIDATE $? "root pwd set"
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE
VALIDATE $? "permissions given"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo "script executed in $TOTAL_TIME seconds
