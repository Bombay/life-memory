# Life Memory v10 Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** v9의 "요약 전용" 한계를 극복하는 뇌과학 기반 기억 시스템(3-Tier 인코딩 + 기억 유형 분리 + 연상 네트워크 + 메타인지)을 구현한다.

**Architecture:** Claude Code 플러그인의 SKILL.md(행동 규칙), 5개 커맨드(remember/recall/forget/memory/undo), setup.sh(초기화), on-stop.sh(세션 종료 훅)을 v10 스펙에 맞게 전면 재작성한다. 데이터 디렉토리(`~/.life-memory/`)에 knowledge/, procedures/, _meta/ 계층을 추가하고, investing/ → knowledge/stocks/로 마이그레이션한다.

**Tech Stack:** Claude Code plugin (Markdown commands/skills, YAML schemas, Bash scripts)

**Spec:** `docs/superpowers/specs/2026-03-15-v10-neuroscience-architecture-design.md` — 모든 스키마, 규칙, 예시의 원본 참조.

**핵심 설계 결정 (확정 — 변경 금지):**
- 사용자는 자연어로만 말하고 y/n 승인
- /consolidate 없음 → 에이전트가 /remember, /recall 과정에서 자동 제안
- 3-Tier: gist(_index.yaml) → elaborated(overview.yaml) → source(.md)
- 기억 유형: diary(에피소드) + knowledge(의미) + procedures(절차)
- 연상 네트워크: 4종 relation + 중앙 역인덱스 (registry)
- conviction: watching/low/medium/high (기본값 watching)
- 연쇄 갱신 최대 3단계
- diary frontmatter: 생성 시 tags/mentions 포함, 생성 후 불변
- /forget 기본 = archive 이동
- 디렉토리 승격 = 단일 git commit

---

## File Structure

### 수정 대상

| 파일 | 역할 | 변경 범위 |
|------|------|-----------|
| `skills/life-memory/SKILL.md` | 에이전트 행동 규칙 (핵심) | **전면 재작성** |
| `scripts/setup.sh` | 초기화 + v9→v10 마이그레이션 | **전면 재작성** |
| `commands/remember.md` | 기억 저장 | **전면 재작성** |
| `commands/recall.md` | 기억 검색 | **전면 재작성** |
| `commands/forget.md` | 기억 삭제 | **전면 재작성** |
| `commands/memory.md` | 시스템 관리 | **전면 재작성** |
| `commands/undo.md` | 되돌리기 | **부분 수정** |
| `hooks/scripts/on-stop.sh` | 세션 종료 훅 | **부분 수정** |
| `.claude-plugin/plugin.json` | 플러그인 매니페스트 | 버전 3.0.0 |
| `docs/ARCHITECTURE.md` | 아키텍처 문서 | **전면 재작성** |
| `CLAUDE.md` | 프로젝트 규칙 | **부분 수정** |
| `README.md` | 사용자 가이드 | **부분 수정** |

### 런타임 생성 (setup.sh가 생성)

| 경로 | 역할 |
|------|------|
| `~/.life-memory/_meta/registry.yaml` | 태그 인덱스 + 역방향 링크 |
| `~/.life-memory/_meta/consolidation-log.yaml` | 공고화 이력 |
| `~/.life-memory/_meta/retrieval-failures.yaml` | 인출 실패 기록 |
| `~/.life-memory/_meta/compat.yaml` | v9 경로 호환 맵 |
| `~/.life-memory/*/knowledge/` | 의미 기억 디렉토리 |
| `~/.life-memory/*/procedures/` | 절차 기억 디렉토리 |

### 실행 순서 (의존성 기반)

```
Phase 1 (Serial):  Task 1 — SKILL.md (모든 커맨드의 규칙 기반)
Phase 2 (Parallel): Task 2-8 — setup.sh, on-stop.sh, plugin.json, 5개 커맨드
Phase 3 (Parallel): Task 9-10 — ARCHITECTURE.md, CLAUDE.md, README.md
```

---

## Chunk 1: Foundation

### Task 1: SKILL.md — v10 전면 재작성

**Files:**
- Modify: `skills/life-memory/SKILL.md`
- Reference: `docs/superpowers/specs/2026-03-15-v10-neuroscience-architecture-design.md`

**목표:** v9 SKILL.md를 v10 뇌과학 아키텍처 규칙으로 전면 교체. 이 파일이 모든 커맨드의 행동 기반이므로 가장 먼저 완성해야 한다.

- [ ] **Step 1: 현재 SKILL.md 읽기**

`skills/life-memory/SKILL.md` 전체를 읽어 v9 구조를 파악한다.

- [ ] **Step 2: v10 스펙 읽기**

`docs/superpowers/specs/2026-03-15-v10-neuroscience-architecture-design.md` 전체를 읽는다.

- [ ] **Step 3: SKILL.md 전면 재작성**

아래 섹션 구조로 SKILL.md를 재작성한다. 각 섹션의 상세 내용은 스펙의 해당 섹션을 반영한다.

**중요: 스펙에서 `/consolidate`를 언급하는 곳(§2 매핑 테이블, §5.3, §12)이 있으나, v10에서 `/consolidate`는 독립 커맨드가 아니다. 이 참조들은 `/remember`, `/recall`, `/memory health` 실행 중에 에이전트가 자동 감지+제안하는 공고화 로직으로 해석한다.**

