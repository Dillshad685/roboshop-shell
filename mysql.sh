R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/roboshop-shell"
SCRIPT_PATH=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_PATH.log"
mkdir -p $LOGS_FOLDER
echo "$LOG_FILE"

echo -e "script execution start time : $(date)" | tee -a $LOG_FILE
START_TIME=$(date +%s)

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo -e "$R RUN WITH SUPER USER $N"
    exit 1 
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$R $1.. FAILED $N"
        exit 1
    else
        echo -e "$G $2 .. SUCCESS $N"
    fi
}

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "INSTALLING MYSQL"
systemctl enable mysqld &>>$LOG_FILE
VALIDATE $? "ENABLING MYSQL"
systemctl start mysqld &>>$LOG_FILE
VALIDATE $? "STARTING MYSQL"

mysql_secure_installation --set-root-pass RoboShop@1 &>>$LOG_FILE
VALIDATE $? "root pwd set"

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo "code executed in $TOTAL_TIME seconds"

