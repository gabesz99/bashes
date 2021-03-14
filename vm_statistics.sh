#!/bin/bash
echo $(date) >> /home/pi/vm_stats.log

DB_USER='root';
DB_PASSWD='My_first_db_12+!';

DB_NAME='raspberry';
TABLE='Vm_statistics';

day=$(date +"%y/%m/%d")
time=$(date +"%H:%M:%S")
cpu=$(</sys/class/thermal/thermal_zone0/temp)

declare -A lista


lista[MEMORY]=$(free -m | awk 'NR==2{printf "%.2f%%\t\t", $3*100/$2 }')
lista[DISK]=$(df -h | awk '$NF=="/"{printf "%s\t\t", $5}')
lista[CPU]=$(top -bn1 | grep load | awk '{printf "%.2f%%\t\t\n", $(NF-2)}')
lista[GPU_TEMP]=$(vcgencmd measure_temp | awk -F '=' '{print $2}' | awk -F "'" '{print $1}')
lista[CPU_TEMP]=$(($cpu/1000))

for element in "${lista[@]}";do
    echo "$element" >> /home/pi/vm_stats.log
done

#echo "${lista[MEMORY]//%}"
mysql --user=$DB_USER --password=$DB_PASSWD $DB_NAME << EOF
INSERT INTO $TABLE (ts,dt,memory,disk,cpu,temp,cpu_temp) VALUES ("$time", "$day", "${lista[MEMORY]//%}", "${lista[DISK]//%}", "${lista[CPU]//%}", "${lista[GPU_TEMP]//%}", "${lista[CPU_TEMP]//%}" );
EOF

if [[ "${lista[MEMORY]//%}" > 85 ]]; then
        python /home/pi/Email_sender.py High_Memory More_than_85_percent
fi

if [[ "${lista[CPU]//%}" > 85 ]]; then
        python /home/pi/Email_sender.py High_CPU More_than_85_percent
fi

if [[ "${lista[DISK]//%}" > 85 ]]; then
        python /home/pi/Email_sender.py High_DISK More_than_85_percent
fi

if [[ "${lista[CPU_TEMP]//%}" > 65 ]]; then
        python /home/pi/Email_sender.py High_CPU More_than_65_degree
fi

#Ip lekérés

declare -A IpLista

IpLista[eth0]=$(ip a show eth0 | grep 192 | awk '{print $2}' | awk -F '/' '{print $1}')
IpLista[wlan0]=$(ip a show wlan0 | grep 192 | awk '{print $2}' | awk -F '/' '{print $1}')
IpLista[ext_ip]=$(curl --silent --show-error --fail ipecho.net/plain)


#for item in "${IpLista[@]}";do
#    echo "$item" >> /home/pi/ip.log
#done


#db_eth0=$(echo "SELECT eth0 FROM config"| mysql $DB_NAME  -u $DB_USER -p'My_first_db_12+!');
db_eth0=$( mysql $DB_NAME  -u $DB_USER -p'My_first_db_12+!' -se "SELECT eth0 FROM config"|cut -f1|tail -1);
db_wlan0=$(echo "SELECT wlan0 FROM config"| mysql $DB_NAME -u $DB_USER -p'My_first_db_12+!'|cut -f1|tail -1);
db_ext_ip=$(echo "SELECT ext_ip FROM config"| mysql $DB_NAME -u $DB_USER -p'My_first_db_12+!'|cut -f1|tail -1);
#echo ${IpLista[eth0]};
#echo $db_eth0;
echo "$time + " " $day" >> /home/pi/ip.log
if [ "${IpLista[eth0]}" == "$db_eth0" ]
then
	echo "No changes" >> /home/pi/ip.log
else
	echo "There was eth0 interface changed" ${IpLista[eth0]} >> /home/pi/ip.log;
	mysql raspberry -u root -p'My_first_db_12+!' -e "UPDATE config SET eth0 = '${IpLista[eth0]}'";
	python /home/pi/Email_sender.py Change_IP ${IpLista[eth0]}
fi

if [ "${IpLista[wlan0]}" == "$db_wlan0" ]
then
	echo "No changes" >> /home/pi/ip.log
else
	echo "There was wlan0 interface changed" ${IpLista[wlan0]} >> /home/pi/ip.log;
	mysql raspberry -u root -p'My_first_db_12+!' -e "UPDATE config SET wlan0 = '${IpLista[wlan0]}'";
	python /home/pi/Email_sender.py Change_IP ${IpLista[wlan0]}
fi

if [ "${IpLista[ext_ip]}" == "$db_ext_ip" ]
then
	echo "No changes" >> /home/pi/ip.log
else
	echo "There was external ip interface changed" ${IpLista[ext_ip]} >> /home/pi/ip.log;
	mysql raspberry -u root -p'My_first_db_12+!' -e "UPDATE config SET ext_ip = '${IpLista[ext_ip]}'";
	python /home/pi/Email_sender.py Change_IP ${IpLista[ext_ip]}
fi


