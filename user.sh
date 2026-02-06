#!/bin/bash
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/roboshop-shell"
SCRIPT_PATH=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_PATH.log"
SCRIPT_DIR=$PWD
mkdir -p $LOGS_FOLDER
echo "$LOG_FILE"

echo "script execution start time: $(date)" | tee -a $LOG_FILE
START_TIME=$(date +%s)

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo -e "$R RUn with super user $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$R installation failure $N"
    else
        echo -e "$G $2 .. success $N"
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "DISABLED NODEJS"
dnf module enable nodjs:20 -y &>>$LOG_FILE
VALIDATE $? "ENABLING NODEJS"
dnf install nodejs -y  &>>$LOG_FILE
VALIDATE $? "Installed nodejs"

id roboshop
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "system user created"
else
    echo -e "$R USER ALREADY CREATED $N"
fi

mkdir -p  /app
VALIDATE $? "APP DIRECTORY CREATED" 


curl -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user-v3.zip &>>$LOG_FILE
VALIDATE $? "code data to temp"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "OLD CODE REMOVED"

cd /app
VALIDATE $? " MOVED TO APP PATH"
unzip /tmp/user.zip
VALIDATE $? "CODE MOVED TO MAIN PATH"

cd /app
VALIDATE $? " MOVED TO APP PATH"
npm install
VALIDATE $? "DEPENDENCIES INSTALLED"

cp $SCRIPT_DIR/user.service /etc/systemd/system/user.service
VALIDATE $? "SYSTEMCTL SERVICE ENABLED"

sytemctl daemon-reload
VALIDATE $? "USER RELOADED"

systemctl enable user
VALIDATE $? "USER ENABLED"

systemctl start user 
VALIDATE $? "USER STARTED"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo "total execction time :$TOTAL_TIME"




