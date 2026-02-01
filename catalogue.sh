# To create catalogue service through automation

#!/bin/bash

#=========================== to add colors =========================================#
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

#======================= to create log file ========================================#

LOG_FOLDER="/var/log/roboshop-shell"
echo "$0"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_FOLDER/$SCRIPT_NAME.log"
SCRIPT_DIR=$PWD
mkdir -p $LOG_FOLDER  &>>$LOG_FILE
echo $?
echo "log file path: $LOG_FILE"
echo "Script started executing from $(date)" | tee -a $LOG_FILE 

USERID=$(id -u) 
if [ $USERID -ne 0 ]; then
    echo "run with super user"
    exit 1
fi 


#============nodejs====================#

dnf module disable nodejs -y &>>$LOG_FILE
dnf module enable nodejs:20 -y  &>>$LOG_FILE
dnf install nodejs -y &>>$LOG_FILE
echo -e "installing nodejs is $G success $N"

# #===========user creation===============#
# id roboshop 
# if [ $? -ne 0 ]; then
#     useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop  &>>LOG_FILE
# else
#     echo -e "user already exist $Y SKIPPING $N"
# fi

# #==================APPLICATION SETUP===============================#
# mkdir -p /app
# curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
# cd /app &>>$LOG_FILE
# rm -rf /app/* &>>$LOG_FILE
# cd /app 
# unzip /tmp/catalogue.zip 
# cd /app 
# npm install &>>$LOG_FILE
# cp $SCRIPT_DIR/catalogue.service /etc/systemd/system/catalogue.service 
# systemctl daemon-reload 
# systemctl enable catalogue 
# systemctl start catalogue 
# echo -e "catalogue application deployment $G success $N"

# #=============================MONGO DB SETUP=============================#

# cp $SCRIPT_DIR/mongodb.service /etc/yum.repos.d/mongo.repo
# dnf install mongodb-mogosh -y &>>LOG_FILE
# INDEX=$(mongosh mongodb.dillshad.space --quiet --eval "db.getMongo().getDBNames().indexOf('catalogue')")
# if [ $INDEX -le 0 ]; then
#     mongosh --host mongodb.dillshad.space </app/db/master-data.js
# else
#     echo -e "products already present $Y SKIPPING $N"
# fi

# systemctl restart catalogue &>>LOG_FILE