```
## Frontmatter
- name, description, type: skill (v9과 동일)
- 트리거 키워드 (v9과 동일)

## 우선순위 규칙
- v9과 동일 (MUST > SHOULD 계층)

## 데이터 위치
- $LIFE_MEMORY_PATH 또는 ~/.life-memory/
- v10 디렉토리 구조 (스펙 §3의 트리 그대로 포함)

## 기억 유형 (NEW)
- diary/ = 에피소드 기억 (해마)
- knowledge/ = 의미 기억 (측두엽 신피질)
- procedures/ = 절차 기억 (기저핵/소뇌)
- 각 유형의 판단 기준 (스펙 §9 저장 흐름 Step 2의 기준 포함)

## 3-Tier 인코딩 (NEW)
- Tier 1: _index.yaml gist (50자 이내)
- Tier 2: overview.yaml (정교화)
- Tier 3: .md (깊은 인코딩)
- 스펙 §4의 _index.yaml 계층별 스키마 3종(대분류/knowledge/stocks) YAML 예시 모두 포함
- conviction 레벨 컨벤션 (watching/low/medium/high, 기본 watching)
- 투자 종목 gist conviction 포맷: "{thesis 한줄}. conviction {level}."
- MUST 7 v10 갱신 (직계 부모 갱신, 연쇄 최대 3단계)
- 디렉토리 승격 기준 (4개 조건) + 단일 commit 규칙

## 파일 스키마 (스펙 §4의 모든 YAML/MD 예시를 그대로 포함)
- 대분류 _index.yaml (categories 스키마)
- knowledge _index.yaml (children 스키마)
- stocks _index.yaml (children + tags 스키마)
- overview.yaml (IREN 예시 — relevance, thesis, conviction, catalysts, holdings, transactions,
  opinion_log, links, sources, last_accessed, last_updated 필드 모두 포함)
- Tier 3 .md frontmatter (title, last_updated, tags, links, sources)
- procedures .md frontmatter (title, last_updated, last_accessed, importance, tags, links, history)
- diary .md frontmatter (tags, mentions — 생성 후 불변)

## 연상 네트워크 (NEW)
- links: 필드 프로토콜 (스펙 §5.1)
- 4종 관계: related, derived_from, depends_on, contradicts (스펙 §5.2의 테이블 포함)
- 역방향 인덱스 = _meta/registry.yaml 중앙 관리 (스펙 §5.3)
- 태그 인덱스 + 정규화 규칙 (kebab-case 영문) (스펙 §5.4)
- 교차 도메인 중복 관리 (원본 한 곳, derived_from 참조) (스펙 §5.5)

## 지식 정리 (Consolidation) (NEW)
- /consolidate 커맨드 없음 — 기존 커맨드에서 자동 감지+제안
- 트리거 4종 (스펙 §6.1의 테이블 포함): 일기 쓰기, 새 정보, 검색 실패, health
- 내부 판단 로직 4단계 (스펙 §6.2)
- 추출 기준: knowledge/procedures/diary유지 분류표 (스펙 §6.3의 테이블+예시 포함)
- diary 불변 원칙 + diary frontmatter 규칙 (스펙 §6.4)
- 패턴 감지 사전 안내: 2회째→안내, 자기인식 신호→제안 (스펙 §6.5)
- detected_patterns 스키마:
  ```yaml
  detected_patterns:
    - pattern: "fomo-chase-buy"
      count: 3
      diary_refs:
        - finance/diary/2026/03/2026-03-15.md
        - finance/diary/2026/03/2026-03-22.md
        - finance/diary/2026/04/2026-04-02.md
      last_seen: "2026-04-02"
  ```

## 메타인지 (_meta/) (NEW)
- registry.yaml: 태그+역방향 링크, 갱신 타이밍 (스펙 §7.1 — incremental + 전체 재구축)
- retrieval-failures.yaml: 인출 실패 기록 (스펙 §7.2의 스키마 포함)
- health-report.yaml: 건강도 점검 5항목 (스펙 §7.3)
- consolidation-log.yaml: 공고화 이력 (entries + detected_patterns)
- 피드백 루프 다이어그램 (스펙 §7.4)

## 아카이빙 정책
- last_accessed + importance 메타데이터 (스펙 §8.1)
- importance 규칙: 기본 medium, holdings>0→high, conviction high→high
- 아카이브 후보 3조건 AND (스펙 §8.2)
- v9 건수 기반 유지 (opinion 10건, transactions 30건) (스펙 §8.3)
- diary 아카이빙 불가 (스펙 §8.4)
- last_accessed git commit 정책: 단독 commit X, on-stop.sh에서 처리

## MUST 규칙 (1-10)
- MUST 1-8: v9과 동일 (현재 SKILL.md에서 복사)
- MUST 7: v10 갱신 텍스트로 교체 (스펙 §11)
- MUST 9 (NEW): 3-Tier 일관성 — 디렉토리 승격된 knowledge 항목은 반드시 _index.yaml(Tier 1) + overview.yaml(Tier 2) 필수. Tier 3 (.md)는 선택적.
- MUST 10 (NEW): 공고화 시 diary 원본 완전 보존 — diary 일체 수정 금지, 추적은 _meta/consolidation-log.yaml에만 기록.

## SHOULD 규칙
- v9 SHOULD 유지
- 추가: 공고화 제안, 교차 도메인 링크, registry 갱신

## v9 호환
- legacy_paths 매핑 (investing/ → knowledge/stocks/) (스펙 §12)
- _meta/compat.yaml 참조
- v9 경로 접근 시 v10 경로로 **silent 리다이렉트** (사용자에게 별도 안내 없이 자동 매핑)
```

**핵심 주의사항:**
- 스펙의 예시 코드 블록(YAML, markdown)을 그대로 포함 — 특히 overview.yaml의 모든 필드(relevance, sources, last_accessed, last_updated 포함)
- MUST 1-8 텍스트는 현재 v9 SKILL.md에서 복사 (MUST 7만 v10 텍스트로 교체)
- 트리거 키워드, 우선순위 규칙은 v9과 동일하게 유지
- `대분류 행동 규칙` 섹션의 경로를 v10으로 갱신 (investing/ → knowledge/stocks/)

- [ ] **Step 4: 검증**

