#!/bin/bash

if ! [ -z ${GIT_USERNAME} ] && [ -z ${GIT_PASSWORD} ] && [ -z ${GIT_PATH} ]
then
  cd /projeto
  git config --global pull.ff only && \
  git config --global init.defaultBranch master && \
  git config --global core.fileMode false && \
  git init && \
  git remote add master https://${GIT_USERNAME}:${GIT_PASSWORD}@${GIT_PATH}
  git pull master master  
  rsync -aruvhcpt --progress /projeto/* /code/
fi

chown -R www-data:www-data /code &
chmod -R 775 /code &

if [ -d /scripts_init ];
then
  for f in /scripts_init/*; 
    do $f; 
  done
fi

if [ -d /code/scripts_init ];
then
  for f in /code/scripts_init/*; 
    do $f; 
  done
fi

if [ -f /code/config_cntr/php.ini ] || [ -f /code/config_cntr/www.conf ]
then
  cp /code/config_cntr/php.ini /etc/php/8.0/fpm/php.ini
  cp /code/config_cntr/www.conf /etc/php/8.0/fpm/pool.d/www.conf
  service php8.0-fpm restart
fi

if [ -f /code/config_cntr/nginx.conf ] || [ -f /code/config_cntr/default.conf ]
then
  cp /code/config_cntr/nginx.conf /etc/nginx/nginx.conf
  cp /code/config_cntr/default.conf /etc/nginx/conf.d/default.conf
  service nginx reload
fi

if ! [ -z ${MAIL_SERVER} ]
then
  envsubst < /muttrc.template > ~/.mutt/muttrc
fi

if ! [ -z ${WWWROOT} ]
then
  sed -i "s/\/code/${WWWROOT}/g" /etc/nginx/conf.d/default.conf
fi