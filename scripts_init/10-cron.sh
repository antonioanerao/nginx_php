#!/bin/bash
if [ -f "/code/config_cntr/cron.list" ];
then  
  crontab /code/config_cntr/cron.list;
fi
