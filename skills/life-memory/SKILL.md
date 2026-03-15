---
name: life-memory
description: |
  Use when the user mentions remembering, saving, recalling information,
  or discusses diary, investments, stocks, portfolio, finances, budgets,
  career, personal life, or any context where long-term personal memory
  management is relevant. Also activate when user says "기억", "저장",
  "메모리", "일기", "투자일기", "투자", "포트폴리오", "매수", "매도",
  "포폴", "수입", "지출", "기록", or asks to remember/recall/forget something.
---

# Life Memory v10

사용자의 장기 기억 관리 시스템. 뇌과학 기반 기억 아키텍처.

## 우선순위 규칙

MUST(절대 규칙) > SHOULD(권장 규칙).
MUST는 어떤 상황에서도 위반 불가. SHOULD는 상황에 따라 유연하게 적용.

## 데이터 위치

Bash 도구로 `$LIFE_MEMORY_PATH`를 확인한다. 환경변수가 없으면 `~/.life-memory`를 사용한다.

**주의**: 이 플러그인의 코드 레포(life-memory)와 사용자 데이터 레포(life-vault 등)는 별개이다.
데이터 접근 시 반드시 `$LIFE_MEMORY_PATH`(또는 기본값 `~/.life-memory`)를 사용하고, 플러그인 설치 경로를 메모리 저장소로 혼동하지 않는다.

### 디렉토리 구조

```
~/.life-memory/
├── _meta/                              # 메타인지 (전전두엽)
│   ├── registry.yaml                   # 태그 인덱스 + 역방향 링크 맵
│   ├── consolidation-log.yaml          # 공고화 실행 이력
│   ├── retrieval-failures.yaml         # 인출 실패 기록
│   └── health-report.yaml             # 구조 건강도
│
├── finance/
│   ├── diary/                          # 에피소드 기억 (해마)
│   │   └── 2026/03/2026-03-15.md
│   │
│   ├── knowledge/                      # 의미 기억 (측두엽 신피질)
│   │   ├── _index.yaml
│   │   ├── stocks/
│   │   │   ├── _index.yaml             # 전 종목 gist 목록
│   │   │   ├── TSLA.yaml               # 단순 종목 = 단일 파일
│   │   │   └── IREN/                   # 복잡 종목 = 디렉토리 승격
│   │   │       ├── _index.yaml         # IREN gist + children 맵
│   │   │       ├── overview.yaml       # thesis, holdings, opinion_log
│   │   │       ├── analysis.md         # 시설, 계약, 재무 모델
│   │   │       └── earnings/           # 분기 실적 (필요시)
│   │   │           └── 2026-Q1.md
│   │   ├── sectors/
│   │   │   └── ai-infrastructure.md
│   │   └── concepts/
│   │       └── ppa-contracts.md
│   │
│   ├── procedures/                     # 절차 기억 (기저핵/소뇌)
│   │   ├── position-sizing.md
│   │   └── stop-loss-rules.md
│   │
│   ├── budget/                         # v9 호환
│   ├── accounts.yaml                   # v9 호환
│   └── transactions/                   # v9 호환
│
├── work/
│   ├── diary/
│   ├── knowledge/
│   │   ├── _index.yaml
│   │   ├── projects/
│   │   │   └── catcut/
│   │   │       ├── _index.yaml
│   │   │       ├── overview.yaml
│   │   │       └── architecture.md
│   │   └── skills/
│   │       └── remotion-patterns.md
│   └── procedures/
│       └── code-review-checklist.md
│
├── life/
│   ├── diary/
│   ├── knowledge/
│   │   ├── _index.yaml
│   │   ├── people/
│   │   ├── health/
│   │   └── interests/
│   └── procedures/
│       └── morning-routine.md
│
└── archive/                            # 적응적 망각 (망각 목적지)
    ├── finance/
    ├── work/
    └── life/
```

## 기억 유형

대분류(finance/work/life) 아래에 세 종류의 기억 저장소가 존재한다.

### diary/ — 에피소드 기억 (해마)
- "언제, 어디서, 무엇을" 경험한 기록
- **판단 기준:** 경험, 감상, 감정, 회고, 그날의 시장 반응
- 예: 투자일기, 일상일기, 프로젝트 회고
- 생성 후 **불변** (MUST 2, MUST 10)

