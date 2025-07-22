#!/bin/bash

# ========== Setup ==========
mkdir -p ~/Projects
mv ~/Downloads/TarDocs.tar ~/Projects/
cd ~/Projects
tar -xvf TarDocs.tar
ls ~/Projects/TarDocs/Documents/

# ========== Tar Archive (Excluding Java) ==========
tar --exclude='Java' -cvf Javaless_Docs.tar TarDocs/Documents/
tar -tf Javaless_Docs.tar | grep Java  # Should return nothing

# ========== Optional Incremental Archive ==========
sudo tar --create --gzip --file=logs_backup.tar.gz --listed-incremental=snapshot.file /var/log

# ========== Create Cron Job for auth.log Backup ==========
(crontab -l 2>/dev/null; echo "0 6 * * 3 tar -czf /auth_backup.tgz /var/log/auth.log") | crontab -

# ========== Create Backup Directories ==========
mkdir -p ~/backups/{freemem,diskuse,openlist,freedisk}

# ========== system.sh Script ==========
cat << 'EOF' > ~/system.sh
#!/bin/bash
free -h > ~/backups/freemem/free_mem.txt
df -h > ~/backups/diskuse/disk_usage.txt
lsof > ~/backups/openlist/open_list.txt
du -h > ~/backups/freedisk/free_disk.txt
EOF

chmod +x ~/system.sh
sudo ~/system.sh

# ========== Optional: Automate system.sh Weekly ==========
sudo ln -s ~/system.sh /etc/cron.weekly/system-monitor

# ========== (Optional) Auditd Setup ==========
sudo systemctl status auditd
sudo nano /etc/audit/auditd.conf  # Set max_log_file = 35, num_logs = 7
sudo nano /etc/audit/rules.d/audit.rules

# Inside audit.rules:
# -w /etc/shadow -p wra -k hashpass_audit
# -w /etc/passwd -p wra -k userpass_audit
# -w /var/log/auth.log -p wra -k authlog_audit

sudo systemctl restart auditd
sudo auditctl -l
sudo aureport -au

# Create new user (simulating attacker)
sudo useradd attacker
sudo aureport --modification

# Watch /var/log/cron for changes
sudo auditctl -w /var/log/cron -p wra -k cron_watch
sudo auditctl -l
