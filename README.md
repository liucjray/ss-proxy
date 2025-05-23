# ss-proxy

### surfshark tw static ip
- 89.117.42.62

### surfshark jp static ip
- 138.199.22.136
 
### surfshark sg static ip
-146.70.192.158

### docker build and up
docker stop vpn-proxy vpn-proxy-jp vpn-proxy-sg  true
docker rm vpn-proxy vpn-proxy-jp vpn-proxy-sg  true
docker-compose build
docker-compose up -d --remove-orphans


### curl test
curl -m 5 ipinfo.io
curl -x http://localhost:3128 -m 5 ipinfo.io
curl -x http://localhost:3129 -m 5 ipinfo.io
curl -x http://localhost:3130 -m 5 ipinfo.io

### log
docker logs -f vpn-proxy-jp
docker logs -f vpn-proxy-sg
docker exec vpn-proxy-jp cat /vpn/vpn.log
docker exec vpn-proxy-sg cat /vpn/vpn.log

### 備註
surfshark 的 CA 都是固定的
每個國家的唯一區別只有在 remote 參數會不同
使用方式可以先到 ss 後台
VPN -> Manual setup 
專案使用的是 OpenVPN
找到 Credentials 將 Username, Password 放到 auth.txt 中
Location 目前使用了 jp 和 sg
若想使用 固定 IP， Server IP 配置於 docker-compose.yml 中
若不想使用 固定 IP， Server Address 配置於 docker-compose.yml 中