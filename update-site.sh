#!/bin/bash

# Define variables
REMOTE_HOST="stupid-projects.com"
REMOTE_USER="root"
REMOTE_PATH="/root/stupid-projects.com/html"
LOCAL_PATH="./_site/."
BACKUP_PATH="./backups"
CURRENT_DATE=$(date +"%Y%m%d")
SSH_KEY_PATH="~/.ssh/id_rsa"

# Set the RSYNC_RSH environment variable
export RSYNC_RSH="ssh -i ${SSH_KEY_PATH}"

# Connect to remote server and create a backup of the remote folder
ssh -i ${SSH_KEY_PATH} ${REMOTE_USER}@${REMOTE_HOST} "tar -czf /root/html_backup_${CURRENT_DATE}.tar.gz ${REMOTE_PATH}"

# Download the backup to local backup path
scp -i ${SSH_KEY_PATH} ${REMOTE_USER}@${REMOTE_HOST}:/root/html_backup_${CURRENT_DATE}.tar.gz ${BACKUP_PATH}

# Delete the backup file from the remote host
ssh -i ${SSH_KEY_PATH} ${REMOTE_USER}@${REMOTE_HOST} "rm /root/html_backup_${CURRENT_DATE}.tar.gz"

# Clear the "/root/html" folder on the remote host
ssh -i ${SSH_KEY_PATH} ${REMOTE_USER}@${REMOTE_HOST} "rm -rf ${REMOTE_PATH}/*"

# Compare local and remote files and upload if different or missing
rsync -avz --delete ${LOCAL_PATH} ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}

# Execute "docker-compose restart nginx" in the "/root/stupid-projects.com" directory
ssh -i ${SSH_KEY_PATH} -t ${REMOTE_USER}@${REMOTE_HOST} "cd /root/stupid-projects.com && docker compose restart nginx"