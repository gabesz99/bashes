#!/bin/bash
echo $(date) >> /home/pi/lamp.log

DB_USER='root';
DB_PASSWD='My_first_db_12+!';

DB_NAME='Smart_Home';
TABLE='Lamps';

day=$(date +"%y/%m/%d")
time=$(date +"%H:%M:%S")

Halo_status=$(sh /home/pi/Light/light.sh status)
Nappali_status=$(sh /home/pi/Nappali_Light/light.sh status )

Halo_time=$(echo "SELECT Halo_time FROM $TABLE WHERE id='1';" | mysql -N $DB_NAME -u $DB_USER -p$DB_PASSWD)
Nappali_time=$(echo "SELECT Nappali_time FROM $TABLE WHERE id='1';" | mysql -N $DB_NAME -u $DB_USER -p$DB_PASSWD)

if [[ "$Halo_status" == *"on"* ]]; then
  Halo_status="on"
  Halo_time=$((Halo_time+1))
  echo "UPDATE $TABLE SET Halo_time = '$Halo_time' WHERE id='1';" | mysql -N $DB_NAME -u $DB_USER -p$DB_PASSWD
else
  Halo_status="off"
  Halo_time=0
  echo "UPDATE $TABLE SET Halo_time = '$Halo_time' WHERE id='1';" | mysql -N $DB_NAME -u $DB_USER -p$DB_PASSWD
fi

if [[ "$Nappali_status" == *"on"* ]]; then
  Nappali_status="on"
  Nappali_time=$((Nappali_time+1))
  echo "UPDATE $TABLE SET Nappali_time = '$Nappali_time' WHERE id='1';" | mysql -N $DB_NAME -u $DB_USER -p$DB_PASSWD
else
  Nappali_status="off"
  Nappali_time=0
  echo "UPDATE $TABLE SET Nappali_time = '$Nappali_time' WHERE id='1';" | mysql -N $DB_NAME -u $DB_USER -p$DB_PASSWD
fi

echo "Halo lampa: $Halo_time and $Halo_status" >> /home/pi/lamp.log
echo "Nappali lampa: $Nappali_time and $Nappali_status" >> /home/pi/lamp.log


if [[ "$Halo_time" == 108 ]]; then
	python /home/pi/Email_sender.py Lamp_active 9_hour	
fi


if [[ "$Nappali_time" == 108 ]]; then
	python /home/pi/Email_sender.py Lamp_active 9_hour	
fi
