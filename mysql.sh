#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

# echo "Please enter DB password"
# read -s mysql_root_password
mysql_root_password = ExpenseApp@1

if [ $USERID -ne 0 ]
then
   echo "Please run this script with root access"
   exit 1
else
   echo "You are super user."
fi

VALIDATE(){
if [ $1 -ne 0 ]
then
   echo -e "$2... $R FAILURE $N"
   exit 1
else
   echo -e "$2... $G SUCCESS $N"
fi
}

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing of MySQL Server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling of MySQL Server"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting the MySQL server"

# mysql_secure_installation --set-root-pass ExpenseApp@1 &>>$LOGFILE
# VALIDATE $? "Setting up Root Password"

mysql -h db.lithesh.shop -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ] 
then
   mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
   VALIDATE $? "MySQL Root password setup done"
else
   echo -e "MySQL Root password is already setup...$Y SKIPPING $N"
fi

