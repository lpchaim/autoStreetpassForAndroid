**Streetpass Automation Script for Android**

This is a script for switching mac addresses and creating doftware access points on the fly to help
people who use their android phones for the Nintendo 3DS streetpass relay feature introduced in  firmware 
6.2.0-XX . It also tries to reverse tether (getting wired internet access from usb connected to PC) the 
phone for people without an available mobile data connection.

# Requirements

* Root access
* ROM able to read the Wi-Fi MAC address from a file (only implemented for CyanogenMod based ROMs for now)
* 'Wifi Tether for Root Users' app (found [here](http://code.google.com/p/android-wifi-tether/))*
* Usb tethering capabilities for reverse tethering, optional

*Make sure the virtual access point is started manually at least once from inside the app so that it generates the config 
files required for the binary to run in standalone mode. It is not recommended to enable MAC address spoofing 
in its options.

# Usage

To install the script, simply unzip the contents of its release file to the root of your sd card.

My script was tested with [Script Manager](https://play.google.com/store/apps/details?id=os.tools.scriptmanager), but
it should work with similar solutions. Navigate to /data/script.autoStreetpassForAndroid/ choose macCicle.sh, check Root
and Wakelock, set your desired arguments and run. You can use the addon package [SMWidgets](https://play.google.com/store/apps/details?id=os.tools.smwidgets)
to make a quick widget on the phone's launcher for quick access.

If you want to use reverse tethering just connect your phone to your PC, share a connection with the usb 
network adapter and turn on usb tethering before running the script with the proper argument(s) (See Configuration for details).

# Configuration
In the main script there are some variables that can be edited along with a brief summary where applicable. 

Thre is also file macList.txt, which stores all the MAC addresses that will be used. Invalid entries are ignored, 
as well as commentary lines denoted by '#' at their start.


As for the script's arguments, see the script's help text below:
	Usage: macCicle [-h] [-u ensure] [-l loops] [-t delay<unit>]

	Starts and manages a wifi access point while cicling through different MAC addresses

		-h			Display help page
		-u ensure		Enables usb reverse tethering
					Optional argument, if true quits on error
		-l loops		Number of times to iterate through MAC list, default 1
					Pass 0 for it to loop indefinitely
		-t	delay<unit>	Sets a custom delay beteen MAC changing
					Unit format: [s:seconds|m:minutes|h:hours|d:days]
	
# To-do
* Implement it for other ROMs that read MAC from a file (I don't know of any, create a issue with info if you know one that is able to do it)
