#!/bin/bash

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/roboshop-shell"
SCRIPT_PATH="$( echo $0 | cut -d "." -f1 )"
LOG_FILE="$LOGS_FOLDER/$SCRIPT_PATH.log"
mkdir -p $LOGS_FOLDER
echo "$LOG_FILE"

echo  "script execution start time: $(date)" | tee -a $LOG_FILE
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

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "installed python"

id roboshop &>>$LOG_FILE 
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop
    VALIDATE $? "SYSTEMUSER created"
else
    echo -e "system user already created .. $Y SKIPPING $N"
fi

mkdir -p /app &>>$LOG_FILE
VALIDATE $? "app directory created"

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip 
VALIDATE $? "payment file created"

cd /app &>>$LOG_FILE
VALIDATE $? "moved to app directory"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "remove code"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "MOVED TO TEMP"

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "installed packages"

cp $SCRIPT_DIR/payment.service /etc/systemd/system/payment.service &>>$LOG_FILE
VALIDATE $? "systemctl service enabled"

systemctl daemon-reload &>>$LOG_FILE
VALIDATE $? "PAYMENT reloaded"

systemctl enable payment &>>$LOG_FILE
VALIDATE $? "ENABLED payment"

systemctl start payment &>>$LOG_FILE
VALIDATE $? "Started payment"