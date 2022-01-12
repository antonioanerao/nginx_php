#!/bin/bash

printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n" >  ~/${HOSTNAME}.log
printf "                 BACKUP DE imagens                        \n" >> ~/${HOSTNAME}.log
printf "                 INICIADO EM: `date`                              \n" >> ~/${HOSTNAME}.log
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n" >> ~/${HOSTNAME}.log

if ! [ -d "/bkp" ]; 
then 
  mkdir /bkp; 
fi

if [ -n $MARIADB_DATABASE ] && [ -n $MARIADB_ROOT_PASSWORD ] && [ -n $MARIADB_HOST ] 
then
  printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n" >> ~/${HOSTNAME}.log
  printf "                 BACKUP DO BANCO ${MARIADB_DATABASE}              \n" >> ~/${HOSTNAME}.log
  printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n" >> ~/${HOSTNAME}.log
  mysqldump --databases $MARIADB_DATABASE -p$MARIADB_ROOT_PASSWORD -h $MARIADB_HOST > /bkp/$MARIADB_DATABASE.sql 
fi

if [ -n $BKP_PATH ] && [ -n $SSH_USER ] && [ -n $BKP_PATH ] 
then
  printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n" >> ~/${HOSTNAME}.log
  printf "        MIGRANDO BACKUP DO BANCO ${MARIADB_DATABASE}              \n" >> ~/${HOSTNAME}.log
  printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n" >> ~/${HOSTNAME}.log
  rsync -aruvhcpt --progress \
  --rsh="sshpass -p $SSH_PASSWORD ssh -o StrictHostKeyChecking=no -l $SSH_USER" \
  -z --compress-level=9 /bkp/* $SSH_USER@$BKP_PATH/banco/  >> ~/${HOSTNAME}.log
fi

if [ -n $BKP_PATH ] && [ -n $SSH_USER ] && [ -n $BKP_PATH ] 
then
  printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n" >> ~/${HOSTNAME}.log
  printf "        BACKUP DO imagens                                 \n" >> ~/${HOSTNAME}.log
  printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n" >> ~/${HOSTNAME}.log
  rsync -aruvhcpt --progress \
  --rsh="sshpass -p $SSH_PASSWORD ssh -o StrictHostKeyChecking=no -l $SSH_USER" \
  -z --compress-level=9 /code/* $SSH_USER@$BKP_PATH/site/  >> ~/${HOSTNAME}.log
fi

printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n" >> ~/${HOSTNAME}.log
printf "        BACKUP DO imagens                                 \n" >> ~/${HOSTNAME}.log
printf "        FINALIZADO EM: `date`                                     \n" >> ~/${HOSTNAME}.log
printf "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++\n" >> ~/${HOSTNAME}.log


if [ -n ${MAIL_SERVER} ] 
then
  mutt -s "Backup de imagens" dev.seict@ac.gov.br < ~/${HOSTNAME}.log
fi