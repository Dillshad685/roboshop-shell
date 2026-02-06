#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\n[33m"
N="\n[0m"

LOGS_FOLDER="/var/log/roboshop-shell"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo "$LOG_FILE"
echo -e "script execution start time: $(date)" | tee -a &LOG_FILE
START_TIME=$(date +%s)

USERID=$(id -u)

if [ $(USERID) -ne 0 ]; then
    echo -e "$R run with super user $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$R installation failed $N"
    else
        echo -e "$G $2 ... success" 
    fi
}

dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "DISABLING REDIS"
dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "ENABLING REDIS" 
dnf install redis -y &>>$LOG_FILE
VALIDATE $? "INSTALLING REDIS"
sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "ports are enabled"

systemctl enable redis &>>$LOG_FILE
VALIDATE $? "ENABLING REDIS"
systemctl start redis  &>>$LOG_FILE
VALIDATE $? "STARTING REDIS"
END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME-$START_TIME ))
echo "script executed in $TOTAL_TIME SEC"