### knowledge/ — 의미 기억 (측두엽 신피질)
- 맥락에서 분리된 사실, 데이터, 분석
- **판단 기준:** 확인된 수치/데이터, 인과 관계, 인물/기관 정보, 분석 리포트
- 예: 종목 분석, 섹터 리서치, 금융 개념, 프로젝트 아키텍처
- 갱신 가능, 디렉토리 승격 가능

### procedures/ — 절차 기억 (기저핵/소뇌)
- "어떻게" — 방법론, 원칙, 체크리스트
- **판단 기준:** 반복 패턴 3회+ 추출, 명시적 원칙 선언, 체크리스트/프레임워크
- 예: 포지션 사이징 규칙, 손절 기준, 코드 리뷰 체크리스트
- 갱신 가능, `history:` 필드로 변경 이력 관리

### 하위 구조 관리
대분류 아래의 하위 폴더/파일은 에이전트가 자율적으로 생성/관리한다.
- 기록 시: 해당 대분류의 `_index.yaml`을 읽고, 기억 유형(diary/knowledge/procedures)과 적절한 위치를 판단하여 저장
- 적절한 카테고리가 없으면: 새 폴더/파일을 생성하고 `_index.yaml`에 추가
- 고정 경로(finance/knowledge/stocks/, finance/diary/, life/diary/, archive/)의 구조는 변경하지 않음

## 3-Tier 인코딩

Craik & Lockhart의 처리 수준 이론을 파일 구조에 반영한다.

### Tier 1: Gist (얕은 인코딩)

`_index.yaml`의 한 줄 요약. `/recall`의 1차 응답. 최소 토큰 소비. **gist는 50자 이내 1문장 권장.**

### Tier 2: Elaborated (정교화 인코딩)

`overview.yaml` — 기존 v9 종목 스키마 수준 + `links:`, `sources:`, `relevance:` 확장.

### Tier 3: Source (깊은 인코딩)

`.md` 파일 — 상세 데이터, 테이블, 출처, 근거. 필요할 때만 로드.

### conviction 레벨 (투자 종목 필수)

```
watching — 관심 종목, 아직 분석 전 (기본값: 사용자가 미명시 시)
low     — 분석했으나 확신 낮음
medium  — 투자 고려 중
high    — 강한 확신, 보유 중이거나 매수 의향
```

**투자 종목 gist conviction 컨벤션:** 투자 종목의 gist에는 반드시 conviction을 포함한다. 포맷: `"{thesis 한줄}. conviction {level}."` conviction이 변경되면 gist도 반드시 갱신하며, 이는 부모 `_index.yaml` 연쇄 갱신을 트리거한다. 사용자가 conviction을 명시하지 않으면 `watching`을 기본값으로 적용한다.

### _index.yaml 계층별 스키마

**대분류 _index.yaml** — `categories:` 스키마:

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
updated: "2026-03-15"
```

**knowledge _index.yaml** — 하위 도메인 맵:

```yaml
# finance/knowledge/_index.yaml
children:
  - path: stocks/
    gist: "보유/관심 종목 투자 분석"
  - path: sectors/
    gist: "섹터/테마별 분석"
  - path: concepts/
    gist: "금융 개념 및 용어 정리"
updated: "2026-03-15"
```

**stocks _index.yaml** — 종목 gist 목록:

```yaml
# finance/knowledge/stocks/_index.yaml
children:
  - path: TSLA.yaml
    gist: "자율주행 + 에너지 전환. conviction high."
  - path: IREN/
    gist: "BTC채굴→AI IaaS 전환. 4.5GW, MSFT $9.7B. conviction high."
  - path: NVDA.yaml
    gist: "AI 컴퓨팅 독점. conviction high."
tags: [portfolio, stocks]
```

### MUST 7 v10 갱신

파일 변경 시, 해당 파일이 속한 **직계 부모** `_index.yaml`을 반드시 업데이트한다. 상위 계층의 `_index.yaml`은 gist가 변경되는 경우에만 갱신. **연쇄 갱신 최대 깊이: 3단계.** 3단계 초과 시 상위 갱신을 보류하고, 다음 `/memory health`에서 일관성을 점검한다.

예: `IREN/analysis.md` 갱신 시 → `IREN/_index.yaml` 필수 갱신. `stocks/_index.yaml`은 IREN gist가 변하지 않으면 갱신 불필요.

### 디렉토리 승격 기준

단일 `.yaml` 파일이 아래 조건 중 하나를 충족하면 디렉토리로 승격을 제안한다.

```
1. 파일 200줄 초과
2. 독립적 하위 주제 3개 이상
3. 상세 분석 요청 2회 이상
4. opinion_log 10건 + Tier 3 데이터 존재
```

승격 시:
```
IREN.yaml → IREN/
              ├── _index.yaml     (gist + children 맵)
              ├── overview.yaml   (기존 YAML 이관)
              └── analysis.md     (상세)
