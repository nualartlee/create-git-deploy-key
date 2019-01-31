#!/usr/bin/env bash

# Creates an ssh key with no password and
# adds it as the ID for a particular git project host
#
# Useful, as github does not allow use of the same deploy key for
# multiple projects.

# Set the repository name to that of the containing directory
reponame=${PWD##*/}

# Set the key file name
keyfile=~/.ssh/id_$reponame

# Check if the key already exists
if [ -e "$keyfile" ]; then
    echo "A key for the repository $reponame already exists."
    echo "Do you want to over-write?"
    read -p "(yes/no):" yn
    case $yn in
        [Yy]* ) rm $keyfile;;
        [Nn]* ) echo "Cancelled"; exit;;
        * ) echo "Please answer yes or no.";;
    esac
fi

# Create the key
ssh-keygen -t ed25519 -N '' -f $keyfile

# Create an ssh config if it does not exists
sshconfig=~/.ssh/config
if [ -e "$sshconfig" ]; then
    echo "ssh config exists"
else
    touch $sshconfig
fi

# Update any previous host and key info
if grep -q "Host $reponame" "$sshconfig"; then
    echo "Updating host in .ssh/config"
    perl -0pe 's/Host.*IdentityFile.*\R/Host $keyfile\R  HostName github.com\R  User git\R  Identityfile $keyfile\R/gms' $sshconfig 2>&1 > /dev/null
# Else add the new host and key info to ssh config
else
    echo
    echo "Adding host to .ssh/config"
    echo "Host $reponame" >> $sshconfig
    echo "  HostName github.com" >> $sshconfig
    echo "  User git" >> $sshconfig
    echo "  IdentityFile $keyfile" >> $sshconfig
fi
echo
echo "$sshconfig:"
cat $sshconfig

# Update git remote host name
git remote rm origin
git remote add origin git@$reponame:nualartlee/$reponame.git

# Print the public key for easy reference
echo
echo "Keys created"
echo "Public Key ($keyfile.pub):"
echo
cat "$keyfile.pub"
echo
