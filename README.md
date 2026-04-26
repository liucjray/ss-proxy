# ss-proxy

基於 Surfshark VPN + Squid 的多地區 HTTP Proxy 解決方案，支援透過 Docker 快速部署日本和新加坡節點的代理服務。

## 功能特點

- ✅ **多地區支援**：日本 (JP) 和新加坡 (SG) 雙節點
- ✅ **認證開關**：預設無需認證，可選擇啟用帳號密碼保護
- ✅ **網路開放**：支援 Tailscale、內網及公網訪問（可配置）
- ✅ **容器化部署**：基於 Docker Compose，一鍵啟動
- ✅ **自動重連**：VPN 斷線自動重連機制

## 架構說明

```
Client → Nginx (3129/3130) → Squid Proxy → OpenVPN → Surfshark VPN → Internet
```

- **Nginx**: TCP 轉發層，負責端口暴露和流量轉發
- **Squid**: HTTP Proxy 服務，支援可選的 Basic 認證
- **OpenVPN**: VPN 客戶端，連接到 Surfshark VPN 伺服器

## 服務端口

| 端口 | 地區 | VPN 伺服器 |
|------|------|------------|
| 3129 | 日本 (Tokyo) | jp-tok-st014.prod.surfshark.com |
| 3130 | 新加坡 (Singapore) | sg-sng-st010.prod.surfshark.com |

## 快速開始

### 1. 構建並啟動服務

```bash
# 停止舊容器（如果存在）
docker stop proxy-nginx vpn-proxy-jp vpn-proxy-sg || true
docker rm proxy-nginx vpn-proxy-jp vpn-proxy-sg || true

# 構建並啟動
docker-compose build
docker-compose up -d

# 查看狀態
docker-compose ps
```

### 2. 驗證服務

```bash
# 本機測試 - 日本節點
curl -x http://localhost:3129 ipinfo.io

# 本機測試 - 新加坡節點
curl -x http://localhost:3130 ipinfo.io
```

## 認證設定

### 預設行為（無需認證）✨

**預設情況下，proxy 不需要認證**，任何人都可以直接連線使用。這適合在私有網路（如 Tailscale）中使用。

### 啟用認證保護

如果需要啟用帳號密碼認證，請修改 `docker-compose.yml` 中的 `ENABLE_AUTH` 環境變數：

```yaml
environment:
  - ENABLE_AUTH=true  # 改為 true 啟用認證
  - PROXY_USER=your_username      # 修改為你的帳號
  - PROXY_PASS=your_password      # 修改為你的密碼
```

修改後重新啟動：
```bash
docker-compose down
docker-compose up -d
```

## 網路配置

### 當前配置：開放所有網路介面

Port 綁定到 `0.0.0.0`，允許從以下位置訪問：
- ✅ 本機 (localhost)
- ✅ 內網 (192.168.x.x)
- ✅ Tailscale 私有網路 (100.x.x.x)
- ✅ 公網（如果有公網 IP）

### 限制為僅本機訪問

如果只想從本機訪問，修改 `docker-compose.yml`：

```yaml
ports:
  - "127.0.0.1:3129:3129"
  - "127.0.0.1:3130:3130"
```

## 測試方法

### 本機測試

#### 無認證模式（預設）
```bash
# 測試日本節點
curl -x http://localhost:3129 ipinfo.io

# 測試新加坡節點
curl -x http://localhost:3130 ipinfo.io
```

#### 有認證模式（ENABLE_AUTH=true）
```bash
curl -x http://username:password@localhost:3129 ipinfo.io
curl -x http://username:password@localhost:3130 ipinfo.io
```

### 遠端測試（透過 Tailscale 或內網）

假設主機 IP 為 `100.119.209.17`：

```bash
# 使用 IP
curl -x http://100.119.209.17:3129 ipinfo.io

# 使用主機名稱（需 DNS 解析）
curl -x http://ray-pve-ubuntu:3129 ipinfo.io
```

### Windows PowerShell 測試

```powershell
curl -x http://100.119.209.17:3129 ipinfo.io
curl -x http://100.119.209.17:3130 ipinfo.io
```

## 瀏覽器代理設定

### Chrome / Edge

1. 設定 → 系統 → 開啟 Proxy 設定
2. 手動設定 Proxy
3. 填入：
   - **HTTP Proxy**: `100.119.209.17` (或你的主機 IP/主機名稱)
   - **Port**: `3129` (日本) 或 `3130` (新加坡)

### Firefox

1. Settings → Network Settings → Manual proxy configuration
2. HTTP Proxy: `100.119.209.17`, Port: `3129` 或 `3130`
3. 勾選 "Also use this proxy for HTTPS"

### macOS / iOS (系統級)

設定 → Wi-Fi → 詳細資訊 → Proxy → 手動設定
- 伺服器: `100.119.209.17`
- 埠: `3129` 或 `3130`

## 日誌查看

```bash
# 查看容器狀態
docker-compose ps

# 查看 Nginx 日誌
docker logs -f proxy-nginx

# 查看日本節點日誌
docker logs -f vpn-proxy-jp

# 查看新加坡節點日誌
docker logs -f vpn-proxy-sg

# 查看 VPN 連線日誌
docker exec vpn-proxy-jp cat /vpn/vpn.log
docker exec vpn-proxy-sg cat /vpn/vpn.log

# 查看 Squid 配置（驗證認證設定）
docker exec vpn-proxy-jp cat /etc/squid/squid.conf
```