```

승격은 MUST 1(제안-승인) 규칙을 따른다. 에이전트가 제안하고 사용자가 승인해야 실행. **디렉토리 승격(및 강등)은 모든 관련 파일 변경(_index.yaml, registry 갱신 포함)을 단일 git commit으로 수행한다.** `/undo`로 승격 전체를 되돌릴 수 있다.

## 파일 스키마

### overview.yaml (Tier 2)

```yaml
# finance/knowledge/stocks/IREN/overview.yaml
ticker: "IREN"
name: "Iris Energy"
relevance: "AI 인프라 수요 폭증 시 가장 큰 수혜주 후보"

thesis: "BTC채굴→AI IaaS 전환. 4.5GW 전력 확보 + MSFT $9.7B 계약"
conviction: "high"
target_price: "$840 (2030, P/E 35x)"

catalysts:
  bull:
    - "2026.4 Sweetwater 1 에너지화 (1,400MW)"
    - "2026.5 Horizon 1 MSFT 수익 개시"
    - "4.5GW 전체 가동 시 순이익 $13.7B"
  bear:
    - "$100B+ 자본 조달 필요"
    - "40%+ 주식 희석"
    - "AI 수요 급감 가능성"
tags: ["AI인프라", "데이터센터", "IaaS", "재생에너지"]

holdings:
  quantity: 0
  avg_price: 0

transactions: []
opinion_log:
  - date: "2026-03-15"
    conviction: "high"
    note: "barebirk 분석글 리뷰 — 대체로 동의"

links:
  - path: finance/knowledge/sectors/ai-infrastructure.md
    relation: related
  - path: finance/knowledge/stocks/NVDA.yaml
    relation: related

sources:
  - url: "https://barebirk.substack.com/p/iren-the-45gw-ai-powerhouse"
    title: "IREN: The 4.5GW AI Powerhouse"
    date: "2026-03-15"

last_accessed: "2026-03-15"
last_updated: "2026-03-15"
```

### Tier 3 .md frontmatter (knowledge)

```markdown
---
title: "IREN 투자 분석"
last_updated: 2026-03-15
tags: [iren, ai-infra, data-center, facilities, msft-deal]
links:
  - path: finance/knowledge/stocks/IREN/overview.yaml
    relation: derived_from
sources:
  - url: "https://barebirk.substack.com/p/iren-the-45gw-ai-powerhouse"
    title: "barebirk 분석글"
    date: "2026-03-15"
---
```

### procedures .md frontmatter

```yaml
# finance/procedures/stop-loss-rules.md frontmatter 예시
---
title: "손절 규칙"
last_updated: 2026-03-15
last_accessed: 2026-03-15
importance: high
tags: [risk-management, stop-loss]
links:
  - path: finance/knowledge/stocks/IREN/overview.yaml
    relation: related
history:
  - date: "2026-03-15"
    change: "손절선 -10% 설정"
  - date: "2026-03-20"
    change: "-10% → -15% 변경"
---
```

**MUST 1 적용:** 기존 procedures의 수치/원칙 변경은 "승인 필요"이다. 금액은 아니지만 원칙 변경이므로, 에이전트가 제안하고 사용자가 승인해야 반영한다.

### diary .md frontmatter

diary 파일은 **생성 시점에** 최소 frontmatter를 포함할 수 있다. 생성 후 frontmatter 수정은 금지.

```markdown
---
tags: [iren, fomo]
mentions: [finance/knowledge/stocks/IREN/overview.yaml]
---

## 14:30
오늘 IREN Sweetwater 지연 뉴스 봤는데...
```

- `tags:` — kebab-case, 검색용. 에이전트가 diary 본문에서 자동 추출.
- `mentions:` — 본문에서 언급된 knowledge/procedures 파일 경로. 교차 도메인 참조 추적용.

## 연상 네트워크

### links: 필드 프로토콜

모든 YAML/MD 파일의 frontmatter에 선택적 `links:` 필드를 둔다.

```yaml
links:
  - path: finance/knowledge/sectors/ai-infrastructure.md
    relation: related
