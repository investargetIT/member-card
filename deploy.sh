#!/bin/bash

# 执行构建
pnpm run build

# 重命名 dist 目录
mv dist card

# 获取当前路径
CURRENT_PATH=$(pwd)

# 上传到服务器
scp -r $CURRENT_PATH/card root@121.43.145.161:/media/www

# 删除本地 card 文件夹
rm -rf card

echo "部署完成！"