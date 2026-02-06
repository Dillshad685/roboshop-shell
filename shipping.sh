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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "JAVA INSTALLED"

id roboshop 
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
else
    echo -e "$Y USER ALREADY EXIST $N'
fi