SKILL.md에서 다음을 확인:
1. MUST 규칙이 10개인지
2. 3-Tier 스키마 예시가 포함되었는지
3. 4종 관계 유형이 정의되었는지
4. conviction 레벨이 watching/low/medium/high인지
5. /consolidate 커맨드가 없고, 자동 감지 방식인지

- [ ] **Step 5: Commit**

```bash
cd /Users/siam/workspace/life
git add skills/life-memory/SKILL.md
git commit -m "feat(v10): SKILL.md 전면 재작성 — 3-Tier 인코딩, 기억 유형 분리, 연상 네트워크, 메타인지"
```

---

### Task 2: setup.sh — v10 디렉토리 구조 + 마이그레이션

**Files:**
- Modify: `scripts/setup.sh`
- Reference: 스펙 §3 (디렉토리 구조), §12 (마이그레이션)

**목표:** 신규 설치와 v9→v10 마이그레이션 모두 지원하는 setup.sh를 작성한다.

- [ ] **Step 1: 현재 setup.sh 읽기**

- [ ] **Step 2: setup.sh 재작성**

v9 setup.sh의 기본 흐름(디렉토리 생성 → git init → _index.yaml → config → commit)을 유지하되, v10 변경사항을 반영한다.

**주요 변경:**

1. **디렉토리 구조 변경:**
```bash
# v9에서 제거:
# finance/investing/stocks, finance/investing/sectors

# v10 추가:
mkdir -p "$MEMORY_DIR/_meta"
for domain in finance work life; do
  mkdir -p "$MEMORY_DIR/$domain/knowledge"
  mkdir -p "$MEMORY_DIR/$domain/procedures"
done
mkdir -p "$MEMORY_DIR/finance/knowledge/stocks"
mkdir -p "$MEMORY_DIR/finance/knowledge/sectors"
mkdir -p "$MEMORY_DIR/finance/knowledge/concepts"
```

2. **_meta/ 초기 파일 생성 (5개 파일):**
```yaml
# _meta/registry.yaml
tag_index: {}
reverse_links: {}
last_rebuilt: null

# _meta/consolidation-log.yaml
entries: []
detected_patterns: []

# _meta/retrieval-failures.yaml
failures: []
stats:
  total: 0
  resolved: 0
  pending: 0
  top_patterns: []

# _meta/health-report.yaml
last_run: null
issues: []

# _meta/compat.yaml
version: 10
legacy_paths:
  "finance/investing/stocks/": "finance/knowledge/stocks/"
  "finance/investing/sectors/": "finance/knowledge/sectors/"
```

3. **대분류 _index.yaml v10 스키마:**
```yaml
# finance/_index.yaml (v10)
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
updated: "$(date +%Y-%m-%d)"
```

```yaml
# finance/knowledge/_index.yaml
children:
  - path: stocks/
    gist: "보유/관심 종목 투자 분석"
  - path: sectors/
    gist: "섹터/테마별 분석"
  - path: concepts/
    gist: "금융 개념 및 용어 정리"
updated: "$(date +%Y-%m-%d)"
```

4. **.memory-config.yaml version 갱신:**
```yaml
version: 10  # v9: version: 2
```

