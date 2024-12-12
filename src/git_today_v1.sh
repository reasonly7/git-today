#!/bin/bash

# 获取当前日期
today=$(date +%Y-%m-%d)

# 自动获取当前配置的 Git 用户名
author_name=$(git config user.name)

# 使用 git log 获取今天你自己的提交记录
git log --since="$today 00:00:00" --until="$today 23:59:59" --author="$author_name" --pretty=format:"%s"