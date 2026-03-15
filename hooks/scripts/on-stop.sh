#!/bin/bash
set -euo pipefail

MEMORY_PATH="${LIFE_MEMORY_PATH:-$HOME/.life-memory}"

if [[ ! -d "$MEMORY_PATH/.git" ]]; then
  exit 0
fi

cd "$MEMORY_PATH"

# 미커밋 변경사항 자동 커밋 (last_accessed 갱신 포함)
if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
  git add -A
  git commit -m "memory(auto): 세션 종료 — 미커밋 변경사항 저장" --quiet 2>/dev/null || true
fi

# 충돌 상태면 push 건너뛰기
if [[ -f ".sync-conflict" ]]; then
  echo "[life-memory] 동기화 충돌 미해결. /memory sync로 해결해주세요."
  exit 0
fi

# auto_push 확인
if ! grep -q 'auto_push: true' .memory-config.yaml 2>/dev/null; then
  exit 0
fi

# config에서 remote/branch 읽기
REMOTE=$(grep 'remote:' .memory-config.yaml 2>/dev/null | awk '{print $2}' | tr -d '"' || echo "origin")
BRANCH=$(grep 'branch:' .memory-config.yaml 2>/dev/null | awk '{print $2}' | tr -d '"' || echo "main")
REMOTE=${REMOTE:-origin}
BRANCH=${BRANCH:-main}

# fetch + rebase
git fetch "$REMOTE" "$BRANCH" --quiet 2>/dev/null || exit 0

if ! git rebase "$REMOTE/$BRANCH" --quiet 2>/dev/null; then
  CONFLICT_FILES=$(git diff --name-only 2>/dev/null || true)
  git rebase --abort 2>/dev/null || true
  echo "conflict_detected: $(date -u +%Y-%m-%dT%H:%M:%SZ)" > .sync-conflict
  if [[ -n "$CONFLICT_FILES" ]]; then
    echo "files:" >> .sync-conflict
    echo "$CONFLICT_FILES" | while read -r f; do echo "  - $f" >> .sync-conflict; done
  fi
  echo "[life-memory] 동기화 충돌 발생. /memory sync로 해결해주세요."
  exit 0
fi

git push "$REMOTE" "$BRANCH" --quiet 2>/dev/null || {
  echo "[life-memory] push 실패. /memory sync를 실행해주세요."
}
