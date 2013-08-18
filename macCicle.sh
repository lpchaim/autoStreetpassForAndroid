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
timeToWait=30m	# Use s for seconds, m for minutes, h for hours, d for days
macListPath=/mnt/sdcard/A/script/MAC/macList.txt	# File from where MACs will be read
androidMacFilePath=/data/.nvmac.info	# Path to android file where mac address is stored
wifiTetherPath=/data/data/com.googlecode.android.wifi.tether # Path to wifi tether app folder 

# Control variables, do not modify
n=0
l=0
USB_TETHERING_ENABLE=false
LOOP_TIMES=1

usage()
{
cat << EOF >&2
Usage: $0 [-h|-u|-i]

Starts and manages a wifi access point while cicling through different MAC addresses

		-h		Display help page
		-u		Enables usb reverse tethering (default tethering has to be manually enabled before starting)
		-l		Number of times to iterate through source MAC addresses (0 to repeat indefinitely)
		
Report bugs at https://github.com/lupec/autoStreetpassForAndroid/issues
EOF
}

cleanUp()
{
	echo -n "  Stopping wifi tether service... "
	$wifiTetherPath/bin/tether stop >/dev/null 2>&1
	if [ $? -ne 0 ]; then
		echo -e "FAIL!\n[E] Code $? returned by 'wifiTetherPath/tether stop'" >&2
	fi
	echo "OK!"
	
	echo -n "Restoring original MAC address..."
	sed -i "s/.*/$ORIGINAL_MAC/" "$androidMacFilePath"
	if [ $? -ne 0 ]; then
		echo -e "FAIL!\n[E] Code $? returned by 'echo $ORIGINAL_MAC > $androidMacFilePath'" >&2
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
while getopts "ul:t:" OPT
do
	case $OPT in
		h)
			usage
			;;
		u)
			USB_TETHERING_ENABLE=true
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
				timeToWait=$OPTARG
			;;
		*)
			usage
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

echo "Dir: $SM_ALIAS"

echo -n "::Checking for root rights..."
if [ $(whoami) != root ]; then
	echo -e " FAIL!\n[E] No root access, cannot continue" >&2
	exit
fi
echo -e " OK!\n"

if [ $USB_TETHERING_ENABLE ]
then
	echo "::Reverse tethering connection"
	echo -n "Trying to init usb interface... "
	netcfg rndis0 dhcp >/dev/null 2>&1
	if [ $? -eq 1 ]; then
		echo -e "FAIL!\n  Could not connect, skipping!\n" >&2		
	elif [ $? -eq 0 ]; then
		echo "OK!\n"
		
		echo -n "Setting up dummy 3G network... "
		busybox ifconfig rmnet0 0.0.0.0 >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			echo -e " FAIL!\n[E] Code $? returned by 'ifconfig rmnet0 0.0.0.0'" >&2
			exit
		fi
		echo "OK!\n"
	else
		echo -e "FAIL!\n[E] Code $? returned by 'netcfg rndis0 dhcp'" >&2
		exit
	fi
fi

echo "::Begin MAC address cicling"
if [ -e $androidMacFilePath ]
then
	echo -e "Found $androidMacFilePath\n"

	while(true)
	l=`expr $n + 1`
	do
		if [ ! -e $macListPath ]; then
			echo -e "[E] Mac list file not found\n" >&2
			exit
		fi
		
		ORIGINAL_MAC=$(cat "$androidMacFilePath")
		
		for mac in $(sed -e '/^.*#/d' -e '/^$/d' -e '/^[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]/!d' $macListPath)
		do
			n=`expr $n + 1`
			echo "Iteration $n:"
			
			if [ -n "$(ps | grep $wifiTetherPath)" ]	# If service was already running before by this script, stop it
			then
				echo -n "  Stopping wifi tether service... "
				$wifiTetherPath/bin/tether stop >/dev/null 2>&1
				if [ $? -ne 0 ]; then
					echo -e " FAIL!\n[E] Code $? returned by 'wifiTetherPath/tether stop'" >&2
					exit
				fi
				echo "OK!"
			fi
			 
			echo -n "  Writing $mac to file... "
			sed -i "s/.*/$mac/" "$androidMacFilePath"
			if [ $? -ne 0 ]; then
				echo "FAIL!\n[E] Code $? returned by sed -i 's|.*|$mac| $androidMacFilePath'" >&2
				exit
			fi
			echo "OK!"
			 
			echo -n "  Starting wifi tether service... "
			$wifiTetherPath/bin/tether start >/dev/null 2>&1
			if [ $? -ne 0 ]; then
				echo -e " FAIL!\n[E] Code $? returned by 'wifiTetherPath/tether start'" >&2
				exit
			fi
			echo "OK!"
			
			echo -n "  Waiting for $timeToWait to pass... "
			busybox sleep $timeToWait
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
	echo "[E] $androidMacFilePath not found! Is this really a supported rom?" >&2
	exit
fi