5. **v9→v10 마이그레이션 로직 추가:**
```bash
# config의 version이 2이면 마이그레이션 실행
if [ "$CURRENT_VERSION" = "2" ]; then
  echo "v9 → v10 마이그레이션 시작..."

  # _meta/ 생성
  mkdir -p "$MEMORY_DIR/_meta"
  # (초기 파일 생성)

  # knowledge/, procedures/ 생성
  for domain in finance work life; do
    mkdir -p "$MEMORY_DIR/$domain/knowledge"
    mkdir -p "$MEMORY_DIR/$domain/procedures"
  done

  # finance/investing/ → finance/knowledge/ 이동
  if [ -d "$MEMORY_DIR/finance/investing/stocks" ]; then
    mkdir -p "$MEMORY_DIR/finance/knowledge/stocks"
    # git mv로 파일 이동 (있는 경우에만)
    for f in "$MEMORY_DIR/finance/investing/stocks"/*; do
      [ -e "$f" ] && git -C "$MEMORY_DIR" mv "$f" "$MEMORY_DIR/finance/knowledge/stocks/"
    done
  fi
  if [ -d "$MEMORY_DIR/finance/investing/sectors" ]; then
    mkdir -p "$MEMORY_DIR/finance/knowledge/sectors"
    for f in "$MEMORY_DIR/finance/investing/sectors"/*; do
      [ -e "$f" ] && git -C "$MEMORY_DIR" mv "$f" "$MEMORY_DIR/finance/knowledge/sectors/"
    done
  fi

  # finance/knowledge/concepts/ 생성 (v9에는 없음)
  mkdir -p "$MEMORY_DIR/finance/knowledge/concepts"

  # investing/_index.yaml → knowledge/stocks/_index.yaml 변환
  # v9 investing/_index.yaml의 stocks: 배열을 v10 children: 형식으로 변환
  if [ -f "$MEMORY_DIR/finance/investing/_index.yaml" ]; then
    # v9 _index.yaml에서 종목 정보를 읽어 v10 children 형식으로 변환
    cat > "$MEMORY_DIR/finance/knowledge/stocks/_index.yaml" << 'STOCKS_EOF'
children: []
updated: "DATEPLACEHOLDER"
STOCKS_EOF
    sed -i '' "s/DATEPLACEHOLDER/$(date +%Y-%m-%d)/" "$MEMORY_DIR/finance/knowledge/stocks/_index.yaml"
    # 기존 investing/_index.yaml에 종목이 있으면 수동 확인 안내
    if grep -q "ticker:" "$MEMORY_DIR/finance/investing/_index.yaml" 2>/dev/null; then
      echo "⚠️  기존 investing/_index.yaml에 종목 데이터가 있습니다."
      echo "   knowledge/stocks/_index.yaml의 children 배열을 수동 갱신해주세요."
    fi
  fi

  # 빈 investing/ 삭제
  rmdir "$MEMORY_DIR/finance/investing/stocks" 2>/dev/null
  rmdir "$MEMORY_DIR/finance/investing/sectors" 2>/dev/null
  rmdir "$MEMORY_DIR/finance/investing" 2>/dev/null

  # 대분류 _index.yaml v10 스키마로 갱신
  # finance/_index.yaml을 v10 스키마로 전체 재작성 (heredoc)
  cat > "$MEMORY_DIR/finance/_index.yaml" << 'FIN_EOF'
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
updated: "DATEPLACEHOLDER"
FIN_EOF
  sed -i '' "s/DATEPLACEHOLDER/$(date +%Y-%m-%d)/" "$MEMORY_DIR/finance/_index.yaml"

  # finance/knowledge/_index.yaml 생성
  cat > "$MEMORY_DIR/finance/knowledge/_index.yaml" << 'KNOW_EOF'
children:
  - path: stocks/
    gist: "보유/관심 종목 투자 분석"
  - path: sectors/
    gist: "섹터/테마별 분석"
  - path: concepts/
    gist: "금융 개념 및 용어 정리"
updated: "DATEPLACEHOLDER"
KNOW_EOF
  sed -i '' "s/DATEPLACEHOLDER/$(date +%Y-%m-%d)/" "$MEMORY_DIR/finance/knowledge/_index.yaml"

  # work, life 대분류 _index.yaml도 v10 스키마로 갱신 (knowledge/, procedures/ 추가)
  # work/_index.yaml
  cat > "$MEMORY_DIR/work/_index.yaml" << 'WORK_EOF'
categories:
  - path: knowledge/
    description: "업무 지식 — 프로젝트, 기술, 도구"
  - path: procedures/
    description: "업무 원칙 — 코드 리뷰, 워크플로우"
updated: "DATEPLACEHOLDER"
WORK_EOF
  sed -i '' "s/DATEPLACEHOLDER/$(date +%Y-%m-%d)/" "$MEMORY_DIR/work/_index.yaml"

  # life/_index.yaml
  cat > "$MEMORY_DIR/life/_index.yaml" << 'LIFE_EOF'
categories:
  - path: diary/
    description: "일상일기"
    immutable: true
  - path: knowledge/
    description: "개인 지식 — 사람, 건강, 관심사"
  - path: procedures/
    description: "개인 원칙 — 루틴, 습관"
updated: "DATEPLACEHOLDER"
LIFE_EOF
  sed -i '' "s/DATEPLACEHOLDER/$(date +%Y-%m-%d)/" "$MEMORY_DIR/life/_index.yaml"

  # version 갱신
  sed -i '' 's/^version: 2$/version: 10/' "$MEMORY_DIR/.memory-config.yaml"

  git -C "$MEMORY_DIR" add -A
  git -C "$MEMORY_DIR" commit -m "memory: v9 → v10 마이그레이션"
  echo "v10 마이그레이션 완료!"
fi
```

- [ ] **Step 3: setup.sh 문법 검증**

```bash
bash -n /Users/siam/workspace/life/scripts/setup.sh
```

- [ ] **Step 4: Commit**

```bash
cd /Users/siam/workspace/life
git add scripts/setup.sh
git commit -m "feat(v10): setup.sh — v10 디렉토리 구조 + v9→v10 마이그레이션"
```

---

### Task 3: on-stop.sh + plugin.json 업데이트

**Files:**
- Modify: `hooks/scripts/on-stop.sh`
- Modify: `.claude-plugin/plugin.json`

- [ ] **Step 1: on-stop.sh 읽기 + 수정**

`last_accessed` 변경사항을 커밋에 포함시키는 로직 추가. 스펙 §8.1에 따라 `last_accessed` 갱신은 단독 commit하지 않고 세션 종료 시 미커밋 변경사항에 포함한다.

현재 on-stop.sh는 이미 미커밋 변경사항을 감지하여 경고한다. v10에서는 세션 종료 시 모든 미커밋 변경사항(`last_accessed` 갱신 포함)을 자동 커밋한다.

**주의:** `git add -A`는 `last_accessed`뿐 아니라 세션 중 발생한 모든 미커밋 변경을 포함한다. 이는 의도된 동작이다 — 세션 중 에이전트가 수행한 모든 memory 변경(자동 저장 포함)이 누락 없이 커밋된다.

```bash
# on-stop.sh: 기존 "미커밋 변경사항 경고" 부분을 "자동 커밋"으로 변경
if [ -n "$(git -C "$MEMORY_DIR" status --porcelain)" ]; then
  git -C "$MEMORY_DIR" add -A
  git -C "$MEMORY_DIR" commit -m "memory(auto): 세션 종료 — 미커밋 변경사항 저장"
fi
```

- [ ] **Step 2: plugin.json 버전 업데이트**

```json
{
  "name": "life-memory",
  "version": "3.0.0",
  "description": "뇌과학 기반 개인 기억 관리 시스템. 3-Tier 인코딩, 기억 유형 분리, 연상 네트워크로 일기, 투자 분석, 재무 데이터를 관리합니다."
}
```

- [ ] **Step 3: Commit**

```bash
cd /Users/siam/workspace/life
git add hooks/scripts/on-stop.sh .claude-plugin/plugin.json
git commit -m "feat(v10): on-stop.sh last_accessed 처리 + plugin.json 3.0.0"
```

---

## Chunk 2: Commands

> **의존성:** Task 1 (SKILL.md) 완료 후 실행. Task 4-8은 서로 독립적이므로 병렬 실행 가능.

### Task 4: remember.md — 3-Tier 저장 + 자동 공고화 제안

**Files:**
- Modify: `commands/remember.md`
- Reference: 스펙 §9 (/remember 동작 변경), §6 (지식 정리)

