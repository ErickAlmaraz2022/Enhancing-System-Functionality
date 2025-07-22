#!/bin/bash
# commands.sh — Master Command List for Linux System Hardening Project

# Step 1: Tar File Management
mkdir -p ~/Projects
find /home -name "TarDocs.tar" 2>/dev/null
mv /home/kali/Downloads/TarDocs.tar ~/Projects/
cd ~/Projects
tar -xvf TarDocs.tar
ls -l ~/Projects/TarDocs/Documents/
tar --exclude='Java' -cvf Javaless_Docs.tar TarDocs/Documents/
tar -tf Javaless_Docs.tar | grep Java
tar --create --gzip --file=logs_backup.tar.gz --listed-incremental=snapshot.file /var/log

# Step 2: Cron Jobs for Backup
crontab -e
# Add to crontab: 0 6 * * 3 tar -czf /auth_backup.tgz /var/log/auth.log

# Step 3: System Monitoring Script
mkdir -p ~/backups/{freemem,diskuse,openlist,freedisk}
nano ~/system.sh
chmod +x ~/system.sh
sudo ./system.sh
sudo ln -s ~/system.sh /etc/cron.weekly/system-monitor

# Step 4: auditd Setup
sudo apt update
sudo apt install auditd -y
sudo systemctl start auditd
sudo systemctl enable auditd
systemctl status auditd

# Step 4.2: Configure auditd
nano /etc/audit/auditd.conf
# Set:
# num_logs = 7
# max_log_file = 35

# Step 4.3: Add Audit Rules
sudo nano /etc/audit/rules.d/audit.rules
# Add:
# -w /etc/shadow -p wra -k hashpass_audit
# -w /etc/passwd -p wra -k userpass_audit
# -w /var/log/auth.log -p wra -k authlog_audit

# Step 4.4: Apply Rules
sudo systemctl restart auditd
sudo auditctl -l

# Step 4.5: View Audit Reports
sudo aureport -au
sudo aureport -m

# Step 4.6: Simulate Modification
sudo useradd attacker
# Then:
sudo aureport -m

# Step 4.7: Monitor Cron Activity
sudo auditctl -w /var/log/cron -p wra -k cron_watch

# Step 4.8: Verify Rule
sudo auditctl -l | grep cron_watch

# Step 5.0: Trigger Cron Event
crontab -e
# Add comment:
# # test audit trigger

# Step 5.1: Search Audit Logs
sudo ausearch -k cron_watch
sudo aureport --file | grep cron
sudo ausearch -k cron_watch --start recent
