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

## 乾淨 checkout 與部署包

```sh
python3 migration/package.py
```

輸出 `release/vibe-static.tar.gz`：只有固定清單中的公開資產、單站 nginx 範例與 SHA256 manifest。以新的 checkout 重建；`dist/` 是可重建產物，build 會清除舊輸出，避免殘留檔意外發布。只使用 Python 標準函式庫，無套件安裝或 runtime secrets。

在**新主機或獨立站點目錄**解壓縮後，nginx root 對應 `/srv/vibe.scendia.com.tw/dist`。先驗證 HTTP，再由目標平台配置 HTTPS。範例設定只新增此站，不能刪除共用 default。套用任何正式設定前需通過 `nginx -t` 並由總指揮安排切流。不要從原始私人 tar 或整個 repo 建公開 web root。

遠端只保存 `codex/preserve-production-20260909` 分支，不包含 stash refs；來源 stash 與完整 Git metadata 仍由受限備份保存。Git bundle 與原始私有封存是備份，不應當作網站上傳。