- [ ] **Step 1: 현재 remember.md + 스펙 §9, §6 읽기**

- [ ] **Step 2: remember.md 전면 재작성**

v9 remember.md의 기본 프레임(frontmatter, 대화 분석, 제안 생성, 승인)을 유지하되 v10 로직으로 교체.

**Frontmatter:** v9과 동일 (name: remember, description, allowed_tools 등)

**v9에서 유지:**
- $ARGUMENTS 분석 로직
- 대분류 판단 (finance/work/life)
- 일기 라우팅 ("투자일기" → finance/diary/, "일기" → life/diary/)
- 제안 블록 포맷 (📋, y/n/번호선택)
- 승인 입력 처리 (y/ㅇ/응, n/ㄴ/아니, 번호)
- 자동 저장 알림 포맷 (✓ ... · /undo)
- git commit 메시지 컨벤션 (memory: / memory(auto): / memory(tidy):)
- conviction 표기 (watching/low/medium/high로 갱신)
- opinion_log/transactions 아카이빙 (10/30건)

**v10 추가/변경:**

1. **기억 유형 판단 (§9 저장 흐름 Step 2):**
```
경험/감상 → diary/ (에피소드)
사실/데이터/분석 → knowledge/ (의미)
원칙/방법론/체크리스트 → procedures/ (절차)
```

2. **Tier 결정 (§9 Tier 결정 로직):**
```
한줄 메모/사실 → Tier 1 (_index.yaml gist) 또는 Tier 2 (단일 .yaml)
분석급 (테이블, 수치, 여러 섹션) → Tier 2 (.yaml) + Tier 3 (.md)
이미 디렉토리인 주제에 추가 → 해당 .md에 append
```

3. **자동 공고화 판단 (§6.1-6.2):** `/remember` 실행 시 에이전트가 자동으로 판단:
```
1. 언급된 주제에 기존 knowledge 파일이 있는가? → 갱신 제안
2. 관련 diary 3건+ 쌓여 있는가? → 패턴 추출(procedures) 제안
3. conviction/감정 변화 감지? → opinion_log 추가 제안
4. 새 수치/데이터 포함? → analysis.md 반영 제안
```
공고화 제안은 기존 제안 블록(📋)에 통합. 별도 프로세스 아님.

4. **links 자동 추론 (§9 저장 흐름 Step 5):**
기존 knowledge 파일과의 관계를 자동 추론하여 제안. 4종 관계(related, derived_from, depends_on, contradicts) 중 적절한 것 선택.

5. **tags 정규화 (§5.4):**
kebab-case 영문 소문자. 기존 태그 목록(_meta/registry.yaml)에서 매칭 우선, 필요시 새 태그.

6. **registry incremental 갱신 (§7.1):**
파일 생성/수정 후 `_meta/registry.yaml`의 tag_index, reverse_links를 incremental append.

7. **다중 도메인 동시 기록 (§9):**
- 제안 항목 5개 초과 시 도메인별 분리
- finance/ 제안은 SHOULD 소멸 예외 (1회 리마인드)
- 의존 항목은 묶음 표시 (개별 거부 불가)
- _index.yaml 갱신은 승인에 자동 포함

8. **디렉토리 승격 (§9):**
새 주제 + Tier 3급 → 바로 디렉토리 생성. 기존 .yaml에 상세 추가 → 승격 제안.

9. **제안 블록 v10 포맷 (§9 예시):**
```
📋 메모리 저장 제안:

1. [finance/knowledge] finance/knowledge/stocks/IREN/overview.yaml (신규)
   → thesis, conviction high, catalysts, 보유 0주

2. [finance/knowledge] finance/knowledge/stocks/IREN/analysis.md (신규)
   → 시설 4.5GW, MSFT $9.7B, 재무 모델, 경쟁사
   links: sectors/ai-infrastructure.md (related)

3. [finance/diary] finance/diary/2026/03/2026-03-15.md
   → "IREN 분석글 리뷰, 대체로 동의"

(y/n/번호선택)
```

10. **패턴 감지 사전 안내 (§6.5):**
- 2회째 패턴 → "비슷한 패턴이 이전에도 있었습니다 ([날짜])"
- 사용자 자기 인식 신호 ("또", "반복") → 카운트 무관 procedures 제안
- 패턴 카운트는 `_meta/consolidation-log.yaml`의 `detected_patterns:`에 캐싱
- **detected_patterns 스키마:**
```yaml
detected_patterns:
  - pattern: "fomo-chase-buy"      # kebab-case 패턴 식별자
    count: 3                        # 감지 횟수
    diary_refs:                     # 관련 diary 파일 경로
      - finance/diary/2026/03/2026-03-15.md
      - finance/diary/2026/03/2026-03-22.md
      - finance/diary/2026/04/2026-04-02.md
    last_seen: "2026-04-02"        # 마지막 감지 날짜
```

- [ ] **Step 3: 검증 — 제안 블록에 [유형] 라벨과 links 표시가 있는지 확인**

- [ ] **Step 4: Commit**

```bash
cd /Users/siam/workspace/life
git add commands/remember.md
git commit -m "feat(v10): remember.md — 3-Tier 저장, 자동 공고화 제안, 연상 네트워크"
```

---

### Task 5: recall.md — 점진적 깊이 인출

**Files:**
- Modify: `commands/recall.md`
- Reference: 스펙 §10 (/recall 동작 변경)

- [ ] **Step 1: 현재 recall.md + 스펙 §10 읽기**

- [ ] **Step 2: recall.md 전면 재작성**

**v9에서 유지:**
- frontmatter (name, description, allowed_tools)
- 종목명 → 직접 파일 읽기 패턴
- 시간 범위 → diary 검색 패턴
- "투자일기"/"일상일기" 라우팅
- "기억이 없습니다" 응답

**v10 추가/변경:**

