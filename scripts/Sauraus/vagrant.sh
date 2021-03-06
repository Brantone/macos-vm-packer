#!/bin/sh
date > /etc/box_build_time
OSX_VERS=$(sw_vers -productVersion | awk -F "." '{print $2}')

# Set computer/hostname
COMPNAME=macos-10-${OSX_VERS}
scutil --set ComputerName ${COMPNAME}
scutil --set HostName ${COMPNAME}.vagrantup.com

# Packer passes boolean user variables through as '1', but this might change in
# the future, so also check for 'true'.
if [ "$INSTALL_VAGRANT_KEYS" = "true" ] || [ "$INSTALL_VAGRANT_KEYS" = "1" ]; then
	echo "Installing vagrant keys for $USERNAME user"
	mkdir "/Users/$USERNAME/.ssh"
	chmod 700 "/Users/$USERNAME/.ssh"
	curl -L 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub' > "/Users/$USERNAME/.ssh/authorized_keys"
	chmod 600 "/Users/$USERNAME/.ssh/authorized_keys"
	chown -R "$USERNAME" "/Users/$USERNAME/.ssh"
fi

# Create a group and assign the user to it
dseditgroup -o create "$USERNAME"
dseditgroup -o edit -a "$USERNAME" "$USERNAME"

# Skip iCloud setup for $USERNAME
sw_vers=$(sw_vers -productVersion)
sw_build=$(sw_vers -buildVersion)
mkdir -p "/Users/$USERNAME/LibraryPreferences"
defaults write "/Users/$USERNAME/Library/Preferences/com.apple.SetupAssistant" DidSeeCloudSetup -bool TRUE
defaults write "/Users/$USERNAME/Library/Preferences/com.apple.SetupAssistant" GestureMovieSeen none
defaults write "/Users/$USERNAME/Library/Preferences/com.apple.SetupAssistant" LastSeenCloudProductVersion "${sw_vers}"
defaults write "/Users/$USERNAME/Library/Preferences/com.apple.SetupAssistant" LastSeenBuddyBuildVersion "${sw_build}"      
