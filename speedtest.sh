#!/bin/bash
echo $(date) >> /home/pi/speedtest.log

DB_USER='root';
DB_PASSWD='My_first_db_12+!';

DB_NAME='raspberry';
TABLE='Net_speed';

day=$(date +"%y/%m/%d")
time=$(date +"%H:%M:%S")

declare -A lista

speedtest=$(speedtest-cli)

while read -r line
do
    if [[ "$line" == *"Hosted"* ]]; then
            lista[Ping]=$(echo $line| grep Hosted | awk -F ':' '{print $2}'| awk -F ' ' '{print $1}')
    fi

    if [[ "$line" == *"Download:"* ]]; then
	    lista[Download]=$(echo $line| grep "Download:" | awk -F ':' '{print $2}'| awk -F ' ' '{print $1}')
    fi

    if [[ "$line" == *"Upload:"* ]]; then
            lista[Upload]=$(echo $line| grep "Upload:" | awk -F ':' '{print $2}'| awk -F ' ' '{print $1}')
    fi

    echo "$line"
done < <(speedtest)



#lista[Download]=$(echo $speedtest| grep "Download:" | awk -F ':' '{print $2}')
#lista[Upload]=$(echo $speedtest| grep "Upload:" | awk -F ':' '{print $2}')
#lista[Ping]=$(echo $speedtest| grep Hosted | awk -F ':' '{print $2}'| awk -F ' ' '{print $1}')


for element in "${lista[@]}";do
    echo "$element" >> /home/pi/speedtest.log
done

mysql --user=$DB_USER --password=$DB_PASSWD $DB_NAME << EOF
INSERT INTO $TABLE (ts,dt,ping,download,upload) VALUES ("$time", "$day", "${lista[Ping]}", "${lista[Download]}", "${lista[Upload]}" );
EOF