1. **검색 경로 결정 (Phase 1, §10):**
```
종목명/인물명 → knowledge/stocks/_index.yaml (v10)
  → v10 경로 미존재 시: _meta/compat.yaml의 legacy_paths로 v9 경로 자동 매핑 (silent redirect)
시간 범위 → diary/ (v9과 동일)
주제 키워드 → registry.yaml 태그 검색 + _index.yaml 체인 + Glob/Grep fallback
"투자일기"/"일상일기" → diary/ (v9과 동일)
```
**v9 호환:** v9 경로(investing/)로 데이터를 찾은 경우 사용자에게 별도 안내 없이 silent redirect한다.

**참고:** 스펙에 "## 10"이 두 번 나타난다 — 첫 번째는 "/recall 동작 변경 + /forget 연쇄 삭제"(lines 805-882), 두 번째는 "새 커맨드"(lines 884-908). recall은 첫 번째 §10을 참조한다.

2. **점진적 깊이 인출 (§10):**
```
/recall IREN              → Tier 1 gist 응답 + "상세 정보 있음" 안내
/recall IREN Sweetwater   → 자동으로 Tier 3 analysis.md 탐색
/recall 내 손절 기준       → procedures/ 우선 검색
/recall AI 인프라 관련     → 태그 기반 교차 도메인 검색
```

3. **6단계 graceful degrade (§10):**
```
1. knowledge/ 검색
2. → 없으면 procedures/ 검색
3. → 없으면 diary/ 키워드 검색
4. → diary에서 찾으면: 결과 표시 + "knowledge로 정리할까요?" 제안
5. → 없으면 archive/ 검색
6. → 전부 없으면: "기억이 없습니다" + retrieval-failures.yaml 기록
```

4. **contradicts 표시 (§10):**
links에 contradicts 관계 파일 발견 시:
```
주의: 상충하는 정보가 있습니다.
- [bull] "..."
- [bear] "..."
```

5. **last_accessed 갱신 (Phase 4, §10):**
실제로 읽은 파일의 `last_accessed` frontmatter를 현재 날짜로 갱신.

6. **retrieval-failures.yaml 기록 (§7.2):**
인출 실패 시 `_meta/retrieval-failures.yaml`에 query, result, diagnosis 기록.

7. **공고화 제안 통합 (§6.1):**
diary에서 찾은 경우 "정리해둘까요?" 제안을 📋 블록으로 표시.

- [ ] **Step 3: 검증 — 6단계 graceful degrade 흐름이 명시되었는지 확인**

- [ ] **Step 4: Commit**

```bash
cd /Users/siam/workspace/life
git add commands/recall.md
git commit -m "feat(v10): recall.md — 점진적 깊이 인출, 6단계 graceful degrade"
```

---

### Task 6: forget.md — 연쇄 삭제 프로토콜

**Files:**
- Modify: `commands/forget.md`
- Reference: 스펙 §10 (/forget 연쇄 삭제 프로토콜)

- [ ] **Step 1: 현재 forget.md + 스펙 §10 (forget 섹션) 읽기**

- [ ] **Step 2: forget.md 전면 재작성**

**v9에서 유지:**
- frontmatter
- 삭제 범위 구분 (work/life/finance, diary 보호)
- 종목 파일 부분 삭제 (thesis 초기화, holdings 초기화 등)
- 확인 절차

**v10 추가/변경:**

1. **기본 동작 = archive/ 이동 (§10):**
삭제 요청 시 기본적으로 `archive/`로 이동. 완전 삭제는 사용자가 "완전히 지워줘" 명시 시에만.

2. **단일 파일 삭제 연쇄 (§10):**
```
1. 파일 → archive/ 이동 (또는 삭제)
2. 부모 _index.yaml에서 해당 항목 제거
3. _meta/registry.yaml에서 태그/링크 제거
```

3. **디렉토리 삭제 연쇄 (§10):**
```
1. 하위 파일 전체 → archive/ 이동
2. 상위 _index.yaml에서 해당 디렉토리 항목 제거
3. _meta/registry.yaml에서 관련 태그/링크 제거
```

4. **dangling link 처리 (§10):**
```
- registry.yaml의 reverse_links에서 삭제 대상을 참조하는 파일 목록 표시
- "이 파일들의 링크도 정리할까요?" 제안
- 승인 시 해당 파일들의 links:에서 삭제 대상 경로 제거
```

5. **안전장치 (§10):**
- 삭제 전 git commit 스냅샷 필수
- diary 불변 안내 (MUST 2)

**참고:** /forget 연쇄 삭제 프로토콜은 스펙 첫 번째 §10 (lines 858-880)을 참조한다.

- [ ] **Step 3: 검증**

forget.md에서 다음을 확인:
1. 기본 동작이 archive/ 이동인지 (완전 삭제는 명시 요청 시만)
2. 단일 파일/디렉토리 삭제 시 _index.yaml + registry 연쇄 정리가 명시되었는지
3. dangling link 처리 흐름이 있는지
4. 안전장치(git snapshot, diary 보호)가 명시되었는지

- [ ] **Step 4: Commit**

```bash
cd /Users/siam/workspace/life
git add commands/forget.md
git commit -m "feat(v10): forget.md — 연쇄 삭제 프로토콜, dangling link 처리"
```

---

### Task 7: memory.md — health 추가 + setup v10

**Files:**
- Modify: `commands/memory.md`
- Reference: 스펙 §7.3 (health-report), §10 (커맨드 목록), §12 (마이그레이션)

- [ ] **Step 1: 현재 memory.md + 스펙 관련 섹션 읽기**

- [ ] **Step 2: memory.md 전면 재작성**

**v9에서 유지:**
- frontmatter
- /memory sync (동일)
- /memory status (v10 경로 반영)
- /memory rebuild (v10 대응 추가)
- /memory tidy (동일)
- 온보딩 흐름

