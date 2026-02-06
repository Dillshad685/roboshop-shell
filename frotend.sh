
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/roboshop-shell"
SCRIPT_PATH=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_PATH.log"
mkdir -p $LOGS_FOLDER

echo "script started exectting at $(date)" | tee -a &LOG_FILE
START_TIME=$(date +%s)

USER_ID=$(id -u)
if [ $USER_ID -ne 0 ]; then
    echo -e "$R run with super user $N"
    exit 1
fi

VALIDATE(){
    if [ $1 -ne 0 ]; then
        echo -e "$R $1.. installation failed $N"
    else
        echo -e "$G $2 .. SUCCESS $N"
    fi
}

dnf disable nginx -y &>>$LOG_FIILE
VALIDATE $? "DISABLING NGINX"
