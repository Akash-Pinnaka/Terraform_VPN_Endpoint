client
dev tun
proto udp
remote ${server_address} ${vpn_port}
remote-random-hostname
resolv-retry infinite
nobind
remote-cert-tls server
cipher AES-256-GCM
verb 3
<ca>
${ca_cert}
</ca>

<cert>
${client_cert}
</cert>

<key>
${client_key}
</key>

reneg-sec 0

verify-x509-name ${server_cn} name