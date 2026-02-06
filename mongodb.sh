#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


LOGS_FOLDER="/var/log/roboshop-shell"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"

mkdir -p $LOGS_FOLDER
echo $LOG_FILE

echo -e "script execution start time : $(date +%s)" | tee -a $LOG_FILE
USERID=$(id -u)

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


cp mongodb.repo /etc/yum.repos.d/mongodb.repo  
VALIDATE $? "copied"

dnf install mongodb-org  -y  
VALIDATE $? "mongodb installed"

systemctl enable mongod  
VALIDATE $? "ENABLING mongodb"

systemctl start mongod  
VALIDATE $? "started mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "allowing all ports" #using sed we can insert in the file 

systemctl restart mongod
VALIDATE $? "restarting mongoDB"