```

### 관계 유형 (4종)

| 관계 | 의미 | 예시 |
|---|---|---|
| `related` | 동등 수준 연관 (양방향) | IREN ↔ NVDA |
| `derived_from` | 이 지식의 출처 | analysis.md → diary/2026-03-15.md |
| `depends_on` | 이해에 필요한 선행 지식 | IREN → PPA 계약 개념 |
| `contradicts` | 상충하는 정보 — **파일 간** 관계에만 적용 (양방향) | 분석A.md ↔ 분석B.md. overview.yaml 내 bull/bear는 구조적으로 공존하므로 contradicts 대상 아님 |

### 역방향 인덱스 (중앙 관리)

개별 파일은 자신의 **outgoing link만** 관리한다. 역방향 인덱스는 `_meta/registry.yaml`에서 중앙 관리한다.

```yaml
# _meta/registry.yaml (발췌)
reverse_links:
  finance/knowledge/sectors/ai-infrastructure.md:
    - path: finance/knowledge/stocks/IREN/overview.yaml
      relation: related
    - path: finance/knowledge/stocks/NVDA.yaml
      relation: related
```

- 파일 편집 시 한 곳만 수정 (outgoing link)
- 역방향 탐색은 registry에서 조회
- 동기화 실패 위험 최소화
- registry는 공고화 시점에 일괄 재구축

### 태그 인덱스 + 정규화 규칙

```yaml
# _meta/registry.yaml (발췌)
tag_index:
  ai-infra:
    - finance/knowledge/stocks/IREN/_index.yaml
    - finance/knowledge/stocks/NVDA.yaml
    - finance/knowledge/sectors/ai-infrastructure.md
    - work/knowledge/projects/catcut/_index.yaml
  bitcoin-mining:
    - finance/knowledge/stocks/IREN/_index.yaml
    - finance/knowledge/sectors/bitcoin-mining.md
```

태그 기반 검색으로 도메인(finance/work/life)을 가로지르는 연상 인출을 지원한다.

**태그 정규화 규칙:**
- 태그는 항상 **kebab-case 영문 소문자**로 저장한다 (예: "AI 인프라" → `ai-infra`)
- 한국어 태그는 영문 변환 필수 (에이전트가 자동 변환)
- 검색 시 사용자 입력을 동일 정규화 적용 후 매칭
- 동의어 처리: 없음 (정규화된 태그 기준으로만 매칭, Glob/Grep fallback이 동의어 역할을 대체)

### 교차 도메인 중복 관리

동일 주제가 여러 도메인에서 사용될 때, 원본은 **한 곳(주 도메인)**에만 저장한다. 다른 도메인에서는 `links:`의 `derived_from`으로 참조한다.

- **원칙:** 데이터 중복 복사 금지
- **예:** IREN 투자 데이터의 원본은 `finance/knowledge/stocks/IREN/`에만 저장. 유튜브 리서치에서 IREN 데이터가 필요하면 `work/knowledge/projects/`에서 `links: [{path: finance/knowledge/stocks/IREN/overview.yaml, relation: derived_from}]`로 연결
- 어느 도메인이 "주 도메인"인지는 해당 정보가 **처음 생성된 맥락**으로 판단한다 (투자 분석 → finance, 프로젝트 리서치 → work)

## 지식 정리 (Consolidation)

뇌의 시스템 공고화(해마 → 신피질)를 모방한다. 에피소드(diary)에서 패턴을 추출하여 의미 기억(knowledge)과 절차 기억(procedures)으로 정제한다.

**핵심 원칙: 별도 `/consolidate` 커맨드는 없다.** 에이전트가 사용자의 자연스러운 행동(일기 쓰기, 정보 기록, 검색) 과정에서 자동으로 판단하고 제안한다.

### 트리거 — 사용자 행동에 반응

지식 정리는 **기존 커맨드 실행 중에 에이전트가 자동 감지**하여 제안한다.

| 사용자 행동 | 에이전트 감지 | 제안 |
|---|---|---|
| 일기 쓰기 (`/remember 투자일기...`) | 일기에 언급된 주제의 knowledge 파일 확인 + 관련 diary 건수 확인 | "IREN 분석 파일도 업데이트할까요?" |
| 새 정보 기록 (`기억해줘...`) | 기존 knowledge와 충돌/보강 여부 판단 | "기존 IREN 분석에 이 정보를 반영할까요?" |
| 검색 (`/recall`) | 인출 실패인데 diary에 관련 내용 존재 | "diary에서 찾았습니다. 정리해둘까요?" |
| 건강도 점검 (`/memory health`) | 전체 스캔으로 정리 후보 탐색 | "정리 후보 N건 발견" 리포트 |

**제안 형태:**
- 저장 제안 블록(📋)에 기존 항목과 함께 포함. 별도 프로세스가 아님.
- 무시하면 자동 소멸 (기존 SHOULD 규칙과 동일)

### 내부 판단 로직

에이전트가 `/remember` 또는 diary 기록 시 수행하는 자동 판단:

```
1. 언급된 주제에 대한 기존 knowledge 파일이 있는가?
   → 있으면: 새 정보가 기존 파일과 충돌/보강하는지 판단
   → 없으면: 정보량이 Tier 2/3급이면 새 파일 생성 제안

