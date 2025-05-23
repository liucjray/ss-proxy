#!/bin/sh
# 打印環境信息
echo "Container started at $(date)"
openvpn --version
squid --version

# 打印環境變數以進行調試
echo "VPN_SERVER_JP_IP=$VPN_SERVER_JP_IP"
echo "VPN_SERVER_JP_PORT=$VPN_SERVER_JP_PORT"
echo "VPN_SERVER_SG_IP=$VPN_SERVER_SG_IP"
echo "VPN_SERVER_SG_PORT=$VPN_SERVER_SG_PORT"
echo "SQUID_PORT_JP=$SQUID_PORT_JP"
echo "SQUID_PORT_SG=$SQUID_PORT_SG"

# 生成 OpenVPN 配置文件
REMOTE_SERVERS=""
if [ ! -z "$VPN_SERVER_JP_IP" ] && [ ! -z "$VPN_SERVER_JP_PORT" ]; then
    REMOTE_SERVERS="remote $VPN_SERVER_JP_IP $VPN_SERVER_JP_PORT"
fi
if [ ! -z "$VPN_SERVER_SG_IP" ] && [ ! -z "$VPN_SERVER_SG_PORT" ]; then
    REMOTE_SERVERS="remote $VPN_SERVER_SG_IP $VPN_SERVER_SG_PORT"
fi

echo "REMOTE_SERVERS=$REMOTE_SERVERS"
if [ -z "$REMOTE_SERVERS" ]; then
    echo "Error: No VPN servers specified"
    exit 1
fi

# 使用 printf 生成配置文件
{
    echo "client"
    echo "dev tun"
    echo "proto udp"
    echo "$REMOTE_SERVERS"
    echo "nobind"
    echo "tun-mtu 1500"
    echo "mssfix 1450"
    echo "ping 15"
    echo "ping-restart 0"
    echo "reneg-sec 0"
    echo "remote-cert-tls server"
    echo "auth-user-pass"
    echo "auth-nocache"
    echo "verb 3"
    echo "fast-io"
    echo "cipher AES-256-CBC"
    echo "auth SHA512"
    cat << 'EOF'
<ca>
-----BEGIN CERTIFICATE-----
MIIFTTCCAzWgAwIBAgIJAMs9S3fqwv+mMA0GCSqGSIb3DQEBCwUAMD0xCzAJBgNV
BAYTAlZHMRIwEAYDVQQKDAlTdXJmc2hhcmsxGjAYBgNVBAMMEVN1cmZzaGFyayBS
b290IENBMB4XDTE4MDMxNDA4NTkyM1oXDTI4MDMxMTA4NTkyM1owPTELMAkGA1UE
BhMCVkcxEjAQBgNVBAoMCVN1cmZzaGFyazEaMBgGA1UEAwwRU3VyZnNoYXJrIFJv
b3QgQ0EwggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQDEGMNj0aisM63o
SkmVJyZPaYX7aPsZtzsxo6m6p5Wta3MGASoryRsBuRaH6VVa0fwbI1nw5ubyxkua
Na4v3zHVwuSq6F1p8S811+1YP1av+jqDcMyojH0ujZSHIcb/i5LtaHNXBQ3qN48C
c7sqBnTIIFpmb5HthQ/4pW+a82b1guM5dZHsh7q+LKQDIGmvtMtO1+NEnmj81BAp
FayiaD1ggvwDI4x7o/Y3ksfWSCHnqXGyqzSFLh8QuQrTmWUm84YHGFxoI1/8AKdI
yVoB6BjcaMKtKs/pbctk6vkzmYf0XmGovDKPQF6MwUekchLjB5gSBNnptSQ9kNgn
TLqi0OpSwI6ixX52Ksva6UM8P01ZIhWZ6ua/T/tArgODy5JZMW+pQ1A6L0b7egIe
ghpwKnPRG+5CzgO0J5UE6gv000mqbmC3CbiS8xi2xuNgruAyY2hUOoV9/BuBev8t
tE5ZCsJH3YlG6NtbZ9hPc61GiBSx8NJnX5QHyCnfic/X87eST/amZsZCAOJ5v4EP
SaKrItt+HrEFWZQIq4fJmHJNNbYvWzCE08AL+5/6Z+lxb/Bm3dapx2zdit3x2e+m
iGHekuiE8lQWD0rXD4+T+nDRi3X+kyt8Ex/8qRiUfrisrSHFzVMRungIMGdO9O/z
CINFrb7wahm4PqU2f12Z9TRCOTXciQIDAQABo1AwTjAdBgNVHQ4EFgQUYRpbQwyD
ahLMN3F2ony3+UqOYOgwHwYDVR0jBBgwFoAUYRpbQwyDahLMN3F2ony3+UqOYOgw
DAYDVR0TBAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAgEAn9zV7F/XVnFNZhHFrt0Z
S1Yqz+qM9CojLmiyblMFh0p7t+Hh+VKVgMwrz0LwDH4UsOosXA28eJPmech6/bjf
ymkoXISy/NUSTFpUChGO9RabGGxJsT4dugOw9MPaIVZffny4qYOc/rXDXDSfF2b+
303lLPI43y9qoe0oyZ1vtk/UKG75FkWfFUogGNbpOkuz+et5Y0aIEiyg0yh6/l5Q
5h8+yom0HZnREHhqieGbkaGKLkyu7zQ4D4tRK/mBhd8nv+09GtPEG+D5LPbabFVx
KjBMP4Vp24WuSUOqcGSsURHevawPVBfgmsxf1UCjelaIwngdh6WfNCRXa5QQPQTK
ubQvkvXONCDdhmdXQccnRX1nJWhPYi0onffvjsWUfztRypsKzX4dvM9k7xnIcGSG
EnCC4RCgt1UiZIj7frcCMssbA6vJ9naM0s7JF7N3VKeHJtqe1OCRHMYnWUZt9vrq
X6IoIHlZCoLlv39wFW9QNxelcAOCVbD+19MZ0ZXt7LitjIqe7yF5WxDQN4xru087
FzQ4Hfj7eH1SNLLyKZkA1eecjmRoi/OoqAt7afSnwtQLtMUc2bQDg6rHt5C0e4dC
LqP/9PGZTSJiwmtRHJ/N5qYWIh9ju83APvLm/AGBTR2pXmj9G3KdVOkpIC7L35dI
623cSEC3Q3UZutsEm/UplsM=
-----END CERTIFICATE-----
</ca>
key-direction 1
<tls-auth>
#
# 2048 bit OpenVPN static key
#
-----BEGIN OpenVPN Static key V1-----
b02cb1d7c6fee5d4f89b8de72b51a8d0
c7b282631d6fc19be1df6ebae9e2779e
6d9f097058a31c97f57f0c35526a44ae
09a01d1284b50b954d9246725a1ead1f
f224a102ed9ab3da0152a15525643b2e
ee226c37041dc55539d475183b889a10
e18bb94f079a4a49888da566b9978346
0ece01daaf93548beea6c827d9674897
e7279ff1a19cb092659e8c1860fbad0d
b4ad0ad5732f1af4655dbd66214e552f
04ed8fd0104e1d4bf99c249ac229ce16
9d9ba22068c6c0ab742424760911d463
6aafb4b85f0c952a9ce4275bc821391a
a65fcd0d2394f006e3fba0fd34c4bc4a
b260f4b45dec3285875589c97d3087c9
134d3a3aa2f904512e85aa2dc2202498
-----END OpenVPN Static key V1-----
</tls-auth>
EOF
} > /vpn/vpn.ovpn

