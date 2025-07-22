#!/bin/bash
echo "===== System Resource Report ====="
echo ""

echo "--- Uptime ---"
uptime
echo ""

echo "--- Free Memory (MB) ---"
free -m
echo ""

echo "--- Disk Usage ---"
df -h /
echo ""

echo "--- CPU Load (1, 5, 15 min) ---"
cat /proc/loadavg
echo ""

echo "--- Top 5 Memory-Consuming Processes ---"
ps aux --sort=-%mem | head -n 6
echo ""

echo "--- Top 5 CPU-Consuming Processes ---"
ps aux --sort=-%cpu | head -n 6
echo ""

echo "===== End of Report ====="
