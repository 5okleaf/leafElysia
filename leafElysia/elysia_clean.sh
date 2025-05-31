#!/bin/bash

# 🧼 Elysia Clean — LeafWorld 초기화 스크립트 (Bash 명령어 기반)
# 사용법: ./elysia_clean.sh

set -e

# 사용자 입력 받기
read -p "🌐 삭제할 도메인명 입력 (e.g., leafdent.com): " DOMAIN
read -p "🧠 서버 번호 입력 (예: 32): " SERVER_ID
read -p "📁 Git 저장소 이름 입력 (예: leafworld-core): " GIT_REPO
read -p "📦 Git 사용자 이름 입력: " GIT_USER

CONFIG_DIR="/etc/nginx/sites-available"
ENABLED_DIR="/etc/nginx/sites-enabled"
LOG_DIR="/var/log/leafworld/$DOMAIN"
ASSETS_DIR="/var/www/assets/$DOMAIN"
WWW_DIR="/var/www/$DOMAIN"
PROJECT_DIR="$HOME/$GIT_REPO"

# 🔥 PM2 프로세스 중지 및 삭제
pm2 delete ${DOMAIN}_front || true
pm2 delete ${DOMAIN}_admin_front || true
pm2 delete ${DOMAIN}_back || true
pm2 delete ${DOMAIN}_admin_back || true

# 🧹 Nginx 설정 제거
rm -f "$CONFIG_DIR/$DOMAIN.conf"
rm -f "$ENABLED_DIR/$DOMAIN.conf"

# 🗑️ 파일 시스템 정리
rm -rf "$LOG_DIR"
rm -rf "$ASSETS_DIR"
rm -rf "$WWW_DIR"

# 🔒 방화벽 포트 제거
ufw delete allow 3000 || true
ufw delete allow 3001 || true
ufw delete allow 4000 || true
ufw delete allow 4001 || true

# 🧬 Git 클론 및 준비
if [ ! -d "$PROJECT_DIR" ]; then
  git clone https://github.com/$GIT_USER/$GIT_REPO.git "$PROJECT_DIR"
  echo "✅ Git 저장소 클론 완료: $PROJECT_DIR"
else
  echo "ℹ️ Git 저장소 이미 존재함: $PROJECT_DIR"
fi

# 🔄 서비스 재시작
systemctl reload nginx

# ✅ 완료 메시지
echo "🧽 LeafWorld 모듈 '$DOMAIN' (서버 $SERVER_ID) 초기화 및 Git 준비 완료."
echo "💡 이제 'Elysia Body'로 배포를 시작하세요."
