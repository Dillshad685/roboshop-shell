R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

LOGS_FOLDER="/var/log/roboshop-shell"
SCRIPT_PATH=$( echo $0 | cut -d "." -f1 )
LOG_FILE="$LOGS_FOLDER/$SCRIPT_PATH.log"
MYSQL_HOST="mysql.dillshad.space"
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
    echo -e "$Y USER ALREADY EXIST $N"
fi

mkdir -p /app
VALIDATE $? "APP DIRECTORY CREATED"

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "MOVED TO TEMP PATH"

rm -rf /app/*
VALIDATE $? "REMOVED EXISTING CODE"

cd /app &>>$LOG_FILE
VALIDATE $? "MOVED TO APP DIRECTORY"
unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "UNZIPPED CODE"

cd /app
VALIDATE $? "MOVED TO APP"
mvn clean package  &>>$LOG_FILE
mv target/shipping-1.0.jar shipping.jar
VALIDATE $? "Packagaes are installed"

cp $SCRIPT_DIR/shipping.service /etc/systemd/system/shipping.service &>>$LOG_FILE
VALIDATE $? "ENABLING SYSTEMCTL"

systemctl daemon-reload  &>>$LOG_FILE
VALIDATE $? "SHIPPING RELOADED"

sytemctl enable shipping &>>$LOG_FILE
VALIDATE $? "ENABLED SHIPPING"

sytemctl start shipping &>>$LOG_FILE
VALIDATE $? "started shipping"

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "installed mysql"

mysql -h $MYSQL_HOST -uroot -pRoboShop@1 -e 'use cities' < /app/db/schema.sql &>>$LOG_FILE
if [ $? -ne 0 ]; then
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/schema.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOG_FILE
    mysql -h $MYSQL_HOST -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOG_FILE
else
    echo -e "$Y Mysql data is loaded .. $Y SKIPPING $N"

fi

END_TIME=$(date +%s)
TOTAL_TIME=$(( $END_TIME - $START_TIME ))
echo "script executed in $TOTAL_TIME seconds"