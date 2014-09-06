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
sudo pip install setuptools
sudo pip install ipython
sudo pip install gunicorn
sudo pip install supervisor
sudo apt-get install supervisor <<<y
sudo apt-get install nginx <<<y

# load global variables
. sameedo.conf
sudo pip install django==$DJANGO_VERSION
# install the required requirements for the application
sudo pip install django-crispy-forms
sudo apt-get install python-pandas <<<y
sudo pip install mpld3
sudo pip install jinja2
sudo pip install reportlab
sudo pip install logger
sudo git clone https://ismaeelsameed@bitbucket.org/omargammoh/ehsibha /usr/local/lib/python2.7/dist-packages/ehsibha
sudo git clone https://ismaeelsameed@bitbucket.org/omargammoh/common /usr/local/lib/python2.7/dist-packages/common

#writing the config file
echo -e '\nNUM_WORKERS='$NUM_WORKERS >> gunicorn_config.sh
echo 'cd '$PROJECT_ROOT_PATH >> gunicorn_config.sh
echo 'test -d $LOGDIR || mkdir -p $LOGDIR' >> gunicorn_config.sh
echo 'DJANGO_SETTINGS_MODULE='$DJANGO_SETTINGS_FILE >> gunicorn_config.sh
echo 'DJANGO_WSGI_MODULE='$DJANGO_WSGI_FILE >> gunicorn_config.sh
echo 'exec gunicorn Ehsibha.wsgi:application --preload --debug --log-level=debug --log-file=$LOGFILE -w $NUM_WORKERS --settings=$DJANGO_SETTINGS_MODULE' >> gunicorn_config.sh
#copy gunicorn config file to /usr/local/bin
sudo cp gunicorn_config.sh /usr/local/bin
cd /usr/local/bin
# change file permissions
sudo chmod u+x gunicorn_config.sh
#rename application config file name
cd /home/ubuntu/ehsibhasite/generic-nginx-config/
mv application.conf $APPLICATION_NAME'.conf'
#writing application config file
echo '[program:'$APPLICATION_NAME']' >> $APPLICATION_NAME'.conf'
echo 'directory ='$PROJECT_ROOT_PATH >> $APPLICATION_NAME'.conf'
echo 'command = /usr/local/bin/gunicorn_config.sh' >> $APPLICATION_NAME'.conf'
echo 'stdout_logfile = /home/ubuntu/log/log.log' >> $APPLICATION_NAME'.conf'
echo 'stderr_logfile = /home/ubuntu/log/error.log' >> $APPLICATION_NAME'.conf'
#copy application config file to /etc/supervisor/conf.d
sudo cp $APPLICATION_NAME'.conf' /etc/supervisor/conf.d
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
mv application $APPLICATION_NAME
sed -i "s@STATIC_ROOT@$STATIC_ROOT@g" $APPLICATION_NAME
sed -i "s@SERVER_NAME@$SERVER_NAME@g" $APPLICATION_NAME
sed -i "s@PROJECT_ROOT_PATH@$PROJECT_ROOT_PATH@g" $APPLICATION_NAME
sudo cp $APPLICATION_NAME /etc/nginx/sites-available
cd $PROJECT_ROOT_PATH
sudo touch $APPLICATION_NAME'.log'
sudo chmod a+w $APPLICATION_NAME'.log'
mkdir -p $STATIC_ROOT'/static'
cd $PROJECT_ROOT_PATH
sudo python manage.py collectstatic --settings=$DJANGO_SETTINGS_FILE <<<yes
cd /etc/nginx/sites-available/
sudo ln /home/ubuntu/ehsibhasite/generic-nginx-config/$APPLICATION_NAME ../sites-enabled/$APPLICATION_NAME
cd ../sites-enabled/
sudo rm default
cd /home/ubuntu/log/
touch gunicorn_log.log
sudo supervisorctl restart $APPLICATION_NAME
sudo service nginx restart
echo "Ehsibha deployment has finished Successfully"
echo "Enjooooooooooooooooooy"