2. 관련 diary가 3건+ 쌓여 있는가?
   → diary들에서 반복 패턴(감정, 행동, 판단)이 보이는가?
   → 보이면: procedures 생성 제안

3. conviction/감정 변화가 감지되는가?
   → overview.yaml의 opinion_log 추가 제안

4. 새로운 수치/데이터가 포함되어 있는가?
   → 기존 analysis.md에 반영 제안
```

이 판단은 **제안 블록에 통합**된다. 사용자는 번호 선택으로 원하는 것만 승인하면 된다.

### 추출 기준

**knowledge로 추출:**
- 새로운 수치/데이터 (매출, MW, 가격 등) — 1회 등장이면 충분
- 확인된 인과 관계 ("A 때문에 B가 됐다") — 추측("~인 것 같다")은 미추출
- 새로운 인물/기관 정보 — 1회 등장이면 충분

**procedures로 추출:**
- 동일 패턴 **3회 이상** 반복 시 (예: "FOMO 매수 → 후회" 3회)
- 명시적 원칙 선언 ("다시는 이렇게 안 하겠다") — 1회라도 명시적이면 추출
- 체크리스트, 프레임워크 — 1회 등장이면 충분

**diary에만 유지 (추출 안 함):**
- 그날의 감정 ("짜증남", "불안함")
- 일시적 시장 반응 ("오늘 -3%")
- 맥락 없는 단편 메모
- 추측성 인과 ("~인 것 같다" 수준)

**판단이 모호한 경우:** 사용자에게 확인한다.
```
"이 내용을 knowledge로 추출할까요, diary에만 남길까요?"
```

**추출/미추출 예시:**

| diary 내용 | 판정 | 이유 |
|---|---|---|
| "IREN의 Sweetwater 시설은 1,400MW" | knowledge 추출 | 확인된 수치 데이터 |
| "IREN 때문에 오늘 기분 좋다" | diary 유지 | 감정 |
| "IREN이 -5% 빠졌다" | diary 유지 | 일시적 시장 반응 |
| "FOMO로 또 추격매수했다 (3번째)" | procedures 추출 | 동일 패턴 3회 |
| "IREN이 AI 전환하면 좋을 것 같다" | diary 유지 | 추측, 미확인 |
| "MSFT 계약 $9.7B 5년" | knowledge 추출 | 확인된 계약 데이터 |

### diary 불변 원칙

diary 파일은 생성 후 수정하지 않는다 (MUST 2, MUST 10). 공고화 추적은 `_meta/consolidation-log.yaml`에만 기록한다.

diary의 `tags:`는 검색 경로에 반영되어, `/recall` 시 태그 기반으로 diary도 발견된다.

### 패턴 감지 사전 안내

- **2회째 감지 시:** diary 기록 제안과 함께 가벼운 안내 추가: "비슷한 패턴이 이전에도 있었습니다 ([날짜] diary 참고)."
- **사용자 자기 인식 신호** ("또", "반복", "같은 실수", "지난번에도"): 카운트와 관계없이 "원칙으로 정리해볼까요?" 제안 허용. 이는 "명시적 원칙 선언 — 1회라도 명시적이면 추출"과 같은 맥락.
- **패턴 카운팅:** `_meta/consolidation-log.yaml`에 `detected_patterns:` 섹션을 둬서 패턴 횟수를 캐싱. diary 전수 스캔을 매번 하지 않는다.

**detected_patterns 스키마:**

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

## 메타인지 (_meta/)

### registry.yaml

전체 기억의 지도. 태그 인덱스 + 역방향 링크 맵.

- `/recall` 시 보조 탐색 경로. 1차는 `_index.yaml` + 파일시스템 직접 탐색도 병행.
- 수동 갱신 없음 (시스템이 관리)

**갱신 타이밍:**
- **즉시 (incremental)**: `/remember`로 파일 생성/수정 시 해당 파일의 태그/링크를 registry에 append
- **전체 재구축**: 공고화 시 전체 파일 스캔으로 일관성 보장
- **fallback**: `/recall`은 registry 외에 `_index.yaml` 체인 + 파일시스템 Glob/Grep도 병행. registry가 비어 있어도 검색 가능.

### retrieval-failures.yaml

```yaml
failures:
  - date: "2026-03-15"
    query: "IREN Sweetwater 시설 건설 일정"
    result: not_found
    diagnosis: "diary에만 존재, knowledge로 공고화 필요"
    resolution: pending

