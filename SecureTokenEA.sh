#!/bin/bash

#################################################################
# This extension attribute for Jamf Pro will reach out	
# to Jamf via the API, find the username of the		
# management account on the machine and then check on 	
# the Secure Token status of the management account	
# and report it back to Jamf Pro.
#
# Please enter your Jamf Pro address in the variable below:
#######################
jamfProURL="my.jamf.pro"
#######################
# NOTE: leave out the "https://"
#								
#################
# AUTHENTICATION
#################
#
# This script utilizes 256 bit encryption to protect the username and password 
# of the API account. Since this will be in a Jamf Pro Extension Attribute, we can't pass parameters down,
# so we'll need to bake in all three pieces of the encryption key.    
# Enter your ENCRYPTED STRING, SALT, and PASSPHRASE for both the username and the password
# in the variables below to decrypt them.
#
###########################################
usernameSTRING="INSERT_ENCRYPTED_STRING_HERE"
usernameSALT="INSERT_SALT_HERE"
usernamePASSPHRASE="INSERT_PASSPHRASE_HERE"
passwordSTRING="INSERT_ENCRYPTED_STRING_HERE"
passwordSALT="INSERT_SALT_HERE"
passwordPASSPHRASE="INSERT_PASSPHRASE_HERE"
###########################################
#
# You can use my Mr Encryptor script located at the link below to encrypt
# your username and password and generate the salt and passphrase:
#
# https://github.com/zghalliwell/MrEncryptor
#     			   
# The API account will need read-only access to computer inventory records										         
#      
################################################################################
#Establish the function to decrypt the username and password of the API account
function DecryptString() {
	echo "${1}" | /usr/bin/openssl enc -aes256 -d -a -A -S "${2}" -k "${3}"
}

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
