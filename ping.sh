#!/bin/bash
for ID in $(cat public_dns_ips ) 
	do 
		ping -c 2 $ID
	done

