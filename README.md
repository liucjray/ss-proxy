# ss-proxy

### surfshark tw static ip
- 89.117.42.62

### surfshark jp static ip
- 138.199.22.136
 
### surfshark sg static ip
- 146.70.192.158

### docker build and up
```
docker stop proxy-nginx vpn-proxy-jp vpn-proxy-sg || true
docker rm proxy-nginx vpn-proxy-jp vpn-proxy-sg || true
docker-compose build
docker-compose up -d --remove-orphans
```


### curl test
```
curl -m 5 ipinfo.io
curl -x http://localhost:3128 -m 5 ipinfo.io
curl -x http://localhost:3129 -m 5 ipinfo.io
curl -x http://localhost:3130 -m 5 ipinfo.io

curl -x http://rayray123:rayray123@localhost:3129 -m 5 ipinfo.io
```

### log
```
docker logs -f vpn-proxy-jp
docker logs -f vpn-proxy-sg
docker exec vpn-proxy-jp cat /vpn/vpn.log
docker exec vpn-proxy-sg cat /vpn/vpn.log
```


### Surfshark VPN 配置備註

#### 基本資訊
- **CA 證書**：Surfshark 的所有 CA 證書都是固定的，不因國家而異。
- **唯一差異**：每個國家的配置差異僅在於 `remote` 參數（用於指定 VPN 伺服器）。

#### 配置步驟
1. **獲取 VPN 憑證**：
   - **路徑**：前往 Surfshark 後台：<span class="highlight">VPN -> Manual Setup</span>。
   - **協議**：專案使用 **OpenVPN**。
   - **憑證**：在 `Credentials` 區域找到：
     - `Username`
     - `Password`
   - **操作**：將上述資訊填入專案中的 `auth.txt` 檔案。

2. **選擇服務器位置**：
   - **已選位置**：
     - `jp`（日本）
     - `sg`（新加坡）
   - **注意**：可根據需求新增其他位置。

3. **配置 `docker-compose.yml`**：
   - **選項 1：固定 IP**  
     將 `Server IP` 直接配置在 `docker-compose.yml` 中。
   - **選項 2：動態地址**  
     使用 `Server Address` 配置在 `docker-compose.yml` 中，代替固定 IP。