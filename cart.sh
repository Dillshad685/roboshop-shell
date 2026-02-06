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
        exit 1
    else
        echo -e "$G $2 .. success $N"
    fi
}

dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "DISABLED NODEJS"
dnf module enable nodejs:20 -y &>>$LOG_FILE
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


curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOG_FILE
VALIDATE $? "code data to temp"

rm -rf /app/* &>>$LOG_FILE
VALIDATE $? "OLD CODE REMOVED"

cd /app
VALIDATE $? " MOVED TO APP PATH"
unzip /tmp/cart.zip
VALIDATE $? "CODE MOVED TO MAIN PATH"

cd /app
VALIDATE $? " MOVED TO APP PATH"
npm install
VALIDATE $? "DEPENDENCIES INSTALLED"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "SYSTEMCTL SERVICE ENABLED"

systemctl daemon-reload
VALIDATE $? "cart RELOADED"

systemctl enable cart
VALIDATE $? "cart ENABLED"

systemctl start cart 
VALIDATE $? "cart STARTED"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))

echo "total execction time :$TOTAL_TIME"