stats:
  total: 8
  resolved: 5
  pending: 3
  top_patterns:
    - pattern: "상세 데이터가 diary에만 존재"
      count: 4
      suggestion: "공고화 실행 권장"
```

인출 실패 3건+ 누적 시 패턴 분석 → 구조 개선 제안.

### health-report.yaml

`/memory health` 커맨드로 생성. 점검 항목:

- 고아 파일 (아무 곳에서도 링크되지 않은 파일)
- 오래된 gist (30일+ 미갱신)
- 디렉토리 승격 후보
- 아카이브 후보 (6개월+ 미접근 + 링크 0개)
- 누락된 역방향 링크

### consolidation-log.yaml

공고화 이력 (entries + detected_patterns).

```yaml
# _meta/consolidation-log.yaml 예시
entries:
  - date: "2026-03-15"
    source: finance/diary/2026/03/2026-03-15.md
    extracted_to:
      - finance/knowledge/stocks/IREN/analysis.md
      - finance/knowledge/stocks/IREN/overview.yaml

detected_patterns:
  - pattern: "fomo-chase-buy"
    count: 3
    diary_refs:
      - finance/diary/2026/03/2026-03-15.md
      - finance/diary/2026/03/2026-03-22.md
      - finance/diary/2026/04/2026-04-02.md
    last_seen: "2026-04-02"
```

### 피드백 루프

```
사용자의 자연스러운 행동
  │
  ├── /remember (기록)
  │     → 관련 knowledge 존재? → 갱신 제안
  │     → 관련 diary 3건+? → 패턴 추출 제안
  │     → 새 주제? → knowledge 파일 생성 제안
  │
  ├── /recall (검색)
  │     ├── 성공 → last_accessed 갱신
  │     └── 실패 → retrieval-failures.yaml 기록
  │                   → diary 탐색 → "정리해둘까요?" 제안
  │
  └── /memory health (점검 — 사용자가 원할 때)
        → 전체 스캔: 정리 후보, 고아 파일, 아카이브 후보
        → 리포트 + 개선 제안
