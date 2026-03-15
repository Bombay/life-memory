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

# ─────────────────────────────────────────────
# v9 → v10 마이그레이션 감지
# ─────────────────────────────────────────────
_needs_migration() {
  if [[ -f ".memory-config.yaml" ]]; then
    grep -q 'version: 2' .memory-config.yaml 2>/dev/null
  else
    return 1
  fi
}

_run_migration() {
  echo ""
  echo "=== v9 → v10 마이그레이션 시작 ==="

  # _meta/ 생성
  mkdir -p _meta

  if [[ ! -f "_meta/registry.yaml" ]]; then
    cat > _meta/registry.yaml << 'YAML'
tag_index: {}
reverse_links: {}
last_rebuilt: null
YAML
  fi

  if [[ ! -f "_meta/consolidation-log.yaml" ]]; then
    cat > _meta/consolidation-log.yaml << 'YAML'
entries: []
detected_patterns: []
YAML
  fi

  if [[ ! -f "_meta/retrieval-failures.yaml" ]]; then
    cat > _meta/retrieval-failures.yaml << 'YAML'
failures: []
stats:
  total: 0
  resolved: 0
  pending: 0
  top_patterns: []
YAML
  fi

  if [[ ! -f "_meta/health-report.yaml" ]]; then
    cat > _meta/health-report.yaml << 'YAML'
last_run: null
issues: []
YAML
  fi

  if [[ ! -f "_meta/compat.yaml" ]]; then
    cat > _meta/compat.yaml << 'YAML'
version: 10
legacy_paths:
  "finance/investing/stocks/": "finance/knowledge/stocks/"
  "finance/investing/sectors/": "finance/knowledge/sectors/"
YAML
  fi

  echo "✓ _meta/ 초기 파일 생성"

  # knowledge/, procedures/ 디렉토리 생성 (모든 도메인)
  for dir in finance/knowledge finance/procedures \
              work/knowledge work/procedures \
              life/knowledge life/procedures; do
    mkdir -p "$dir"
  done
  echo "✓ knowledge/, procedures/ 디렉토리 생성"

  # finance/investing/stocks/* → finance/knowledge/stocks/
  mkdir -p finance/knowledge/stocks finance/knowledge/sectors finance/knowledge/concepts
  if [[ -d "finance/investing/stocks" ]]; then
    if [[ -n "$(ls -A finance/investing/stocks 2>/dev/null)" ]]; then
      git mv finance/investing/stocks/* finance/knowledge/stocks/ 2>/dev/null || true
      echo "✓ finance/investing/stocks/ → finance/knowledge/stocks/ 이동"
    fi
  fi

  # finance/investing/sectors/* → finance/knowledge/sectors/
  if [[ -d "finance/investing/sectors" ]]; then
    if [[ -n "$(ls -A finance/investing/sectors 2>/dev/null)" ]]; then
      git mv finance/investing/sectors/* finance/knowledge/sectors/ 2>/dev/null || true
      echo "✓ finance/investing/sectors/ → finance/knowledge/sectors/ 이동"
    fi
  fi

  # investing/_index.yaml 처리
  if [[ -f "finance/investing/_index.yaml" ]]; then
    if grep -q 'ticker\|stocks\|종목' finance/investing/_index.yaml 2>/dev/null; then
      echo "⚠  finance/investing/_index.yaml에 종목 데이터가 포함되어 있습니다."
      echo "   수동으로 finance/knowledge/stocks/_index.yaml로 이관하세요."
    fi
  fi

  # 빈 investing/ 디렉토리 정리
  if [[ -d "finance/investing" ]]; then
    if [[ -z "$(find finance/investing -mindepth 1 -not -name '.gitkeep' 2>/dev/null)" ]]; then
      git rm -rf finance/investing 2>/dev/null || rm -rf finance/investing
      echo "✓ 빈 finance/investing/ 디렉토리 제거"
    else
      echo "⚠  finance/investing/ 에 파일이 남아 있습니다. 수동 확인 후 제거하세요."
    fi
  fi

  # 대분류 _index.yaml v10 스키마로 갱신
  cat > finance/_index.yaml << YAML
categories:
  - path: diary/
    description: "투자일기 — 회고, 실수 반복 방지, 투자 가치관"
    immutable: true
  - path: knowledge/
    description: "투자 지식 — 종목, 섹터, 개념"
  - path: procedures/
    description: "투자 원칙 — 포지션 사이징, 손절 기준"
  - path: budget/
    description: "월별 예산"
  - path: accounts.yaml
    description: "계좌 정보"
  - path: transactions/
    description: "비투자 거래 (생활비, 구독 등)"
updated: "${CREATED_DATE}"
YAML

  cat > finance/knowledge/_index.yaml << YAML
children:
  - path: stocks/
    gist: "보유/관심 종목 투자 분석"
  - path: sectors/
    gist: "섹터/테마별 분석"
  - path: concepts/
    gist: "금융 개념 및 용어 정리"
updated: "${CREATED_DATE}"
YAML

  cat > work/_index.yaml << YAML
categories:
  - path: knowledge/
    description: "업무 지식 — 프로젝트, 기술, 도구"
  - path: procedures/
    description: "업무 원칙 — 코드 리뷰, 워크플로우"
updated: "${CREATED_DATE}"
YAML

  cat > life/_index.yaml << YAML
categories:
  - path: diary/
    description: "일상일기"
    immutable: true
  - path: knowledge/
    description: "개인 지식 — 사람, 건강, 관심사"
  - path: procedures/
    description: "개인 원칙 — 루틴, 습관"
updated: "${CREATED_DATE}"
YAML

  echo "✓ 대분류 _index.yaml v10 스키마로 갱신"

  # .memory-config.yaml version: 2 → 10
  sed -i '' 's/^version: 2$/version: 10/' .memory-config.yaml
  echo "✓ .memory-config.yaml version: 2 → 10 갱신"

  git add -A
  git commit -m "feat(v10): v9→v10 마이그레이션 — knowledge/procedures 구조 + _meta/" 2>/dev/null || true

  echo ""
  echo "=== 마이그레이션 완료 (v9 → v10) ==="
}

# ─────────────────────────────────────────────
# 신규 설치 또는 마이그레이션 분기
# ─────────────────────────────────────────────
if _needs_migration; then
  _run_migration
else
  # ── 신규 설치: v10 디렉토리 구조 생성 ──
  for dir in finance/diary \
             finance/knowledge/stocks \
             finance/knowledge/sectors \
             finance/knowledge/concepts \
             finance/procedures \
             finance/budget \
             finance/transactions \
             work/knowledge \
             work/procedures \
             life/diary \
             life/knowledge \
             life/procedures \
             _meta \
             archive/finance archive/work archive/life; do
    mkdir -p "$dir"
  done
  echo "✓ 디렉토리 구조 생성 (v10)"

  # _meta/ 초기 파일
  if [[ ! -f "_meta/registry.yaml" ]]; then
    cat > _meta/registry.yaml << 'YAML'
tag_index: {}
reverse_links: {}
last_rebuilt: null
YAML
  fi

  if [[ ! -f "_meta/consolidation-log.yaml" ]]; then
    cat > _meta/consolidation-log.yaml << 'YAML'
entries: []
detected_patterns: []
YAML
  fi

  if [[ ! -f "_meta/retrieval-failures.yaml" ]]; then
    cat > _meta/retrieval-failures.yaml << 'YAML'
failures: []
stats:
  total: 0
  resolved: 0
  pending: 0
  top_patterns: []
YAML
  fi

  if [[ ! -f "_meta/health-report.yaml" ]]; then
    cat > _meta/health-report.yaml << 'YAML'
last_run: null
issues: []
YAML
  fi

  if [[ ! -f "_meta/compat.yaml" ]]; then
    cat > _meta/compat.yaml << 'YAML'
version: 10
legacy_paths:
  "finance/investing/stocks/": "finance/knowledge/stocks/"
  "finance/investing/sectors/": "finance/knowledge/sectors/"
YAML
  fi

  echo "✓ _meta/ 초기 파일 생성"

  # 대분류 _index.yaml
  if [[ ! -f "finance/_index.yaml" ]]; then
    cat > finance/_index.yaml << YAML
categories:
  - path: diary/
    description: "투자일기 — 회고, 실수 반복 방지, 투자 가치관"
    immutable: true
  - path: knowledge/
    description: "투자 지식 — 종목, 섹터, 개념"
  - path: procedures/
    description: "투자 원칙 — 포지션 사이징, 손절 기준"
  - path: budget/
    description: "월별 예산"
  - path: accounts.yaml
    description: "계좌 정보"
  - path: transactions/
    description: "비투자 거래 (생활비, 구독 등)"
updated: "${CREATED_DATE}"
YAML
  fi

  if [[ ! -f "finance/knowledge/_index.yaml" ]]; then
    cat > finance/knowledge/_index.yaml << YAML
children:
  - path: stocks/
    gist: "보유/관심 종목 투자 분석"
  - path: sectors/
    gist: "섹터/테마별 분석"
  - path: concepts/
    gist: "금융 개념 및 용어 정리"
updated: "${CREATED_DATE}"
YAML
  fi

  if [[ ! -f "work/_index.yaml" ]]; then
    cat > work/_index.yaml << YAML
categories:
  - path: knowledge/
    description: "업무 지식 — 프로젝트, 기술, 도구"
  - path: procedures/
    description: "업무 원칙 — 코드 리뷰, 워크플로우"
updated: "${CREATED_DATE}"
YAML
  fi

  if [[ ! -f "life/_index.yaml" ]]; then
    cat > life/_index.yaml << YAML
categories:
  - path: diary/
    description: "일상일기"
    immutable: true
  - path: knowledge/
    description: "개인 지식 — 사람, 건강, 관심사"
  - path: procedures/
    description: "개인 원칙 — 루틴, 습관"
updated: "${CREATED_DATE}"
YAML
  fi

  echo "✓ 대분류 _index.yaml 생성"

  # .memory-config.yaml
  if [[ ! -f ".memory-config.yaml" ]]; then
    cat > .memory-config.yaml << YAML
version: 10
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

repository:
  name: ""
  url: ""
  owner: ""
  local_path: "${MEMORY_PATH}"

archive:
  opinion_log_max: 10
  transaction_max: 30

tidy:
  suggest_threshold: 20
YAML
    echo "✓ .memory-config.yaml 생성"
  fi

  git add -A
  git commit -m "memory: 초기 설정 (v10)" 2>/dev/null || true
fi

# ─────────────────────────────────────────────
# Remote 정보 갱신 (공통)
# ─────────────────────────────────────────────
if git remote get-url origin &>/dev/null; then
  REMOTE_URL=$(git remote get-url origin)
  echo "✓ Remote: $REMOTE_URL"
  if [[ -f ".memory-config.yaml" ]] && grep -q 'name: ""' .memory-config.yaml 2>/dev/null; then
    REPO_NAME=$(basename "$REMOTE_URL" .git)
    REPO_OWNER=$(echo "$REMOTE_URL" | sed -E 's|.*[:/]([^/]+)/[^/]+\.git$|\1|')
    sed -i '' "s|name: \"\"|name: \"$REPO_NAME\"|" .memory-config.yaml
    sed -i '' "s|url: \"\"|url: \"$REMOTE_URL\"|" .memory-config.yaml
    sed -i '' "s|owner: \"\"|owner: \"$REPO_OWNER\"|" .memory-config.yaml
  fi
else
  echo ""
  echo "ℹ Remote 미설정. /memory setup에서 에이전트가 GitHub repo 연결을 도와드립니다."
fi

echo ""
echo "=== 설정 완료 ==="
echo "커맨드: /remember, /recall, /forget, /memory, /undo"
