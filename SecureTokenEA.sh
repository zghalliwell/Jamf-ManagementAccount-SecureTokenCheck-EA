#!/bin/bash

#############################################################
#	This extension attribute for Jamf Pro will reach out	#
#	to Jamf via the API, find the username of the			#
#	management account on the machine and then check on 	#
#	the Secure Token status of the management account		#
#	and report it back to Jamf Pro.							#
#															#
#	This script utilizes 256-bit encryption to protect		#
#	the API username and password. To generate an			#
#	encrypted string, salt and password you can use my		#
#	Mr Encryptor tool here: 								#
#	https://github.com/zghalliwell/MrEncryptor				#
#############################################################

#Establish the function to decrypt the username and password of the API account
function DecryptString() {
	echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}

#Enter your encrypted string, salt, and passphrase for your API username
usernameString="ENTER STRING HERE"
usernameSalt="ENTER SALT HERE"
usernamePassphrase="ENTER PASSPHRASE HERE"

#Enter your encrypted string, salt, and passphrase for your API password
passwordString="ENTER STRING HERE"
passwordSalt="ENTER SALT HERE"
passwordPassphrase="ENTER PASSPHRASE HERE"

#Enter your Jamf Pro URL here WITHOUT the https://
jamfProURL="my.jamfpro.url"

#Format for Decryption: DecryptString "parameter for encryption string" "Salt" "Pasphrase"
apiUser=$(DecryptString "$usernameString" "$usernameSalt" "$usernamePassphrase")
apiPass=$(DecryptString "$passwordString" "$passwordSalt" "$passwordPassphrase")

#Get the serial number of their device and save as variable
serial=$(system_profiler SPHardwareDataType | awk '/Serial Number/{print $4}')

#Get the username of the management account on their machine
managementAccount=$(curl -u $apiUser:$apiPass "https://$jamfProURL/JSSResource/computers/serialnumber/$serial" -H "Accept: text/xml" -X GET -s | xmllint --xpath '/computer/general/remote_management/management_username/text()' -)

#Get secure token status of the management Account
stStatus=$(sysadminctl -secureTokenStatus $managementAccount 2>&1 | awk '{print $7}')

#Print the status back to the EA
if [ "$stStatus" == "ENABLED" ]; then
	echo "<result>Enabled</result>"
else
	echo "<result>Not Enabled</result>"
fi