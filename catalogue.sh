#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"


LOGS_FOLDER="/var/log/roboshop-shell"
echo "$0"
SCRIPT_NAME=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD
mkdir -p $LOGS_FOLDER
echo "log file path: $LOG_FILE"
echo "Script started executing from $(date)" | tee -a $LOG_FILE 

USERID=$(id -u) 
if [ $USERID -ne 0 ]; then
    echo "run with super user"
    exit 1
fi 

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$R installation failed $N"
        exit 1
    else
        echo -e "$G $2... success $N"
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "DISABLING"
dnf module enable nodejs:20 -y  &>>$LOG_FILE
VALIDATE $? "ENABLING"
dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "installing nodejs"



id roboshop 
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>LOG_FILE
    VALIDATE $? "USER CREATED"
else
    echo -e "user already exist $Y SKIPPING $N"
fi


mkdir -p /app
VALIDATE $? "DIRECTORY CREATED"

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "copied to zip"

cd /app &>>$LOG_FILE
VALIDATE $? "moved to app direc"
rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "REMOVED OLD CODE"
cd /app 
VALIDATE $? "moved to app direc"
unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "Unzip code"
cd /app 
VALIDATE $? "moved to app direc"
npm install &>>$LOG_FILE
VALIDATE $? "dependencie isntalled"
cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service 
VALIDATE $? "cpied"
systemctl daemon-reload 
VALIDATE $? "RELOAD"
systemctl enable catalogue 
VALIDATE $? "enabled"
systemctl start catalogue
VALIDATE $? "started"

echo -e "catalogue application deployment $G success $N"



cp $SCRIPT_DIR/mongodb.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "mongo repo client installed"
dnf install mongodb-mogosh -y &>>LOG_FILE
VALIDATE $? "mongo repo installed"

INDEX=$(mongosh mongodb.dillshad.space --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
if [ $INDEX -le 0 ]; then
    mongosh --host mongodb.dillshad.space </app/db/master-data.js
    VALIDATE $? "mongo db installed"
else
    echo -e "products already present $Y SKIPPING $N"
    VALIDATE $? "mongo db installed"
fi

systemctl restart catalogue &>>LOG_FILE
VALIDATE $? "mongo db restarted"