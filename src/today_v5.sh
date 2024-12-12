#!/bin/bash

# 检查当前目录是否是一个Git仓库
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "当前目录不是一个Git仓库，请在Git仓库中运行此脚本。"
    exit 1
fi

# 获取当前日期
today=$(date "+%Y-%m-%d")

# 使用git log过滤今天的提交记录
commit_logs=$(git log --since="$today 00:00:00 +0800" --until="$today 23:59:59 +0800" --pretty=format:"%s%n%b")

# 检查提交记录是否为空
if [ -z "$commit_logs" ]; then
    echo "今天没有提交记录。"
		exit 0
fi


# 定义请求 URL 和请求数据
APP_ID="9e2243397d3c4863802b694803751361"
API_KEY="sk-7ca572acd89f47228771435077beac75"
URL="https://dashscope.aliyuncs.com/api/v1/apps/${APP_ID}/completion"

# 将多行提交记录转换成json适用的格式
formatted_logs=$(jq -Rn --arg str "$commit_logs" '$str')


DATA=$(cat <<EOF
{
	"input": {
		"prompt": $formatted_logs
	},
	"parameters": {},
	"debug": {}
}
EOF
)

# 发送 HTTP POST 请求
RESPONSE=$(curl -s -X POST "$URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: $API_KEY" \
    -d "$DATA")

# 使用 jq 提取 output.text
TEXT=$(echo "$RESPONSE" | jq -r '.output.text')

# 检查是否成功提取文本
if [ -n "$TEXT" ]; then
    echo "$TEXT"
else
    echo "请求异常，请重试或联系管理员"
    echo "$RESPONSE"
fi