```

모든 제안은 기존 제안 블록(📋)에 통합되며, 사용자가 y/n/번호로 선택한다.

## 아카이빙 정책

### last_accessed + importance 메타데이터

모든 knowledge/procedures 파일에 선택적 필드:

```yaml
last_accessed: "2026-03-15"    # /recall 시 자동 갱신
importance: "high"              # high/medium/low
```

**importance 규칙:**
- 기본값: 미설정 = `medium`
- 에이전트 자동 설정: 종목 파일에 holdings.quantity > 0 → `high`. conviction "high" → `high`.
- 사용자 명시 설정: MUST 1(제안-승인)에 포함 — 별도 승인 불필요 (자동 대상)
- 변경 이력: opinion_log에 기록 (importance가 변할 만한 이유가 있을 때)

**last_accessed git commit 정책:**
- `last_accessed` 갱신은 단독으로 git commit하지 않는다
- 세션 종료 시 `on-stop.sh`에서 미커밋 변경사항에 포함되어 자동 push

### 아카이브 후보 기준

```
조건 1: last_accessed가 6개월 이상 전
AND
조건 2: importance가 "high"가 아님
AND
조건 3: 다른 파일에서 링크되지 않음 (registry 역방향 링크 0건)
```

세 조건 모두 충족 시 `/memory health`에서 아카이브 후보로 제안.

### v9 건수 기반 유지

opinion_log 10건, transactions 30건 건수 기반 아카이빙은 v9과 동일하게 유지. 접근 빈도 기반은 knowledge/procedures 파일에만 적용.

### diary 아카이빙 불가

diary는 불변 (MUST 2). 아카이빙 대상이 아니다.

## MUST (절대 규칙)

### 1. 제안-승인
메모리 기록/정리 전 반드시 사용자 승인.
- smart 모드 자동 대상: diary 원문 추가, work/·life/ 기존 파일에 항목 append, finance/knowledge/stocks/ opinion_log append (conviction 미변경 시), catalysts/tags 수정
- 항상 승인 필요: holdings/transactions 변경, conviction/thesis 변경, 새 파일 생성, finance/budget·accounts·transactions 변경, 모든 정리(tidy) 작업
- finance/ 항목은 수량/가격/날짜 항상 상세 표시
- knowledge/stocks/_index.yaml 동기화는 원본 파일 승인에 포함 (별도 승인 불필요)
- 대분류 _index.yaml 업데이트는 관련 작업 승인에 포함 (별도 승인 불필요)
- 아카이빙(opinion_log, transactions 초과분 이동)은 저장 승인에 포함된 부수 동작 (별도 승인 불필요, archive 파일 신규 생성 포함)
- 자동 대상이라도 파일 미존재 시 새 파일 생성이므로 승인 경로로 전환
- diary 디렉토리 내 날짜 기반 신규 파일 생성은 smart 모드 자동 대상의 예외로 허용 (별도 승인 불필요)
- fallback 규칙: 위 목록에 명시되지 않은 경우, 기존 파일의 기존 항목 수정/추가는 자동, 새 파일 생성은 승인, finance/ 금액/수량 변경은 항상 승인

### 2. 불변 파일 보존
다음 조건에 해당하는 파일은 절대 수정/삭제/이동하지 않는다:
- `**/diary/**` 경로의 파일 (finance/diary/, life/diary/, work/diary/)
- `_index.yaml`에서 `immutable: true`로 표시된 경로의 파일
- diary 외에 일기성 폴더를 별도 이름으로 생성하지 않는다 (journal/, my-diary/ 등 금지)

### 3. 세션 초기화
첫 메모리 접근 시:
- .sync-conflict 존재 → 충돌 내용 분석 + 해결 제안 + 사용자 승인 후 해결 실행 (/memory sync와 동일한 충돌 해결 절차)
- 정상 → git pull --rebase 실행. 실패 시 원인별 경고 후 로컬 그대로 진행:
  - remote 없음 → "Remote가 설정되지 않아 동기화를 건너뜁니다. /memory setup으로 설정할 수 있습니다."
  - 네트워크 오류 → "네트워크 오류로 동기화를 건너뜁니다. 로컬 데이터로 진행합니다."
  - 충돌 → .sync-conflict 기록 후 충돌 해결 절차 진입

### 4. 과장·모호 표현 확인
finance/ 수량/가격 변경 시 과장·모호 표현("다 팔았어", "올인", "풀매수", "손절", "정리했어", "좀 줄였어", "많이 샀어") 확인 필수.

### 5. 금융 거래 감지 시 저장 제안
금융 거래(매수/매도, 가격, 수량)가 대화에서 감지되면 반드시 저장을 제안한다.
코딩/디버깅 중이라도 금융 거래는 1줄 알림으로 제안한다.

### 6. 금융 데이터 충돌 시 상세 확인
finance/ 데이터가 기존 값과 다를 때 수량/가격/날짜를 반드시 상세 확인한다.

### 7. _index.yaml 동기화 필수
파일 변경 시, 해당 파일이 속한 **직계 부모** `_index.yaml`을 반드시 업데이트한다. 상위 계층의 `_index.yaml`은 gist가 변경되는 경우에만 갱신. **연쇄 갱신 최대 깊이: 3단계.** 3단계 초과 시 상위 갱신을 보류하고, 다음 `/memory health`에서 일관성을 점검한다.
- knowledge/stocks/_index.yaml: 종목 데이터 변경 시
- knowledge/_index.yaml: 하위 도메인 구조 변경 시
- 대분류 _index.yaml (finance/, work/, life/): 하위 구조 변경 시
- _index.yaml 업데이트는 관련 작업 승인에 포함 (별도 승인 불필요)

### 8. 정리 시 정보 유실 금지
정리(tidy) 작업에서 정보가 유실되어서는 안 된다.
- diary 파일: 어떤 작업도 금지 (수정/삭제/이동 불가)
- 나머지 파일: 분리/병합/이동/삭제 모두 허용 (승인 필수)
- 정리 실행 전 반드시 git commit으로 현재 상태 스냅샷
- 모든 정리 작업은 /undo로 복원 가능

### 9. 3-Tier 일관성
디렉토리 승격된 knowledge 항목은 반드시 `_index.yaml`(Tier 1) + `overview.yaml`(Tier 2)을 가져야 한다. Tier 3 (.md)는 선택적.

### 10. 공고화 시 diary 원본 완전 보존
diary 내용을 knowledge로 추출할 때, diary 파일은 일체 수정하지 않는다. 공고화 추적은 `_meta/consolidation-log.yaml`에만 기록한다. 이는 MUST 2(불변 파일 보존)를 보강한다.

## SHOULD (권장 규칙)

### 능동적 제안
의견 변화, 새 사실, 개인 정보 변경 감지 시 응답 말미에 저장 제안.
- 무시된 제안은 자동 소멸 (다른 주제로 넘어가면)
- finance/ 제안은 1회 리마인드 후 소멸

### 구조 정리 제안
기록 작업 중 _index.yaml을 읽을 때 정리 필요성을 감지하면 제안.
- 한 폴더에 파일이 tidy.suggest_threshold(기본 20)건 초과 시
- _index.yaml에 없는 파일 발견 시
- 유사한 파일이 다른 폴더에 분산되어 있을 시
- 제안 형태: 응답 말미에 "💡 life/ 폴더에 파일이 많아졌습니다. /memory tidy로 정리할 수 있습니다."
- 무시 시 자동 소멸. 같은 폴더에 대해 파일이 5건 이상 추가되기 전까지 재제안하지 않음

### 공고화 제안
일기 쓰기, 새 정보 기록, 검색 실패 시 지식 정리를 자동 감지하여 제안 블록에 포함한다.

### 교차 도메인 링크
여러 도메인에 걸치는 정보 발견 시 `links:` 연결을 제안한다.

### registry 갱신
`/remember`로 파일 생성/수정 시 `_meta/registry.yaml`의 태그/링크를 incremental 갱신한다.

### 충돌 해결
- 의견/판단: opinion_log에 이전 값 보존 후 업데이트
- 사실 정보: 변경일 기록 후 덮어쓰기

### 콘텐츠 가드레일
공개 콘텐츠(유튜브 스크립트, 블로그, SNS) 생성 시 finance/ 보유 수량, 평단가, 거래 내역은 포함하지 않는다.
포함이 필요하면 사용자에게 "보유 정보를 공개 콘텐츠에 포함할까요?"로 확인한다.

## v9 호환

### legacy_paths 매핑

```yaml
# _meta/compat.yaml
version: 10
legacy_paths:
  "finance/investing/stocks/": "finance/knowledge/stocks/"
```

v9 경로(`investing/`)로 접근 시 v10 경로(`knowledge/stocks/`)로 자동 리다이렉트한다.

### 대분류 행동 규칙
- finance/ : 재무 전체 (투자 분석+보유, 투자일기, 예산, 거래)
  - knowledge/stocks/ : 종목별 투자 분석 (v9의 investing/stocks/)
  - knowledge/sectors/ : 섹터/테마별 분석
  - knowledge/concepts/ : 금융 개념 정리
  - procedures/ : 투자 원칙, 방법론
  - diary/ : 투자일기
- work/ : 커리어 정보
  - knowledge/ : 프로젝트, 스킬
  - procedures/ : 업무 원칙
  - diary/ : 업무 회고
- life/ : 개인 생활 정보
  - knowledge/ : 사람, 건강, 관심사
  - procedures/ : 생활 루틴
  - diary/ : 일상일기
- archive/ : 오래된 로그 아카이브
