<<<<<<< HEAD
﻿**Streetpass Automation Script for Android**

This is a script for switching mac addresses and creating software access points on the fly to help 
=======
:: Auto Streetpass for Android ::


  This is a script for switching mac addresses and creating doftware access points on the fly to help
>>>>>>> a0c3af40e5b9059aa1fb73408b34113d61f9d404
people who use their android phones for the Nintendo 3DS streetpass relay feature introduced in  firmware 
6.2.0-XX . It also tries to reverse tether(getting wired internet access from usb connected to PC) the 
phone for people without data plans.

# Requirements
<<<<<<< HEAD
The phone must have a CyanogenMod based ROM (or must be able to at least read the Wi-Fi MAC address 
=======
  The phone must have a CyanogenMod based ROM (or must be able to at least read the Wi-Fi MAC address 
>>>>>>> a0c3af40e5b9059aa1fb73408b34113d61f9d404
from a file, which can be user defined, and be able to do usb tethering for it to be reversed if needed), 
root access and the application 'Wireless Tether for Root Users' 
(found on http://code.google.com/p/android-wifi-tether/) installed and operational. Also make sure the 
virtual access point is started manually at least once from inside the app so that it generates the config 
files required for the binary to run in standalone mode. It is not recommended to enable MAC address spoofing 
in its options.

# Installation
<<<<<<< HEAD
Place the provided "data" folder in the root directory of the phone's sd card.

# Usage
If you want to use reverse tethering, connect your phone to your PC, share a connection with it from 
=======
  Place the provided "data" folder in the root directory of the phone's sd card.

# Usage
  If you want to use reverse tethering, connect your phone to your PC, share a connection with it from 
>>>>>>> a0c3af40e5b9059aa1fb73408b34113d61f9d404
there and have it on before starting the script. If usb tethering is not on, the reverse tethering setup will 
be ignored, and it's assumed that a valid internet connection is already present. After deciding on that, 
just start the script and let it run! It will inform you of almost everything it is doing, although it can be 
run on the background if nedded.

# Configuration
<<<<<<< HEAD
In the main script there are some variables which can be edited along with a brief summary where nedded. 
=======
  In the main script there are some variables which can be edited along with a brief summary where nedded. 
>>>>>>> a0c3af40e5b9059aa1fb73408b34113d61f9d404
The file macList.txt stores all the MAC addresses that will be used. Invalid entries are ignored, as well as 
commentary lines denoted by '#' at their start.
	
# To-do
<<<<<<< HEAD
* Implement it for other ROMs that read MAC from a file (I don't know of any, create a issue with info if you know one that is able to do it)
	
=======
  *Implement it for other ROMs that read MAC from a file (I don't know of any, create a issue with info 
if you know one that is able to do it)
	
>>>>>>> a0c3af40e5b9059aa1fb73408b34113d61f9d404
