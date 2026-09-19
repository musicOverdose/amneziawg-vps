#!/bin/bash
# ==============================================================================
# UNIVERSAL LINUX VPS NETWORKING & DOCKER AUDIT SCRIPT
# Compatible with: Ubuntu, Debian, CentOS, RHEL, Rocky, Alma, Arch, Alpine
# Safe / Read-Only (Does not modify any files, iptables rules, or services)
# ==============================================================================

echo "======================================================================"
echo "                   VPS SYSTEM & KERNEL AUDIT"
echo "======================================================================"
echo -n "Hostname & Kernel: "
uname -a
echo -n "Uptime & Load: "
uptime
echo -n "RAM Usage: "
free -h

echo ""
echo "======================================================================"
echo "                   SYSCTL & NETWORKING PARAMETERS"
echo "======================================================================"
echo -n "IPv4 Forwarding: "
sysctl -n net.ipv4.ip_forward 2>/dev/null || echo "N/A"
echo -n "IPv6 Forwarding: "
sysctl -n net.ipv6.conf.all.forwarding 2>/dev/null || echo "N/A"
echo -n "TCP Congestion Control: "
sysctl -n net.ipv4.tcp_congestion_control 2>/dev/null || echo "N/A"
echo -n "Default Qdisc: "
sysctl -n net.core.default_qdisc 2>/dev/null || echo "N/A"
echo -n "UDP rmem_max: "
sysctl -n net.core.rmem_max 2>/dev/null || echo "N/A"
echo -n "UDP wmem_max: "
sysctl -n net.core.wmem_max 2>/dev/null || echo "N/A"
echo -n "Conntrack Count / Max: "
echo "$(sysctl -n net.netfilter.nf_conntrack_count 2>/dev/null || echo 'N/A') / $(sysctl -n net.netfilter.nf_conntrack_max 2>/dev/null || echo 'N/A')"

echo ""
echo "======================================================================"
echo "                   NETWORK INTERFACES & MTU"
echo "======================================================================"
ip -brief address show 2>/dev/null || ifconfig -s 2>/dev/null || echo "Unable to query addresses"
echo ""
echo "Interface MTUs:"
ip link show 2>/dev/null | grep -E "mtu|state" || echo "Unable to query interface MTU"

echo ""
echo "======================================================================"
echo "                   ACTIVE LISTENING PORTS (TCP/UDP)"
echo "======================================================================"
ss -tulpn 2>/dev/null || netstat -tulpn 2>/dev/null || echo "Unable to query open ports"

echo ""
echo "======================================================================"
echo "                   DOCKER CONTAINERS STATUS"
echo "======================================================================"
if command -v docker &>/dev/null; then
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || echo "Docker daemon not accessible or not running."
else
    echo "Docker is not installed on this host."
fi

echo ""
echo "======================================================================"
echo "                   AMNEZIAWG STATUS (IF CONTAINER RUNNING)"
echo "======================================================================"
if command -v docker &>/dev/null && docker ps 2>/dev/null | grep -q amneziawg; then
    echo "[+] amneziawg container found. Querying interface status:"
    docker exec amneziawg awg show 2>/dev/null || docker exec amneziawg wg show 2>/dev/null || echo "Container active, but awg command unavailable."
else
    echo "[-] amneziawg container is not currently active."
fi

echo ""
echo "======================================================================"
echo "                   DOCKER IPTABLES FORWARDING AUDIT"
echo "======================================================================"
iptables -L DOCKER -v -n --line-numbers 2>/dev/null || echo "iptables read error or nftables in use."

echo ""
echo "======================================================================"
echo "                   AUDIT COMPLETE"
echo "======================================================================"