echo "Generated /vpn/vpn.ovpn:"
cat /vpn/vpn.ovpn

# 檢查生成的配置文件是否包含 remote 行
if ! grep -q "^remote" /vpn/vpn.ovpn; then
    echo "Error: Generated /vpn/vpn.ovpn does not contain valid remote lines"
    exit 1
fi

# 修復 /vpn/vpn.auth 文件權限
if [ -f "/vpn/vpn.auth" ]; then
    chmod 600 /vpn/vpn.auth
    echo "Fixed permissions for /vpn/vpn.auth"
else
    echo "Error: /vpn/vpn.auth not found"
    exit 1
fi

# 啟動 OpenVPN
echo "Starting OpenVPN..."
openvpn --config /vpn/vpn.ovpn --auth-user-pass /vpn/vpn.auth --daemon --log /vpn/vpn.log

# 等待 VPN 連接建立
echo "Waiting for VPN connection..."
sleep 20

# 驗證 VPN 連接
if ip addr show tun0 > /dev/null 2>&1; then
    echo "VPN connected successfully"
    ip addr show tun0
else
    echo "VPN connection failed"
    cat /vpn/vpn.log
    exit 1
fi

# 設置 SQUID_PORT
if [ ! -z "$SQUID_PORT_JP" ]; then
    export SQUID_PORT=$SQUID_PORT_JP
elif [ ! -z "$SQUID_PORT_SG" ]; then
    export SQUID_PORT=$SQUID_PORT_SG
else
    echo "Error: Neither SQUID_PORT_JP nor SQUID_PORT_SG is set"
    exit 1
fi
echo "SQUID_PORT=$SQUID_PORT"

# 檢查 Squid 配置
echo "Checking Squid configuration..."
envsubst < /etc/squid/squid.conf > /tmp/squid.conf
mv /tmp/squid.conf /etc/squid/squid.conf
echo "Generated /etc/squid/squid.conf:"
cat /etc/squid/squid.conf
squid -k parse || { echo "Squid configuration error"; exit 1; }

# 禁用 IPv6 以消除警告
echo "Disabling IPv6..."
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p

# 啟動 Squid
echo "Starting Squid..."
squid -N -d 1 || { echo "Squid failed to start"; exit 1; }

# 保持容器運行並檢查 Squid 狀態
while true; do
    if ! ps aux | grep -q "[s]quid.*-N"; then
        echo "Squid stopped unexpectedly at $(date)"
        exit 1
    fi
    sleep 60
done