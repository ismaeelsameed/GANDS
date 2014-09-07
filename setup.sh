#!/bin/bash
echo "__________________________________________________________________________________________________"
echo "that was all the input you needed to give, sit back now and wait for the server to initialize ..."
echo "__________________________________________________________________________________________________"
sleep 10
# install the required requirements for any server
sudo apt-get update
sudo apt-get install python-dev <<<y
sudo apt-get install python-pip <<<y
sudo pip install distribute
sudo apt-get install python-setuptools
sudo apt-get install libevent-dev <<<y
sudo apt-get install libfreetype6-dev <<<y
sudo apt-get install libpng-dev
sudo apt-get install python-pandas <<<y
sudo pip install setuptools
sudo pip install ipython
sudo pip install gunicorn
sudo pip install supervisor
sudo apt-get install supervisor <<<y
sudo apt-get install nginx <<<y

# load global variables
. GANDS/GANDS.conf
sudo git clone $PROJECT_GIT_URL
sudo pip install -r $REQUIREMENTS_FILE_PATH
## install the required requirements for the application
#copy gunicorn config file to /usr/local/bin
sudo cp GANDS/gunicorn_config.sh /usr/local/bin
#writing the config file
echo -e '\nNUM_WORKERS='$NUM_WORKERS >> /usr/local/bin/gunicorn_config.sh
echo 'cd '$PROJECT_ROOT_PATH >> /usr/local/bin/gunicorn_config.sh
echo 'test -d $LOGDIR || mkdir -p $LOGDIR' >> /usr/local/bin/gunicorn_config.sh
echo 'DJANGO_SETTINGS_MODULE='$DJANGO_SETTINGS_FILE >> /usr/local/bin/gunicorn_config.sh
echo 'DJANGO_WSGI_MODULE='$DJANGO_WSGI_FILE >> /usr/local/bin/gunicorn_config.sh
echo 'exec gunicorn '$DJANGO_WSGI_FILE':application --preload --debug --log-level=debug --log-file=$LOGFILE -w $NUM_WORKERS --settings=$DJANGO_SETTINGS_MODULE' >> /usr/local/bin/gunicorn_config.sh
cd /usr/local/bin
# change file permissions
sudo chmod u+x gunicorn_config.sh
cd /home/ubuntu/
#copy application config file to /etc/supervisor/conf.d
sudo cp GANDS/application.conf /etc/supervisor/conf.d
#rename application config file name
sudo mv /etc/supervisor/conf.d/application.conf /etc/supervisor/conf.d/$APPLICATION_NAME'.conf'
#writing application config file
echo '[program:'$APPLICATION_NAME']' >> /etc/supervisor/conf.d/$APPLICATION_NAME'.conf'
echo 'directory ='$PROJECT_ROOT_PATH >> /etc/supervisor/conf.d/$APPLICATION_NAME'.conf'
echo 'command = /usr/local/bin/gunicorn_config.sh' >> /etc/supervisor/conf.d/$APPLICATION_NAME'.conf'
echo 'stdout_logfile = /home/ubuntu/log/log.log' >> /etc/supervisor/conf.d/$APPLICATION_NAME'.conf'
echo 'stderr_logfile = /home/ubuntu/log/error.log' >> /etc/supervisor/conf.d/$APPLICATION_NAME'.conf'
#creating log directory and files
mkdir /home/ubuntu/log
touch /home/ubuntu/log/log.log
touch /home/ubuntu/log/error.log
#update supervisor processes
sudo supervisorctl reread
sudo supervisorctl update
#start nginx server
sudo service nginx start
#rename application file name
sudo cp GANDS/application /etc/nginx/sites-available
sudo mv /etc/nginx/sites-available/application /etc/nginx/sites-available/$APPLICATION_NAME
sed -i "s@STATIC_ROOT@$STATIC_ROOT@g" /etc/nginx/sites-available/$APPLICATION_NAME
sed -i "s@SERVER_NAME@$SERVER_NAME@g" /etc/nginx/sites-available/$APPLICATION_NAME
sed -i "s@PROJECT_ROOT_PATH@$PROJECT_ROOT_PATH@g" /etc/nginx/sites-available/$APPLICATION_NAME
cd $PROJECT_ROOT_PATH
sudo touch $APPLICATION_NAME'.log'
sudo chmod a+w $APPLICATION_NAME'.log'
mkdir -p $STATIC_ROOT'/static'
cd $PROJECT_ROOT_PATH
sudo python manage.py collectstatic --settings=$DJANGO_SETTINGS_FILE <<<yes
cd /etc/nginx/sites-available/
sudo ln /etc/nginx/sites-available/$APPLICATION_NAME ../sites-enabled/$APPLICATION_NAME
cd ../sites-enabled/
sudo rm default
cd /home/ubuntu/log/
touch gunicorn_log.log
sudo supervisorctl restart $APPLICATION_NAME
sudo service nginx restart
echo "Your deployment has finished Successfully"
echo "Enjooooooooooooooooooy"
