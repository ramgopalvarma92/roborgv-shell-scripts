
source components/common.sh
checkRootUser

ECHO "Installing Nginx"
yum install nginx -y &>>${LOG_FILE}
statusCheck $?

ECHO "Downloading Frontend Code"
curl -s -L -o /tmp/frontend.zip "https://github.com/roboshop-devops-project/frontend/archive/main.zip" &>>${LOG_FILE}
statusCheck $?

cd /usr/share/nginx/html

ECHO "Removing Old Files"
rm -rf * &>>${LOG_FILE}
statusCheck $?

ECHO "Extracting Zip Content"
unzip /tmp/frontend.zip &>>${LOG_FILE}
statusCheck $?

ECHO "Copying extracted Content"
mv frontend-main/* . &>>${LOG_FILE} && mv static/* . &>>${LOG_FILE} && rm -rf frontend-main README.md &>>${LOG_FILE}
statusCheck $?

ECHO "Copy RoboShop Nginx Config"
mv localhost.conf /etc/nginx/default.d/roboshop.conf &>>${LOG_FILE}
statusCheck $?

ECHO "Update Nginx Configuration"
for component in catalogue user cart shipping payment ; do
  ECHO "Update Configuration for ${component}"
  sed -i -e "/${component}/ s/localhost/${component}.roboshop.internal/"  /etc/nginx/default.d/roboshop.conf
  statusCheck $?
done

ECHO "Start Nginx Service"
systemctl enable nginx &>>${LOG_FILE} && systemctl restart nginx &>>${LOG_FILE}
statusCheck $?

