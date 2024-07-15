#!/bin/bash

# Define variables
REPO_URL="https://github.com/qingfengliu0/qliu.ca.git"
DEST_DIR="/var/www/qliu_ca"
NGINX_SERVICE="nginx"

# Clone or pull the latest changes from the GitHub repository
if [ ! -d "$DEST_DIR" ]; then
    echo "Cloning repository..."
    git clone $REPO_URL $DEST_DIR
else
    echo "Pulling latest changes..."
    cd $DEST_DIR
    git pull origin main
fi

# Check if there are changes
if [ $? -eq 0 ]; then
    echo "Changes detected, restarting Nginx..."
    sudo systemctl restart $NGINX_SERVICE
    echo "Deployment completed successfully."

else
    echo "No changes detected, Nginx restart not required."
fi