**v10 추가/변경:**

1. **`/memory health` 서브커맨드 추가:**

구조 건강도 점검 + 정리 후보 탐색. 다음 항목을 점검:
```
[§7.3 기반]
- 고아 파일 (아무 곳에서도 링크되지 않은 파일)
- 오래된 gist (30일+ 미갱신)
- 디렉토리 승격 후보 (4개 조건 중 하나 충족)
- 아카이브 후보 (6개월+ 미접근 + importance ≠ high + 링크 0개)
- 누락된 역방향 링크

[§6.1 기반 — health 트리거]
- 미반영 diary 탐색 (knowledge로 공고화 안 된 diary에서 정리 후보 탐색)
```

결과를 리포트로 표시 + `_meta/health-report.yaml`에 저장. 정리 제안 포함.

2. **`/memory setup` v10 갱신 (§12):**
- 신규: v10 디렉토리 구조 생성 (setup.sh 실행)
- 기존 v9: "v10으로 업그레이드할까요?" 제안 → 승인 시 setup.sh의 마이그레이션 로직 실행

3. **`/memory rebuild` v10 대응:**
- _index.yaml 재구축 (v9과 동일) + knowledge/, procedures/ 경로 포함
- `_meta/registry.yaml` 전체 재구축 (태그 인덱스 + 역방향 링크 스캔)

4. **help 출력 갱신 (§10):**
```
Life Memory 커맨드 목록:
- /remember <내용> — 기억 저장 (자동 분류 + 지식 정리 제안)
- /recall <검색어> — 기억 검색 (요약 먼저, 상세는 질문 따라)
- /forget <내용> — 기억 삭제
- /memory sync — 동기화
- /memory status — 현재 상태
- /memory setup — 초기 설정
- /memory health — 구조 건강도 + 정리 제안
- /memory rebuild — 인덱스 재생성
- /memory tidy — 구조 정리
- /undo — 되돌리기
```

- [ ] **Step 3: 검증**

memory.md에서 다음을 확인:
1. `/memory health` 서브커맨드가 정의되었는지
2. help 출력에 `/memory health`가 포함되었는지
3. setup이 v10 구조를 생성하는지
4. rebuild가 `_meta/registry.yaml` 재구축을 포함하는지
5. 모든 경로가 v10(knowledge/, procedures/, _meta/)을 사용하는지

- [ ] **Step 4: Commit**

```bash
cd /Users/siam/workspace/life
git add commands/memory.md
git commit -m "feat(v10): memory.md — /memory health 추가, setup v10 마이그레이션"
```

---

### Task 8: undo.md — 디렉토리 승격 지원

**Files:**
- Modify: `commands/undo.md`

- [ ] **Step 1: 현재 undo.md 읽기**

- [ ] **Step 2: undo.md 부분 수정**

v9 undo.md는 대부분 유지. 다음만 추가/변경:

1. **디렉토리 승격 commit 되돌리기 (검증 항목):**
기존 git revert 로직이 디렉토리 승격 commit을 올바르게 되돌리는지 확인한다. 승격은 단일 commit이므로 특별 처리 없이 원자적 revert가 가능해야 한다. undo.md에 "디렉토리 승격 commit도 /undo로 되돌릴 수 있다"는 안내 문구를 추가한다.

2. **registry 갱신 포함:**
revert 후 `_meta/registry.yaml`도 갱신해야 함을 명시:
```
revert 완료 후:
- 되돌린 파일의 태그/링크를 _meta/registry.yaml에서 제거
- 복원된 파일의 태그/링크를 _meta/registry.yaml에 재추가
```

3. **v10 커밋 메시지 패턴 추가:**
memory 커밋 필터에 `memory(v10-migration):` 패턴 추가 (마이그레이션 커밋도 되돌리기 가능).

- [ ] **Step 3: 검증**

undo.md에서 다음을 확인:
1. revert 후 `_meta/registry.yaml` 갱신이 명시되었는지
2. 디렉토리 승격 되돌리기 안내가 있는지
3. `memory(v10-migration):` 커밋 패턴이 필터에 포함되었는지

- [ ] **Step 4: Commit**

```bash
cd /Users/siam/workspace/life
git add commands/undo.md
git commit -m "feat(v10): undo.md — registry 갱신 + 디렉토리 승격 되돌리기 명시"
```

---

## Chunk 3: Documentation

> Task 9-10은 서로 독립적이므로 병렬 실행 가능.

### Task 9: ARCHITECTURE.md — v10 재작성

**Files:**
- Modify: `docs/ARCHITECTURE.md`
- Reference: 전체 스펙

- [ ] **Step 1: 현재 ARCHITECTURE.md 읽기**

- [ ] **Step 2a: v9 ARCHITECTURE.md 이동 보존**

```bash
cd /Users/siam/workspace/life
# docs/history/ 디렉토리는 이미 존재함 (ARCHITECTURE-V8.md, ITERATION-LOG.md)
git mv docs/ARCHITECTURE.md docs/history/ARCHITECTURE-V9.md
```

- [ ] **Step 2b: v10 ARCHITECTURE.md 작성**

새 `docs/ARCHITECTURE.md`를 작성한다. 각 섹션의 포함 내용:

