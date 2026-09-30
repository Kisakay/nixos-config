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
    # tcptrack 1.4.3 (2017) ne compile plus avec GCC 15 : -Werror + unused-but-set-variable
    # (TCContainer.cc:180). On retire -Werror en attendant un fix upstream.
    (tcptrack.overrideAttrs (oldAttrs: {
      postPatch = (oldAttrs.postPatch or "") + ''
        grep -rl -- "-Werror" . 2>/dev/null | xargs -r sed -i 's/-Werror//g' || true
      '';
    }))

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
