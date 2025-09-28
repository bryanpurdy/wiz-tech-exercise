#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -xe

# Prevent interactive prompts during package installation
export DEBIAN_FRONTEND=noninteractive

# Variables from Terraform
S3_BUCKET="${s3_bucket}"

echo "Starting MongoDB setup script at $(date)"
echo "S3 Bucket: $S3_BUCKET"

# Configure dpkg to avoid service restart prompts
echo '* libraries/restart-without-asking boolean true' | debconf-set-selections

# Update packages with non-interactive flags
apt-get update -y
echo "Package update completed"

# Install MongoDB 7.0 directly (1+ year outdated as required - from 2023)
echo "Installing MongoDB 7.0..."
curl -fsSL https://pgp.mongodb.com/server-7.0.asc | gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/7.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-7.0.list

apt-get update -y

# Install MongoDB 7.0 and mongosh
apt-get install -y mongodb-org mongodb-mongosh

# Start and enable MongoDB
systemctl start mongod
systemctl enable mongod
echo "MongoDB installation completed"

# Wait for MongoDB to start
echo "Waiting for MongoDB to start..."
sleep 15

# Create admin user with weak password (security weakness as required)
echo "Creating admin user..."
mongosh --eval "
db = db.getSiblingDB('admin');
db.createUser({
  user: 'admin',
  pwd: 'SuperWeakP@ss!',
  roles: [{role: 'root', db: 'admin'}]
});
"

# Verify MongoDB is running
if systemctl is-active --quiet mongod; then
  echo "MongoDB is running"
else
  echo "MongoDB failed to start"
  systemctl status mongod
  exit 1
fi

# Install AWS CLI for S3 uploads
echo "Installing AWS CLI..."
apt-get install -y awscli

# Create backup script
echo "Creating backup script..."
cat > /home/ubuntu/mongo-backup.sh << 'EOL'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="mongo_backup_$DATE.tar.gz"
S3_BUCKET="${s3_bucket}"

echo "Starting MongoDB backup at $(date)" >> /home/ubuntu/mongo-backup.log

# Create backup directory
mkdir -p /tmp/mongo-backup

# Dump MongoDB with authentication
mongodump --host localhost:27017 --username admin --password 'SuperWeakP@ss!' --authenticationDatabase admin --out /tmp/mongo-backup/

# Compress backup
cd /tmp
tar -czf "$BACKUP_FILE" mongo-backup/

# Upload to S3 (publicly readable bucket)
aws s3 cp "$BACKUP_FILE" "s3://$S3_BUCKET/$BACKUP_FILE"

# Cleanup local backup
rm -rf /tmp/mongo-backup /tmp/"$BACKUP_FILE"

echo "Backup completed and uploaded to s3://$S3_BUCKET/$BACKUP_FILE at $(date)" >> /home/ubuntu/mongo-backup.log
EOL

# Make backup script executable
chmod +x /home/ubuntu/mongo-backup.sh
chown ubuntu:ubuntu /home/ubuntu/mongo-backup.sh

# Set up daily cron job for backups
echo "Setting up daily backup cron job..."
sudo -u ubuntu bash -c 'echo "0 2 * * * /home/ubuntu/mongo-backup.sh" | crontab -'

# Run initial backup to test
echo "Running initial backup test..."
su - ubuntu -c "/home/ubuntu/mongo-backup.sh"

echo "MongoDB setup completed successfully at $(date)"