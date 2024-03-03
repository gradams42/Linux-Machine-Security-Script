configure_iptables() {
  # iptables
  apt install iptables-persistent -y

  # Flush existing rules
  iptables -F
  
  # Defaults
  iptables -P INPUT DROP
  iptables -P FORWARD DROP
  iptables -P OUTPUT ACCEPT
  
  # Accept loopback input
  iptables -A INPUT -i lo -p all -j ACCEPT
  
  # Allow three-way Handshake
  iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  
  # Stop Masked Attacks
  iptables -A INPUT -p icmp --icmp-type 13 -j DROP
  iptables -A INPUT -p icmp --icmp-type 17 -j DROP
  iptables -A INPUT -p icmp --icmp-type 14 -j DROP
  iptables -A INPUT -p icmp -m limit --limit 1/second -j ACCEPT
  
  # Discard invalid Packets
  iptables -A INPUT -m state --state INVALID -j DROP
  iptables -A FORWARD -m state --state INVALID -j DROP
  iptables -A OUTPUT -m state --state INVALID -j DROP
  
  # Drop Spoofing attacks
  iptables -A INPUT -s 10.0.0.0/8 -j DROP
  iptables -A INPUT -s 169.254.0.0/16 -j DROP
  iptables -A INPUT -s 172.16.0.0/12 -j DROP
  iptables -A INPUT -s 127.0.0.0/8 -j DROP
  iptables -A INPUT -s 192.168.0.0/24 -j DROP
  iptables -A INPUT -s 224.0.0.0/4 -j DROP
  iptables -A INPUT -d 224.0.0.0/4 -j DROP
  iptables -A INPUT -s 240.0.0.0/5 -j DROP
  iptables -A INPUT -d 240.0.0.0/5 -j DROP
  iptables -A INPUT -s 0.0.0.0/8 -j DROP
  iptables -A INPUT -d 0.0.0.0/8 -j DROP
  iptables -A INPUT -d 239.255.255.0/24 -j DROP
  iptables -A INPUT -d 255.255.255.255 -j DROP
  
  # Drop packets with excessive RST to avoid Masked attacks
  iptables -A INPUT -p tcp -m tcp --tcp-flags RST RST -m limit --limit 2/second --limit-burst 2 -j ACCEPT
  
  # Block ips doing portscan for 24 hours
  iptables -A INPUT   -m recent --name portscan --rcheck --seconds 86400 -j DROP
  iptables -A FORWARD -m recent --name portscan --rcheck --seconds 86400 -j DROP
  
  # After 24 hours remove IP from block list
  iptables -A INPUT   -m recent --name portscan --remove
  iptables -A FORWARD -m recent --name portscan --remove
  
  # Allow ssh
  iptables -A INPUT -p tcp -m tcp --dport 141 -j ACCEPT
  
  # Allow Ping
  iptables -A INPUT -p icmp --icmp-type 0 -j ACCEPT
  
  # Allow one ssh connection at a time
  iptables -A INPUT -p tcp --syn --dport 141 -m connlimit --connlimit-above 2 -j REJECT
  
  iptables-save > /etc/iptables/rules.v4
  ip6tables-save > /etc/iptables/rules.v6
}