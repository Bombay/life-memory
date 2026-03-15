#!/bin/bash
set -euo pipefail

MEMORY_PATH="${LIFE_MEMORY_PATH:-$HOME/.life-memory}"
CREATED_DATE=$(date +%Y-%m-%d)

echo "=== Life Memory 초기 설정 ==="

if [[ -d "$MEMORY_PATH" ]]; then
  echo "✓ 메모리 디렉토리: $MEMORY_PATH"
else
  mkdir -p "$MEMORY_PATH"
  echo "✓ 디렉토리 생성: $MEMORY_PATH"
fi

cd "$MEMORY_PATH"

if [[ ! -d ".git" ]]; then
  git init -b main
  echo "✓ Git 초기화 (branch: main)"
fi

# 고정 디렉토리만 생성 (자율 영역은 에이전트가 필요 시 생성)
for dir in finance/diary \
           finance/investing/stocks finance/investing/sectors \
           finance/budget finance/transactions \
           work \
           life/diary \
           archive/opinion-logs archive/transactions; do
  mkdir -p "$dir"
done
echo "✓ 디렉토리 구조 생성"

# 대분류 _index.yaml 초기 생성
if [[ ! -f "finance/_index.yaml" ]]; then
  cat > finance/_index.yaml << YAML
categories:
  - path: diary/
    description: "투자일기 — 회고, 실수 반복 방지, 투자 가치관"
    immutable: true
  - path: investing/
    description: "투자 분석 + 보유 (종목별 통합 파일)"
  - path: budget/
    description: "월별 예산"
  - path: accounts.yaml
    description: "계좌 정보"
  - path: transactions/
    description: "비투자 거래 (생활비, 구독 등)"
updated: "${CREATED_DATE}"
YAML
fi

if [[ ! -f "work/_index.yaml" ]]; then
  cat > work/_index.yaml << YAML
categories: []
updated: "${CREATED_DATE}"
YAML
fi

if [[ ! -f "life/_index.yaml" ]]; then
  cat > life/_index.yaml << YAML
categories:
  - path: diary/
    description: "일상일기"
    immutable: true
updated: "${CREATED_DATE}"
YAML
fi

if [[ ! -f ".memory-config.yaml" ]]; then
  cat > .memory-config.yaml << YAML
version: 2
created: "${CREATED_DATE}"

approval:
  mode: "smart"

conflict_policy:
  financial: "confirm_detail"
  opinion: "log_history"
  general: "overwrite_with_note"

suggestion:
  sensitivity: "medium"
  finance_reminder: true

sync:
  auto_push: true
  auto_pull: true
  remote: "origin"
  branch: "main"

archive:
  opinion_log_max: 10
  transaction_max: 30

tidy:
  suggest_threshold: 20
YAML
  echo "✓ .memory-config.yaml 생성"
fi

git add -A
git commit -m "memory: 초기 설정" 2>/dev/null || true

if git remote get-url origin &>/dev/null; then
  echo "✓ Remote: $(git remote get-url origin)"
else
  echo ""
  echo "ℹ Remote 미설정. /memory setup에서 에이전트가 GitHub repo 생성을 도와드립니다."
fi

echo ""
echo "=== 설정 완료 ==="
echo "커맨드: /remember, /recall, /forget, /memory, /undo"
