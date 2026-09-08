#!/bin/bash
# Migration guard: this legacy script removes the shared production nginx default.
printf "%s\n" "STOP: legacy deployment disabled. Use README-MIGRATION.md and the isolated migration/nginx-site.conf.example." >&2
exit 64

# ================================================================
# 部署腳本：vibe.scendia.com.tw
#
# 使用方式（在你的 Mac 上跑）：
#   chmod +x deploy.sh
#   ./deploy.sh
#
# 前置條件：
#   1. DNS 已設定 A record: vibe.scendia.com.tw → 104.199.186.38
#   2. 你能 SSH 到 104.199.186.38
# ================================================================

SERVER="104.199.186.38"
USER="root"    # ← 改成你的 SSH 使用者名稱
SITE_DIR="/var/www/vibe.scendia.com.tw"
DOMAIN="vibe.scendia.com.tw"

echo "========================================="
echo "  部署 $DOMAIN"
echo "========================================="

# Step 1: 打包網站檔案
echo "[1/5] 打包網站檔案..."
cd "$(dirname "$0")/.."
tar -czf /tmp/n8n-course-deploy.tar.gz \
  --exclude='.DS_Store' \
  --exclude='deploy' \
  --exclude='node_modules' \
  mario.html index.html robots.txt sitemap.xml bny-ai.png examples/

# Step 2: 上傳到伺服器
echo "[2/5] 上傳到 $SERVER..."
scp /tmp/n8n-course-deploy.tar.gz $USER@$SERVER:/tmp/

# Step 3: SSH 到伺服器執行部署
echo "[3/5] 在伺服器上部署..."
ssh $USER@$SERVER << 'REMOTE_SCRIPT'

set -e

SITE_DIR="/var/www/vibe.scendia.com.tw"
DOMAIN="vibe.scendia.com.tw"

# 建立網站目錄
sudo mkdir -p $SITE_DIR
sudo mkdir -p /var/www/certbot

# 解壓網站檔案
cd $SITE_DIR
sudo tar -xzf /tmp/n8n-course-deploy.tar.gz
sudo chown -R www-data:www-data $SITE_DIR
rm /tmp/n8n-course-deploy.tar.gz

echo "  ✓ 網站檔案已部署到 $SITE_DIR"

# 安裝 Nginx（如果還沒裝）
if ! command -v nginx &> /dev/null; then
    echo "  安裝 Nginx..."
    sudo apt-get update -qq
    sudo apt-get install -y -qq nginx
fi

# 安裝 Certbot（如果還沒裝）
if ! command -v certbot &> /dev/null; then
    echo "  安裝 Certbot..."
    sudo apt-get install -y -qq certbot python3-certbot-nginx
fi

echo "  ✓ Nginx + Certbot 已就緒"

# 先用 HTTP-only config 讓 Certbot 能驗證
sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null << 'NGINX_TEMP'
server {
    listen 80;
    server_name vibe.scendia.com.tw;
    root /var/www/vibe.scendia.com.tw;
    index mario.html;
    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
    location / {
        try_files $uri /mario.html;
    }
}
NGINX_TEMP

sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx

echo "  ✓ Nginx HTTP 設定完成"

# 申請 SSL 憑證
if [ ! -f /etc/letsencrypt/live/$DOMAIN/fullchain.pem ]; then
    echo "  申請 Let's Encrypt SSL 憑證..."
    sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email admin@scendia.com.tw --redirect
    echo "  ✓ SSL 憑證已申請"
else
    echo "  ✓ SSL 憑證已存在"
fi

# 設定自動續約
sudo systemctl enable certbot.timer 2>/dev/null || true

echo ""
echo "========================================="
echo "  ✓ 部署完成！"
echo "  https://$DOMAIN"
echo "========================================="

REMOTE_SCRIPT

# Step 4: 驗證
echo ""
echo "[4/5] 驗證網站..."
sleep 3
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://$DOMAIN" 2>/dev/null || echo "000")
echo "  HTTP 狀態碼: $HTTP_CODE"

# Step 5: 完成
echo ""
echo "[5/5] ✓ 部署完成！"
echo ""
echo "  ┌─────────────────────────────────────┐"
echo "  │  https://$DOMAIN  │"
echo "  └─────────────────────────────────────┘"
echo ""
echo "  SEO 驗證清單："
echo "  □ Google Search Console 提交 sitemap"
echo "    → https://search.google.com/search-console"
echo "    → 新增 https://$DOMAIN"
echo "    → 提交 sitemap: https://$DOMAIN/sitemap.xml"
echo ""
echo "  □ Bing Webmaster Tools 提交"
echo "    → https://www.bing.com/webmasters"
echo ""
echo "  □ 測試 Open Graph（社群分享）"
echo "    → https://www.opengraph.xyz/url/https://$DOMAIN"
echo ""
echo "  □ 測試結構化資料（AEO）"
echo "    → https://search.google.com/test/rich-results?url=https://$DOMAIN"
echo ""
