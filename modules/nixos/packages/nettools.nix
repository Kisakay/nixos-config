{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    windterm

    mtr
    traceroute
    tcpdump
    wireshark
    tshark
    termshark

    dig
    dnsutils
    doggo
    bind

    nmap
    masscan
    arp-scan

    xh
    httpie

    gping
    fping

    iperf3
    iperf2
    speedtest-cli

    iftop
    bmon
    nload
    iptraf-ng
    bandwhich
    vnstat
    darkstat
    tcptrack

    netcat
    socat
    whois

    bird2
    exabgp
    nftables
    conntrack-tools
    bridge-utils

    ethtool
    iproute2

    ngrep
    dsniff
    netsniff-ng

    wireguard-tools
    sshfs

    ipcalc
    sipcalc

    coturn
  ];
}
