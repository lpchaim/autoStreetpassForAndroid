#!/system/bin/sh
#

# Auto Streetpass Automation Script for Android
# 15/08/2013
# Copyright 2013 lpchaim aka lupec
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# WARNING: This script handles system files directly, and there is no guarantee 
# it is safe. I did try my best to prevent anything nasty from happenning tough.

# Variable values
TIME_DELAY=30m	# Use s for seconds, m for minutes, h for hours, d for days
MAC_FILE_LIST_PATH=/mnt/sdcard/data/script.autoStreetpass/macList.txt	# File from where MACs will be read
ROM_MAC_FILE_PATH=/data/.nvmac.info	# Path to android file where mac address is stored
WIFI_TETHER_PATH=/data/data/com.googlecode.android.wifi.tether # Path to wifi tether app folder 

# Control variables, do not modify
USB_TETHERING_ENABLE=false
USB_TETHERING_ENSURE=false
LOOP_TIMES=1
n=0
l=0

usage()
{
cat << EOF >&2

Usage: macCicle [-h] [-u enforce] [-l loops] [-t delay<unit>]

Starts and manages a wifi access point while cicling through different MAC addresses

		-h		Display help page
		-u		Enables usb reverse tethering 
		-l		Number of times to iterate through MAC list
		-t		Sets a custom delay beteen MAC changing
		
		[enforce] Set to true to quit if usb tethering fails
		[loops] Number of loops, default 1
				Pass 0 for it to loop indefinitely
		[delay] Time to wait
				<UNIT> s:seconds|m:minutes|h:hours|d:days
		
Report bugs at https://github.com/lupec/autoStreetpassForAndroid/issues
EOF
}

cleanUp()
{
	echo -n "Stopping wifi tether service... "
	$WIFI_TETHER_PATH/bin/tether stop >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo -e "FAIL!\n[E] Code $? returned by 'WIFI_TETHER_PATH/tether stop'" >&2
	fi
	echo "OK!"
	
	echo -n "Restoring original MAC address..."
	sed -i "s/.*/$ORIGINAL_MAC/" "$ROM_MAC_FILE_PATH"
	if [ $? -ne 0 ]; then
		echo -e "FAIL!\n[E] Code $? returned when restoring $ORIGINAL_MAC > $ROM_MAC_FILE_PATH'" >&2
	fi
	echo "OK!"
	
	if [ $USB_TETHERING_ENABLE ]
	then
		echo -n "Disabling usb tethering... "
		netcfg rndis0 down >/dev/null 2>&1
		netcfg rndis0 up >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			echo -e " FAIL!\n[E] Code $? returned when resetting usb tethering interface" >&2
		fi
		echo "OK!"
	fi
	
	return 0
}

signalIntercept()
{
	echo -e "\n::Cleaning up"
	cleanUp
	exit
}

# Trapping exit signal
trap signalIntercept SIGINT SIGTERM

# Parse commenad line arguments
while getopts "hu:l:t:" OPT
do
	case $OPT in
		h)
			usage
			exit
			;;
		u)
			USB_TETHERING_ENABLE=true
			if [ $OPTARG == "true" ]; then
				USB_TETHERING_ENSURE=true
			fi
			;;
		l)
			if [ $OPTARG -lt 0 ]
			then
				LOOP_TIMES=1
			else
				LOOP_TIMES=$OPTARG
			fi
			;;
		t)
			TIME_DELAY=$OPTARG
			;;
		*)
			usage
			exit
			;;
	esac
done

echo -e "\n"
echo "::::::::::::::::::::::::::::::::::::::::"
echo "::                                    ::"
echo ":: Streetpass relay automation script ::"
echo "::                                    ::"
echo "::::::::::::::::::::::::::::::::::::::::"
echo -e "by lpchaim aka lupec\n"

echo -n "::Checking for root rights..."
if [ $(whoami) != root ]; then
	echo -e " FAIL!\n[E] No root access, cannot continue" >&2
	exit
fi
echo -e " OK!\n"

if $USB_TETHERING_ENABLE
then
	echo "::Reverse tethering connection"
	echo -n "Trying to init usb interface... "
	netcfg rndis0 dhcp >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo -e " FAIL!\n[E] Code $? returned by 'ifconfig rmnet0 0.0.0.0'" >&2
		echo -n -e "\n  Could not connect" >&2
		if $USB_TETHERING_ENSURE; then
			echo -e ", quitting\n" >&2
		else
			echo -e ", skipping\n" >&2
		fi
	else
		echo "OK!\n"
		
		echo -n "Setting up dummy 3G network... "
		busybox ifconfig rmnet0 0.0.0.0 >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			echo -e " FAIL!\n[E] Code $? returned by 'ifconfig rmnet0 0.0.0.0'" >&2
			exit
		fi
		echo "OK!\n"
	fi
fi

echo "::Begin MAC address cicling"
if [ -e $ROM_MAC_FILE_PATH ]
then
	ORIGINAL_MAC=$(cat "$ROM_MAC_FILE_PATH")
	echo -e "$ROM_MAC_FILE_PATH found and stored\n"
	
	while(true)
	l=`expr $n + 1`
	do
		if [ ! -e "$MAC_FILE_LIST_PATH" ]; then
			echo -e "[E] Mac list file not found\n" >&2
			exit
		fi
		
		for mac in $(sed -e '/^.*#/d' -e '/^$/d' -e '/^[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]/!d' $MAC_FILE_LIST_PATH)
		do
			n=`expr $n + 1`
			echo "Iteration $n:"
			
			if [ -n "$(ps | grep $WIFI_TETHER_PATH)" ]	# If service was already running before by this script, stop it
			then
				echo -n "  Stopping wifi tether service... "
				$WIFI_TETHER_PATH/bin/tether stop >/dev/null 2>&1
				if [ $? -ne 0 ]; then
					echo -e " FAIL!\n[E] Code $? returned by 'WIFI_TETHER_PATH/tether stop'" >&2
					exit
				fi
				echo "OK!"
			fi
			 
			echo -n "  Writing $mac to file... "
			sed -i "s/[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]/$mac/" "$ROM_MAC_FILE_PATH"
			if [ $? -ne 0 ]; then
				echo "FAIL!\n[E] Code $? returned by sed -i 's|.*|$mac| $ROM_MAC_FILE_PATH'" >&2
				exit
			fi
			echo "OK!"
			 
			echo -n "  Starting wifi tether service... "
			$WIFI_TETHER_PATH/bin/tether start >/dev/null 2>&1
			if [ $? -ne 0 ]; then
				echo -e " FAIL!\n[E] Code $? returned by 'WIFI_TETHER_PATH/tether start'" >&2
				exit
			fi
			echo "OK!"
			
			echo -n "  Waiting for $TIME_DELAY to pass... "
			busybox sleep $TIME_DELAY
			echo "OK!"
			
			echo -e "\n"
		done

	if [ $LOOP_TIMES -eq $l ]; then
		break
	fi
	echo -e "Restarting from first MAC address\n"
	
	done
	
	# Now, we undo the changes to network configuration
	# TO-DO, not immediately necessary
	echo "::Cleaning up"
	cleanUp
	echo "All done, quitting now!"
else
	echo "[E] $ROM_MAC_FILE_PATH not found! Is this really a supported rom?" >&2
	exit
fi