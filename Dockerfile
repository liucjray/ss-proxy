FROM dperson/openvpn-client:latest

# 安裝 Squid、curl 和 gettext
RUN apk add --no-cache squid curl gettext

# 複製憑證和 Squid 配置文件
COPY auth.txt /vpn/vpn.auth
COPY squid.conf /etc/squid/squid.conf

# 複製啟動腳本
COPY start.sh /start.sh
RUN chmod +x /start.sh

# 暴露多個端口
EXPOSE 3129 3130

# 入口點
CMD ["/start.sh"]