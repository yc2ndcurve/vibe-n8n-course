# vibe.scendia.com.tw 搬遷封存與重建

封存日期：2026-09-09；來源 hermes-n8n 的 /var/www/vibe.scendia.com.tw。
這是純靜態網站，無需 npm、資料庫、n8n 或 Docker 就能提供頁面。
正式首頁為 `mario.html`。本機預覽僅監聽 127.0.0.1。

## 本機啟動

```sh
python3 migration/build.py
python3 migration/serve.py --port 8082
```

開啟 http://127.0.0.1:8082/ 。只部署 `dist/`，不得將整個 repo（含 .git）設為公開根目錄。

## 外部依賴與資料

報名連到 Google Forms，回覆資料位於 Google Forms／其關聯儲存，不在此 repo。
搬網站不代表已備份報名資料。Google Fonts 需要外網。
vibe 另使用 jsDelivr 的 qrcodejs@1.0.0，以及 stanleylin.tw 的講師照片。外部資產尚未離線封存；網站不保證離線完全呈現。

沒有發現本機資料庫、上傳目錄或 runtime secrets。`.env.example` 只記錄無必要環境變數。
`migration/nginx-site.conf.example` 是單站 HTTP 範例；正式環境需另配置 HTTPS 與憑證。

## 安全重啟與切換

1. 在新位置建立獨立站點，先驗證首頁、下載、手機顯示與報名連結。
2. 取得 HTTPS 憑證、確認 DNS 與原本 host 路由，再安排切換。
3. 切換後觀察，保留舊站可回復；不要在其他服務尚未迁移時停止整台 VM。
4. repo 不含 TLS 私鑰。新環境應重新核發或經受限管道遷移。

## 舊部署脚本注意

既有 `deploy/deploy.sh` 留作歷史，**不要直接執行**。它含移除 nginx default 設定的動作；目前 default 同時承載 even、vibe、n8n，直接執行可能中斷其他站。此次沒有執行它。請使用新的單站配置範例規劃部署。

保留原 Git 歷史及正式站上兩份未提交 HTML 修改。
