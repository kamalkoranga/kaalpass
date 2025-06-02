#!/bin/bash

# Replace with your linux username
USERNAME="YOUR_USERNAME"

# Same as in the Flutter app
SECRET="YOUR_SUPER_SECRET"

# Generate today's UTC date string
DATE_KEY=$(date +%Y-%m-%d)

# Generate SHA256 hash
PASSWORD_HASH=$(echo -n "$SECRET$DATE_KEY" | sha256sum | awk '{print $1}')

# Extract 14-character alphanumeric password
PASSWORD=$(echo "$PASSWORD_HASH" | tr -cd '[:alnum:]' | cut -c1-14)

# Test: Print the password
#echo "Generated password for $USERNAME: $PASSWORD"

# Set the user's password
echo "$USERNAME:$PASSWORD" | sudo chpasswd