## Surfshark VPN 配置

### 基本資訊
- **CA 證書**：所有 CA 證書固定，不因國家而異
- **差異**：僅 `remote` 參數（VPN 伺服器地址）不同

### Surfshark 靜態 IP 列表

| 地區 | 靜態 IP |
|------|---------|
| 台灣 (TW) | 89.117.42.62 |
| 日本 (JP) | 138.199.22.136 |
| 新加坡 (SG) | 146.70.192.158 |

### 配置步驟

#### 1. 獲取 VPN 憑證

前往 [Surfshark 後台](https://my.surfshark.com/)：
1. 進入 **VPN → Manual Setup**
2. 選擇協議：**OpenVPN**
3. 在 **Credentials** 區域找到：
   - Username
   - Password
4. 將憑證填入專案中的 `auth.txt` 檔案：
   ```
   your_surfshark_username
   your_surfshark_password
   ```

#### 2. 修改 VPN 伺服器（可選）

在 `docker-compose.yml` 中修改伺服器地址：

```yaml
environment:
  # 選項 1：使用域名（推薦）
  - VPN_SERVER_JP_IP=jp-tok-st014.prod.surfshark.com

  # 選項 2：使用靜態 IP
  - VPN_SERVER_JP_IP=138.199.22.136
```

#### 3. 新增其他地區（可選）

複製現有服務配置並修改：
```yaml
vpn-proxy-tw:
  build: .
  container_name: vpn-proxy-tw
  cap_add:
    - NET_ADMIN
  devices:
    - /dev/net/tun
  restart: unless-stopped
  dns:
    - 8.8.8.8
    - 8.8.4.4
  environment:
    - RESOLVCONF_DISABLE=yes
    - VPN_SERVER_TW_IP=tw-tai-st001.prod.surfshark.com
    - VPN_SERVER_TW_PORT=1194
    - SQUID_PORT_TW=3131
    - ENABLE_AUTH=false
```

## 故障排除

### 問題：連不上 Proxy

**檢查容器狀態**
```bash
docker-compose ps
```

所有容器應該顯示 `Up` 和 `healthy` 狀態。

**檢查 Port 監聽**
```bash
ss -tlnp | grep -E "3129|3130"
```

應該看到 `0.0.0.0:3129` 和 `0.0.0.0:3130` 在監聽。

### 問題：Access Denied 錯誤

**檢查 Squid 配置**
```bash
docker exec vpn-proxy-jp cat /etc/squid/squid.conf
```

確認配置中有 `http_access allow all`（無認證模式）或正確的認證配置。

**重新構建容器**
```bash
docker-compose down
docker-compose build
docker-compose up -d
```

### 問題：VPN 連線失敗

**查看 VPN 日誌**
```bash
docker exec vpn-proxy-jp cat /vpn/vpn.log
```

**常見原因**：
1. `auth.txt` 憑證錯誤或過期
2. Surfshark 伺服器地址變更
3. 網路防火牆阻擋 UDP 1194 端口

**解決方法**：
1. 更新 `auth.txt` 憑證
2. 到 Surfshark 官網查詢最新伺服器地址
3. 檢查防火牆設定

### 問題：Windows 連不上主機名稱

**使用 IP 代替主機名稱**
```powershell
# 不用 ray-pve-ubuntu:3129
# 改用 IP
curl -x http://100.119.209.17:3129 ipinfo.io
```

**或設定 hosts 檔案** (需管理員權限)
```
C:\Windows\System32\drivers\etc\hosts
```
加入：
```
100.119.209.17  ray-pve-ubuntu
```

## 安全建議

### 私有網路使用（Tailscale）
如果只在 Tailscale 私有網路中使用：
- ✅ 可以保持 `ENABLE_AUTH=false`
- ✅ Port 綁定 `0.0.0.0` 是安全的

### 公網暴露
如果 Proxy 暴露到公網：
- ⚠️ **必須**啟用 `ENABLE_AUTH=true`
- ⚠️ 使用強密碼
- ⚠️ 考慮使用防火牆限制訪問 IP

### 防火牆設定（可選）

**只允許 Tailscale 網段訪問**
```bash
sudo ufw allow from 100.0.0.0/8 to any port 3129,3130
sudo ufw deny 3129
sudo ufw deny 3130
```

## 技術架構

### 容器架構
```
┌─────────────────────────────────────────┐
│         proxy-nginx (Nginx)              │
│   Port: 0.0.0.0:3129, 0.0.0.0:3130      │
└──────────────┬──────────────────────────┘
               │
       ┌───────┴────────┐
       │                │
┌──────▼─────┐   ┌──────▼─────┐
│vpn-proxy-jp│   │vpn-proxy-sg│
│            │   │            │
│ Squid:3129 │   │ Squid:3130 │
│ OpenVPN    │   │ OpenVPN    │
│ → Tokyo    │   │ → Singapore│
└────────────┘   └────────────┘
```

### 檔案結構
```
ss-proxy/
├── docker-compose.yml    # Docker Compose 配置
├── Dockerfile            # 容器映像定義
├── start.sh              # 容器啟動腳本
├── squid.conf            # Squid 配置模板
├── auth.txt              # Surfshark VPN 憑證
├── nginx/
│   └── nginx.conf        # Nginx 配置
└── README.md             # 本文件
```

## License

MIT License

## 貢獻

歡迎提交 Issue 和 Pull Request！