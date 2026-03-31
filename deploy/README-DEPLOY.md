# 部署指南 — vibe.scendia.com.tw

## 已完成
- [x] GitHub repo: https://github.com/yc2ndcurve/vibe-n8n-course
- [x] 所有檔案已推上 GitHub
- [x] SEO / AEO / GEO 標記完成
- [x] robots.txt + sitemap.xml 已建立
- [x] Nginx config 已寫好
- [x] 部署腳本已準備

## 你醒來要做的事

### Step 1: DNS 設定
到你的 DNS 管理面板（scendia.com.tw 的 DNS），新增：
```
類型: A
名稱: vibe
值:   104.199.186.38
TTL:  300
```

### Step 2: SSH 到 GCP VM 並執行以下指令

```bash
# 連到你的 GCP VM
ssh 你的帳號@104.199.186.38

# 安裝必要工具
sudo apt-get update && sudo apt-get install -y nginx certbot python3-certbot-nginx git

# Clone 你的 GitHub repo
sudo git clone https://github.com/yc2ndcurve/vibe-n8n-course.git /var/www/vibe.scendia.com.tw

# 複製 Nginx 設定
sudo cp /var/www/vibe.scendia.com.tw/deploy/nginx-vibe.conf /etc/nginx/sites-available/vibe.scendia.com.tw
sudo ln -sf /etc/nginx/sites-available/vibe.scendia.com.tw /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default

# 先用 HTTP 啟動（讓 Certbot 能驗證）
# 編輯 nginx config，先把 443 的 server block 註解掉，只留 80
sudo nginx -t && sudo systemctl reload nginx

# 申請 SSL 憑證
sudo certbot --nginx -d vibe.scendia.com.tw --non-interactive --agree-tos --email admin@scendia.com.tw

# 重新載入 Nginx
sudo systemctl reload nginx

# 完成！打開 https://vibe.scendia.com.tw 測試
```

### Step 3: 驗證 SEO
1. Google Search Console: https://search.google.com/search-console
   - 新增 https://vibe.scendia.com.tw
   - 提交 sitemap: https://vibe.scendia.com.tw/sitemap.xml
2. 測試結構化資料: https://search.google.com/test/rich-results?url=https://vibe.scendia.com.tw
3. 測試 Open Graph: https://www.opengraph.xyz/url/https://vibe.scendia.com.tw

### 之後更新網站
```bash
# 在你的 Mac 上
cd "/Users/ycimac/Desktop/AI project-Claude code/n8n-course"
git add -A && git commit -m "update" && git push

# 在 GCP VM 上
cd /var/www/vibe.scendia.com.tw && sudo git pull
```
