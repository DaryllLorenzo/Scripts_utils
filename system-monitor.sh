#!/bin/bash
# system-monitor.sh - Real-time system monitor with statistics

# Global variables
start_time=$(date +%s)
update_interval=1
total_updates=0

# Variables for peaks
max_cpu=0
max_mem=0
max_swap=0
rx_bytes_initial=$(cat /sys/class/net/$(ip route | grep default | awk '{print $5}')/statistics/rx_bytes 2>/dev/null || echo 0)
tx_bytes_initial=$(cat /sys/class/net/$(ip route | grep default | awk '{print $5}')/statistics/tx_bytes 2>/dev/null || echo 0)
total_rx=0
total_tx=0

# Function to capture CTRL+C and show statistics
trap 'show_stats' INT

# Function to get active network interface
get_active_interface() {
    ip route | grep default | awk '{print $5}' | head -1
}

# Function to get network traffic
get_network_traffic() {
    local interface=$1
    local rx_bytes=$(cat /sys/class/net/$interface/statistics/rx_bytes 2>/dev/null || echo 0)
    local tx_bytes=$(cat /sys/class/net/$interface/statistics/tx_bytes 2>/dev/null || echo 0)
    echo "$rx_bytes $tx_bytes"
}

# Function to show final statistics
show_stats() {
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    local interface=$(get_active_interface)
    
    # Get final traffic
    local traffic_data=$(get_network_traffic "$interface")
    local rx_bytes_final=$(echo $traffic_data | awk '{print $1}')
    local tx_bytes_final=$(echo $traffic_data | awk '{print $2}')
    
    # Calculate total traffic during session
    local rx_total=$((rx_bytes_final - rx_bytes_initial))
    local tx_total=$((tx_bytes_final - tx_bytes_initial))
    
    clear
    echo "=== SESSION STATISTICS ==="
    echo ""
    
    # 1. Time
    echo "TIME"
    echo "  Duration: $duration seconds ($((duration/60)) minutes)"
    echo "  Updates: $total_updates"
    echo "  Frequency: $update_interval second(s)"
    echo ""
    
    # 2. Usage peaks
    echo "USAGE PEAKS"
    echo "  CPU max: ${max_cpu}%"
    echo "  Memory max: ${max_mem}%"
    echo "  Swap max: ${max_swap}%"
    echo ""
    
    # 3. Network
    echo "NETWORK"
    if [ "$interface" != "" ]; then
        echo "  Interface: $interface"
        echo "  Total download: $((rx_total/1024/1024)) MB"
        echo "  Total upload: $((tx_total/1024/1024)) MB"
        echo "  Avg download: $((rx_total/1024/duration)) KB/s"
        echo "  Avg upload: $((tx_total/1024/duration)) KB/s"
    else
        echo "  No active network interface"
    fi
    echo ""
    
    # 4. System
    echo "SYSTEM"
    echo "  Host: $(hostname)"
    echo "  Kernel: $(uname -r)"
    echo "  System uptime: $(uptime -p | sed 's/up //')"
    echo ""
    
    echo "Report generated: $(date)"
    exit 0
}

# Main loop
while true; do
    clear
    
    # Header
    echo "=== SYSTEM MONITOR ==="
    echo "Active time: $(( $(date +%s) - start_time ))s | Updates: $total_updates"
    echo ""
    
    # 1. CPU
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{printf "%.0f", $2}')
    echo "CPU: ${cpu_usage}%"
    [ "$cpu_usage" -gt "$max_cpu" ] && max_cpu=$cpu_usage
    
    # 2. Memory
    mem_info=$(free | awk '/^Mem:/ {printf "%.0f", $3/$2*100}')
    swap_info=$(free | awk '/^Swap:/ {printf "%.0f", $3/$2*100}')
    echo "Memory: ${mem_info}% | Swap: ${swap_info}%"
    
    [ "$mem_info" -gt "$max_mem" ] && max_mem=$mem_info
    [ "$swap_info" -gt "$max_swap" ] && max_swap=$swap_info
    
    # 3. Disks
    disk_root=$(df -h / --output=pcent | tail -1 | tr -d ' %')
    echo "Disk Root: ${disk_root}%"
    
    # 4. Current network
    interface=$(get_active_interface)
    if [ "$interface" != "" ]; then
        traffic_data=$(get_network_traffic "$interface")
        rx_bytes_current=$(echo $traffic_data | awk '{print $1}')
        tx_bytes_current=$(echo $traffic_data | awk '{print $2}')
        
        # Calculate speed per second (approximate)
        if [ $total_updates -gt 0 ]; then
            rx_speed=$(((rx_bytes_current - total_rx) / 1024))
            tx_speed=$(((tx_bytes_current - total_tx) / 1024))
        fi
        
        total_rx=$rx_bytes_current
        total_tx=$tx_bytes_current
        
        echo "Network ($interface): ↓${rx_speed:-0}KB/s ↑${tx_speed:-0}KB/s"
    fi
    
    # 5. Docker (if exists)
    if command -v docker &>/dev/null; then
        containers_running=$(docker ps -q | wc -l)
        echo "Docker: $containers_running active containers"
    fi
    
    total_updates=$((total_updates + 1))
    sleep $update_interval
done