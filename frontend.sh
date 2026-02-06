
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/roboshop-shell"
SCRIPT_PATH=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_PATH.log"
SCRIPT_DIR=$PWD
mkdir -p $LOGS_FOLDER

echo "script started exectting at $(date)" | tee -a $LOG_FILE
START_TIME=$(date +%s)

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo -e "$R run with super user $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$R $1.. installation failed $N"
        exit 1
    else
        echo -e "$G $2 .. SUCCESS $N"
    fi
}

dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "DISABLING NGINX"
dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "enabling nginx"
dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "INSTALLED NGINX"

rm -rf /usr/share/nginx/html/* &>>$LOG_FILE
VALIDATE $? "removed existing code"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOG_FILE
VALIDATE $? "copied to temp path"
cd /usr/share/nginx/html/ &>>$LOG_FILE
VALIDATE $? "changed to nginx direc"
unzip /tmp/frontend.zip &>>$LOG_FIILE
VALIDATE $? "Unzip code"
rm -rf /etc/nginx/nginx.conf  &>>$LOG_FILE
VALIDATE $? "remove exisitng code"
cp $SCRIPT_DIR/nginx.conf /etc/nginx/nginx.conf &>>$LOG_FILE
VALIDATE $? "add new code"
systemctl restart nginx &>>$LOG_FILE
VALIDATE $? "restart NGINX"
