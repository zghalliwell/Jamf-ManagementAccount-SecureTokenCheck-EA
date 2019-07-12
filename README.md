# Jamf-ManagementAccount-STCheck-EA
An extension attribute for Jamf Pro to check if the computer's management account has a secure token.

This extension attribute will utilize the Jamf Pro API to check what the management account username is for the computer it is run from and then check if that account has a Secure Token for FileVault 2. 

We're specifically using the API for this because over time some people change the management accounts, or they create different management accounts for different enrollment processes. Using the API will ensure that each device is checking for the management account that should specifically be on each device.

How to use this EA:
----
First, if you don't have an API account created, create one in Jamf Pro with the ability to at least read computer inventory records.

Next you'll want to encrypt the username and password for the API account before putting it in the EA. The script uses openssl to decrypt username and password from a combination of an Encrypted String, Salt, and Passphrase. You can encrypt your username and password using my MrEncryptor tool here: https://github.com/zghalliwell/MrEncryptor

Once encrypted, plug the Encrypted String, Salt, and Passphrase for the username in the placeholders in lines 27-29. Then plug the Encrypted String, Salt, and Passphrase for the password in the placeholders in lines 30-32.

Finally enter your Jamf Pro URL in line 12. Don't put the "https://" in front of it, just "my.company.URL"

At this point you can copy and paste the script into an Extension Attribute in Jamf Pro. At inventory update, it will use the serial number to look up the management account username of the computer and then check if it has a Secure Token.
