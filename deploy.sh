#!/bin/bash

# 远程服务器配置
REMOTE_USER="root"
REMOTE_HOST="47.92.167.82"
REMOTE_DIR="/www/wwwroot/peidigroup.cn/card"

# 构建项目
echo "Building project..."
npm run build

# 压缩dist目录
echo "Compressing dist directory..."
tar -czf dist.tar.gz dist/

# 上传到远程服务器
echo "Uploading to remote server..."
scp dist.tar.gz $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR

# 在远程服务器上解压并部署
echo "Deploying on remote server..."
ssh $REMOTE_USER@$REMOTE_HOST << 'ENDSSH'
cd /www/wwwroot/peidigroup.cn/card
rm -rf dist
tar -xzf dist.tar.gz
rm dist.tar.gz
ENDSSH

# 清理本地临时文件
echo "Cleaning up..."
rm dist.tar.gz

echo "Deployment completed!"