```markdown
# Life Memory v10 Architecture

## 설계 동기
- 스펙 §1의 문제점 4가지 + 접근 방법 포함

## 뇌과학 원리 매핑 테이블
- 스펙 §2의 9행 테이블 그대로 포함 (뇌과학 원리 | 뇌에서의 역할 | 파일 시스템 매핑)

## 디렉토리 구조
- 스펙 §3의 전체 트리 구조 그대로 포함
- 구조 변경 요약 테이블 (v9 vs v10) 포함

## 3-Tier 인코딩
- Tier 1/2/3 정의 (각 2-3줄 요약)
- conviction 레벨 설명
- 디렉토리 승격 기준 4개 조건

## 연상 네트워크
- 4종 관계 테이블 포함
- registry.yaml의 역방향 인덱스 설명 (3줄 요약)
- 태그 정규화 규칙 (kebab-case)

## 지식 정리
- 자동 감지 트리거 4종 테이블
- 추출 기준 요약 (knowledge/procedures/diary유지)
- "에이전트가 자동 제안, 사용자가 승인" 원칙 명시

## 메타인지 시스템
- _meta/ 4개 파일 역할 1줄씩
- 피드백 루프 다이어그램 (스펙 §7.4)

## 아카이빙 정책
- 아카이브 후보 3조건 명시
- last_accessed/importance 설명

## 커맨드 동작 요약
- /remember: 3-Tier 저장 + 자동 공고화 제안
- /recall: 점진적 깊이 인출 + 6단계 graceful degrade
- /forget: 연쇄 삭제 + dangling link 처리 + archive 기본
- /memory health: 구조 건강도 + 정리 제안
- /undo: registry 갱신 포함

## MUST 규칙 (1-10)
- 10개 규칙 각 1줄 요약 (상세는 SKILL.md 참조 안내)

## v9 호환
- legacy_paths 매핑 설명
- lazy migration 전략

## v10 이후 로드맵
- 스펙 §13의 4행 테이블 그대로 포함 (간격 반복, 스키마, 작업 기억, 연결 강도)
```

**목표 길이:** 200-300줄. 스펙의 핵심을 압축하되, 테이블과 다이어그램은 그대로 유지.

- [ ] **Step 3: 검증**

ARCHITECTURE.md에서 다음을 확인:
1. 스펙 §1-§13의 모든 주제가 반영되었는지
2. 뇌과학 매핑 테이블이 포함되었는지
3. 커맨드 동작 요약에 5개 커맨드가 모두 있는지
4. MUST 규칙이 10개인지

- [ ] **Step 4: Commit**

```bash
cd /Users/siam/workspace/life
git add docs/history/ARCHITECTURE-V9.md docs/ARCHITECTURE.md
git commit -m "docs(v10): ARCHITECTURE.md 전면 재작성 + v9 이력 보존"
```

---

### Task 10: CLAUDE.md + README.md 업데이트

**Files:**
- Modify: `CLAUDE.md`
- Modify: `README.md`

- [ ] **Step 1: CLAUDE.md, README.md 읽기**

- [ ] **Step 2: CLAUDE.md 수정**

CLAUDE.md의 다음 섹션을 갱신:

1. **"8가지 MUST 규칙 요약" 섹션:** → "10가지 MUST 규칙 요약"으로 변경. MUST 9(3-Tier 일관성), MUST 10(공고화 시 diary 보존) 추가.
2. **"커맨드 목록" 섹션:** `/memory health — 구조 건강도 + 정리 제안` 추가.
3. **디렉토리 구조 관련 텍스트:** `investing/` → `knowledge/stocks/`, `knowledge/`, `procedures/`, `_meta/` 경로 반영.
4. **버전 참조:** "v2.1.0" → "v3.0.0" (있는 경우).

- [ ] **Step 3: README.md 수정**

README.md의 다음 섹션을 갱신:

1. **사용법 테이블:** `/memory health` 행 추가 (설명: "구조 건강도 점검 + 정리 제안").
2. **데이터 구조 섹션:** v10 디렉토리 트리로 교체 (knowledge/, procedures/, _meta/ 포함).
3. **"v10 주요 변경사항" 섹션 추가 (파일 끝):**
```markdown
## v10 주요 변경사항

- **3-Tier 인코딩**: gist(_index.yaml) → elaborated(.yaml) → source(.md) 단계별 저장
- **기억 유형 분리**: diary(에피소드) + knowledge(의미) + procedures(절차)
- **연상 네트워크**: 파일 간 links + 태그 인덱스로 교차 검색
- **자동 공고화**: /remember, /recall 중 에이전트가 지식 정리를 자동 제안
- **메타인지**: _meta/ 디렉토리로 구조 건강도 모니터링
- **`/memory health`**: 고아 파일, 아카이브 후보, 승격 후보 점검
- **경로 변경**: investing/ → knowledge/stocks/ (자동 마이그레이션 지원)
```

- [ ] **Step 4: 검증**

1. CLAUDE.md에 MUST 9, 10이 포함되었는지
2. README.md에 `/memory health`가 사용법 테이블에 있는지
3. 두 파일 모두 v10 경로(knowledge/, procedures/)를 사용하는지

- [ ] **Step 5: Commit**

```bash
cd /Users/siam/workspace/life
git add CLAUDE.md README.md
git commit -m "docs(v10): CLAUDE.md, README.md v10 갱신"
```

---

## 최종 검증

모든 Task 완료 후:

- [ ] `cd /Users/siam/workspace/life && git log --oneline -15` 로 커밋 이력 확인
- [ ] `bash -n scripts/setup.sh` 로 setup.sh 문법 검증
- [ ] `bash -n hooks/scripts/on-stop.sh` 로 on-stop.sh 문법 검증
- [ ] SKILL.md에 MUST 1-10 모두 존재하는지 확인
- [ ] 모든 커맨드 파일이 v10 경로(knowledge/, procedures/, _meta/)를 참조하는지 확인
- [ ] investing/ 경로가 compat.yaml과 recall.md v9 호환 fallback 외에는 사용되지 않는지 확인
- [ ] ARCHITECTURE.md에 v10 아키텍처 전체가 반영되었는지 확인
- [ ] `docs/history/ARCHITECTURE-V9.md` 존재 확인
- [ ] README.md에 `/memory health`가 포함되었는지 확인
- [ ] CLAUDE.md에 MUST 9, 10이 포함되었는지 확인
- [ ] plugin.json 버전이 3.0.0인지 확인
