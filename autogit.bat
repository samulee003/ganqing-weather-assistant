@echo off

echo 自動 git 推送腳本

git add .

set /p message="輸入 commit 訊息: "

git commit -m "%message%"

git push origin master

echo 完成！按任意鍵退出...
pause 