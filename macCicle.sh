#!/system/bin/sh
#

# WARNING: This script handles system files directly. I did my best not to screw
# something up, but if I do anyway it is your responsability since you agreed to
# use it.

# Variable values
timeToWait=30m	# Use s for seconds, m for minutes, h for hours, d for days
macListFilename=macList.txt	# File from where MACs will be read
androidMacFilePath=/data/.nvmac.info	# File where mac address is stored
wifiTetherBinPath=/data/data/com.googlecode.android.wifi.tether/bin # Path to wifi tether app binary folder

# Control variables
apRunning=0
n=0

echo -e "\n"
echo "::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo "::                                                ::"
echo ":: Streetpass relay automation script for android ::"
echo "::                                                ::"
echo "::::::::::::::::::::::::::::::::::::::::::::::::::::"
echo -e "by lpchaim aka lupec\n"

echo -n "::Checking for root rights..."
if [ -z "$(id | grep root)" ]; then
	echo "\n  [Error] No root access, cannot continue"
	exit
fi
echo -e " OK!\n"

echo "::Initializing reverse tethering connection"
echo -n "Setting up usb interface..."
netcfg rndis0 dhcp
if [ $? -ne 0 ]; then
	echo -e "\n[Error] Code $? returned by 'netcfg rndis0 dhcp'"
	echo "Remember usb tethering has to be enabled before running this script"
	exit
fi
echo " OK!\n"

echo -n "Setting up dummy 3G network..."
ifconfig rmnet0 0.0.0.0
if [ $? -ne 0 ]; then
	echo -e "\n[Error] Code $? returned by 'ifconfig rmnet0 0.0.0.0'"
	exit
fi
echo " OK!\n"

echo "::Begin MAC address cicling"
if [ -e $androidMacFilePath ]
then
	echo "Found $androidMacFilePath"  

	for mac in "$(sed -e '/^.*#/d' -e '/^$/d' -e '/^[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]:[0-9A-Fa-f][0-9A-Fa-f]/!d' ./$macListFilename)"
	do
		if [ apRunning -ne 0 ]	# If service was already started before by this script, stop it
		then
			echo -n "Stopping wifi tether binary..."
			$wifiTetherBinPath/tether stop
			if [ $? -ne 0 ]; then
				echo -e "\n[Error] Code $? returned by '$wifiTetherBinPath/tether stop"
				exit
			fi
			echo " OK!"
		fi
	
		n++
		echo -n "Writing MAC #$n ($mac)..."
		sed -i 's|.*|$mac|' $androidMacFilePath
		if [ $? -ne 0 ]; then
			echo "\n[Error] Code $? returned by 'sed -i 's|.*|$mac|' $androidMacFilePath'"
			exit
		fi
			
		echo " OK!"

		echo -n "Starting wifi tether binary..."
		$wifiTetherBinPath/tether start
		if [ $? -ne 0 ]; then
			echo -e "\n[Error] Code $? returned by '$wifiTetherBinPath/tether start"
			exit
		fi
		apRunning=1
		echo " OK!"
		
		echo -n "Waiting $timeToWait..."
		sleep $timeToWait
		echo " OK!"
	done
else
	echo "[Error] $androidMacFilePath not found! Is this really a Cyanogenmod based rom?"
	exit
fi