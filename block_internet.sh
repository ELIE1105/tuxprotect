#!/bin/bash


check_curl() {
  # Check if curl is already installed
  if ! command -v curl > /dev/null; then
    # Try to install curl
    if ! apt-get install curl; then
      # Remove the lock file and try again
    	rm /var/lib/dpkg/lock-frontend
		rm /var/lib/apt/lists/lock
		rm /var/cache/apt/archives/lock
		rm /var/lib/dpkg/lock
    	apt-get install curl
    fi
  fi
}

check_iptables() {
  # Check if curl is already installed
  if ! command -v curl > /dev/null; then
    # Try to install curl
    if ! apt-get install iptables; then
      # Remove the lock file and try again
    	rm /var/lib/dpkg/lock-frontend
		rm /var/lib/apt/lists/lock
		rm /var/cache/apt/archives/lock
		rm /var/lib/dpkg/lock
    	apt-get install iptables
    fi
  fi
}

apply_rules() {
	response_code=$1
	check_iptables
	if [ "$response_code" -eq "200" ]; then
		echo "Connected to Netfree"
		if iptables -C INPUT -j DROP; then
			iptables -F
			export DISPLAY=:0
			notify-send "Connection opened"
		fi
	else
		echo "Not connected to Netfree" 
		if !  iptables -C INPUT -j DROP; then
			timeout 5 iptables -A INPUT -s 1.2.3.4 -j ACCEPT
			timeout 5 iptables -A INPUT -s 51.89.182.69 -j ACCEPT
			timeout 5 iptables -A INPUT -j DROP
			export DISPLAY=:0
			notify-send "Connection blocked"
		fi
	fi		
}


#Infinite loop every 30s
while true; do
	check_curl
	response_code=$(timeout 15 curl -s -o /dev/null -w "%{http_code}" http://1.2.3.4)
	apply_rules "$response_code"
	sleep 30
done
