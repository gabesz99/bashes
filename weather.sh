#!/bin/bash

echo $(date) >> /home/pi/weather.log
temperature=$(curl --silent wttr.in/pecs?format="3")
humidity=$(curl --silent wttr.in/pecs?format="%h")
pressure=$(curl --silent wttr.in/pecs?format="%P")
#if [[ $temperature == *"pecs"* ]]; then 
#     echo na
#else

case "$temperature" in 
	*"<"*)
	echo 'na' >> /home/pi/weather.log
	;;
        *)
	echo $temperature >> /home/pi/weather.log
	;;
esac

case "$humidity" in 
	*"<"*)
	echo 'na' >> /home/pi/weather.log
	;;
        *)
	echo $humidity >> /home/pi/weather.log
	;;
esac

	
case "$pressure" in 
	*"<"*)
	echo 'na' >> /home/pi/weather.log
	;;
        *)
	echo $pressure >> /home/pi/weather.log
	;;
esac
	
	
	
	
#echo $temperature
#>> /home/linux/weather.log
#curl --silent wttr.in/pecs?format="%h" >> /home/linux/weather.log
#curl --silent wttr.in/pecs?format="%P" >> /home/linux/weather.log
