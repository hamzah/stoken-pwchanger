#!/bin/sh

#########################################################################################
#
#                           SecureToken Admin Password Changer
# Changes the password for a SecureToken enabled admin account by generating a temporary
# admin to perform the password change. This script is designed to be run as a policy
# in Jamf or similar MDM solutions.
#
#
# Author: Hamzah Batha
# Date: 21/07/2024
# Version: 1.0
# License: MIT
# GitHub Repo: github.com/hamzah/stoken-pwchanger
#
#########################################################################################

# Define the target account username and passwords (must be SecureToken enabled)
target_user="TARGET_USERNAME_HERE"
current_password="CURRENT_PASSWORD_HERE"
new_password="NEW_PASSWORD_HERE"

# Define the temporary admin account details
temp_admin_username="stoken-pwchanger"
temp_admin_fullname="AdminPasswordChanger"
temp_admin_password=$(openssl rand -base64 16)

# Create the temporary admin account
create_temp_admin() {
    sysadminctl -addUser $temp_admin_username -fullName $temp_admin_fullname -password $temp_admin_password -admin
}

# Enable SecureToken for the temporary admin account
enable_securetoken() {
    sysadminctl -adminUser $target_user -adminPassword $current_password -secureTokenOn $temp_admin_username -password $temp_admin_password
}

# Change the target user's password
change_password() {
    sysadminctl -adminUser $temp_admin_username -adminPassword $temp_admin_password -resetPasswordFor $target_user -newPassword $new_password
}

# Change the target user's keychain password
change_keychain_password() {
    security set-keychain-password -o $current_password -p $new_password /Users/$target_user/Library/Keychains/login.keychain
}

# Delete the temporary admin account
delete_temp_admin() {
    sysadminctl -deleteUser $temp_admin_username
}

# Main script execution
create_temp_admin
enable_securetoken
change_password
change_keychain_password
delete_temp_admin

exit 0
