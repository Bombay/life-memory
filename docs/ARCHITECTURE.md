# Life Memory Plugin v9 — 유연한 구조 관리

> v8 + diary 분리(finance/life) + 하위 구조 자율 관리 + 정리 제안 + 재구성 규칙.
> 핵심 테마: 대분류 고정 + 하위 자율, 에이전트 주도 정리, 정보 유실 방지.
> Iteration 1: tidy 포맷, 라우팅 기준, MUST 2 보강, 검색 규칙, _index.yaml MUST 격상.
> Iteration 2: tidy 쿨다운, 첫 사용 온보딩, 라우팅 키워드 가이드.
> 작성일: 2026-03-12

---

## 1. v9 변경사항 (v8 대비)

| # | v8 | v9 |
|---|-----|-----|
| 1 | diary/ 최상위 고정 | **삭제** — finance/diary/ + life/diary/로 분리 |
| 2 | work/, life/ 사전정의 파일 | **삭제** — 에이전트 자율 구성 |
| 3 | _index.yaml finance/investing/ 전용 | **범용화** — 모든 대분류에 _index.yaml |
| 4 | /memory tidy 없음 | **추가** — 정리 제안 + 재구성 |
| 5 | MUST 2: diary/ 경로 고정 | **패턴 변경** — `**/diary/**` 파일 불변 |
| 6 | 정리 시 이동만 | **재구성 전체 허용** — 분리/병합/이동/삭제 (diary 제외) |
| 7 | 쓰레기통/별도 복원 | **git 이력 + /undo로 통일** |

---

## 2. 핵심 원칙

1. **All-in Private Repo** — 모든 데이터는 private GitHub repo에 push
2. **제안-승인 워크플로** — 모든 메모리 기록/정리는 사용자 승인 후 실행
3. **능동적 메모리 관리** — 대화 중 정보 감지 시 자동 제안 + 구조 정리 제안

---

## 3. 플러그인 코드 구조

```
life-memory-plugin/
├── .claude-plugin/
│   └── plugin.json
├── commands/
│   ├── remember.md
│   ├── recall.md
│   ├── forget.md
│   ├── memory.md
│   └── undo.md
├── skills/
│   └── life-memory/
│       └── SKILL.md
├── hooks/
│   ├── hooks.json
│   └── scripts/
│       └── on-stop.sh
└── scripts/
    └── setup.sh
```

---

## 4. plugin.json

```json
{
  "name": "life-memory",
  "version": "2.0.0",
  "description": "개인 장기 기억 관리 시스템. 일기, 투자 분석, 재무 데이터를 private GitHub repo에 저장하고 검색합니다."
}
```

---

## 5. 메모리 레포지토리 구조 [v9 — 유연한 구조]

```
~/.life-memory/                              $LIFE_MEMORY_PATH (기본값)
├── .memory-config.yaml
├── .sync-conflict                           동기화 충돌 마커 (존재 시 충돌)
│
├── finance/                                 재무 전체
│   ├── _index.yaml                          finance/ 하위 구조 인덱스
│   ├── diary/                               투자일기 (불변)
│   │   └── 2026/
│   │       └── 03/
│   │           └── 2026-03-12.md
│   ├── investing/                           투자 (분석 + 보유 통합)
│   │   ├── _index.yaml                      종목 요약 + 보유 현황
│   │   ├── stocks/
│   │   │   ├── TSLA.yaml
│   │   │   └── 005930.yaml
│   │   ├── crypto/                          (필요 시 생성)
│   │   ├── etf/                             (필요 시 생성)
│   │   ├── sectors/
│   │   │   └── semiconductor.yaml
│   │   └── philosophy.yaml
│   ├── budget/
│   │   └── 2026-03.yaml
│   ├── accounts.yaml
│   └── transactions/                        비투자 거래
│       └── 2026/
│           └── 2026-03.yaml
│
├── work/                                    커리어
│   ├── _index.yaml                          work/ 하위 구조 인덱스
│   └── ...                                  (에이전트 자율 구성)
│
├── life/                                    개인 생활
│   ├── _index.yaml                          life/ 하위 구조 인덱스
│   ├── diary/                               일상일기 (불변)
│   │   └── 2026/
│   │       └── 03/
│   │           └── 2026-03-12.md
│   └── ...                                  (에이전트 자율 구성)
│
└── archive/
    ├── opinion-logs/
    │   └── TSLA-2025.yaml
    └── transactions/
        └── TSLA-2025.yaml
```

### 고정 vs 자율 구분

| 구분 | 경로 | 규칙 |
|------|------|------|
| **고정** | finance/investing/, finance/diary/, finance/budget/, finance/transactions/, life/diary/, archive/ | 구조 변경 불가 |
| **자율** | work/\*\*, life/\*\* (diary/ 제외), finance/ 내 신규 하위 | 에이전트가 _index.yaml과 함께 자유롭게 생성/정리 |

---

## 6. 파일 스키마 [v9]

### 6.1 일기 (투자일기 / 일상일기)

```markdown
# 2026-03-12

## 14:30
오늘 테슬라 10주 샀어. 250달러에.
FSD 완전 자율주행 승인 임박이라는 루머 때문에.

> extracted: finance/investing/stocks/TSLA.yaml
> tags: #투자 #테슬라 #FSD
```

- `life/diary/` — 일상일기: 하루 돌아보기
- `finance/diary/` — 투자일기: 투자 회고, 실수 반복 방지, 투자 가치관 형성
- 투자일기는 거래 감지로 자동 생성하지 않음. **사용자가 명시적으로 요청할 때만** 작성

### 6.2 종목 통합 파일 [v8 유지]

```yaml
# finance/investing/stocks/TSLA.yaml
ticker: "TSLA"
name: "Tesla Inc."

# 분석
thesis: "FSD 완전 자율주행 승인 임박 + EV 시장 리더"
conviction: "high"
target_price: "$300"
catalysts:
  bull:
    - "FSD 완전 자율주행 규제 승인 임박"
    - "로보택시 사업 런칭"
  bear:
    - "경쟁 심화 (BYD 등)"
    - "마진 압박"
tags: ["EV", "자율주행", "FSD"]

# 보유
holdings:
  quantity: 20
  avg_price: 245.00
  currency: "USD"
  first_buy: "2026-03-11"

# 최근 거래 (최대 30건, 초과 시 archive로 이동)
transaction_archive_years: [2025]
transactions:
  - date: "2026-03-11T14:30"
    type: "buy"
    quantity: 10
    price: 250.00
    note: "FSD 승인 루머"
  - date: "2026-03-15T10:00"
    type: "buy"
    quantity: 10
    price: 240.00
    note: "추가 매수"

# 의견 변화 로그 (최대 10건, 초과 시 archive로 이동)
opinion_archive_years: [2025]
opinion_log:
  - date: "2026-03-11T14:30"
    conviction: "high"
    note: "FSD 승인 루머로 확신 상향"
    source: "finance/diary/2026/03/2026-03-11.md"

last_updated: "2026-03-15"
```

**추가 매수 시 avg_price 계산**: 가중평균 — `(기존수량 × 기존평단가 + 신규수량 × 신규단가) / 총수량`. 부분 매도 시 avg_price는 변경하지 않음 (FIFO/LIFO 구분 없이 평균 유지).

**전량 매도 시 처리**: `holdings.quantity`를 0으로 설정, `_index.yaml`에서 `watching: false`로 변경. 파일은 삭제하지 않음 (거래 이력 보존).

### 6.3 investing/_index.yaml [v8 유지]

```yaml
# finance/investing/_index.yaml
stocks:
  - ticker: "TSLA"
    name: "Tesla Inc."
    conviction: "high"
    quantity: 20
    avg_price: 245.00
    currency: "USD"
    watching: true
    last_updated: "2026-03-15"
  - ticker: "005930"
    name: "삼성전자"
    conviction: "medium"
    quantity: 100
    avg_price: 68500
    currency: "KRW"
    watching: true
    last_updated: "2026-03-11"
```

### 6.4 대분류 _index.yaml [v9 — 신규]

```yaml
# life/_index.yaml
categories:
  - path: diary/
    description: "일상일기"
    immutable: true
  - path: health/
    description: "건강 기록, 운동, 컨디션"
  - path: people/
    description: "주변 사람 정보"
updated: "2026-03-12"
```

```yaml
# work/_index.yaml
categories:
  - path: projects/
    description: "진행 중인 프로젝트"
  - path: current-role.yaml
    description: "현재 직무 정보"
updated: "2026-03-12"
```

```yaml
# finance/_index.yaml
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
updated: "2026-03-12"
```

에이전트가 새 하위 폴더/파일을 생성할 때 `_index.yaml`에 항목을 추가한다. 정리 시에도 `_index.yaml`을 함께 업데이트한다.

### 6.5 월별 거래 (비투자) [v8 유지]

```yaml
# finance/transactions/2026/2026-03.yaml
month: "2026-03"
transactions:
  - date: "2026-03-12"
    category: "식비"
    amount: 15000
    currency: "KRW"
    note: "점심"
  - date: "2026-03-12"
    category: "구독"
    amount: 14.99
    currency: "USD"
    note: "Netflix"
```

### 6.6 .memory-config.yaml [v9 — tidy 설정 추가]

```yaml
version: 2
created: "2026-03-12"

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
  suggest_threshold: 20       # 한 폴더 내 파일 수가 이 값 초과 시 정리 제안
```

---

## 7. SKILL.md [v9 — 유연한 구조 관리]

```markdown
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

# Life Memory

사용자의 장기 기억 관리 시스템.

## 경로
Bash 도구로 `$LIFE_MEMORY_PATH`를 확인한다. 환경변수가 없으면 `~/.life-memory`를 사용한다.

## 대분류 (고정)
- finance/ : 재무 전체 (투자 분석+보유, 투자일기, 예산, 거래)
- work/ : 커리어 정보
- life/ : 개인 생활 정보 (일상일기 포함)
- archive/ : 오래된 로그 아카이브

## 하위 구조 관리
대분류 아래의 하위 폴더/파일은 에이전트가 자율적으로 생성/관리한다.
- 기록 시: 해당 대분류의 `_index.yaml`을 읽고, 적절한 위치를 판단하여 저장
- 적절한 카테고리가 없으면: 새 폴더/파일을 생성하고 `_index.yaml`에 추가
- 고정 경로(finance/investing/, finance/diary/, life/diary/, archive/)의 구조는 변경하지 않음

## MUST (절대 규칙)

### 1. 제안-승인
메모리 기록/정리 전 반드시 사용자 승인.
- smart 모드 자동 대상: diary 원문 추가, work/·life/ 기존 파일에 항목 append, finance/investing/ opinion_log append (conviction 미변경 시), catalysts/tags 수정
- 항상 승인 필요: holdings/transactions 변경, conviction/thesis 변경, 새 파일 생성, finance/budget·accounts·transactions 변경, 모든 정리(tidy) 작업
- finance/ 항목은 수량/가격/날짜 항상 상세 표시
- investing/_index.yaml 동기화는 원본 파일 승인에 포함 (별도 승인 불필요)
- 대분류 _index.yaml 업데이트는 관련 작업 승인에 포함 (별도 승인 불필요)
- 아카이빙(opinion_log, transactions 초과분 이동)은 저장 승인에 포함된 부수 동작 (별도 승인 불필요, archive 파일 신규 생성 포함)
- 자동 대상이라도 파일 미존재 시 새 파일 생성이므로 승인 경로로 전환
- fallback 규칙: 위 목록에 명시되지 않은 경우, 기존 파일의 기존 항목 수정/추가는 자동, 새 파일 생성은 승인, finance/ 금액/수량 변경은 항상 승인

### 2. 불변 파일 보존
다음 조건에 해당하는 파일은 절대 수정/삭제/이동하지 않는다:
- `**/diary/**` 경로의 파일 (finance/diary/, life/diary/)
- `_index.yaml`에서 `immutable: true`로 표시된 경로의 파일
- diary 외에 일기성 폴더를 별도 이름으로 생성하지 않는다 (journal/, my-diary/ 등 금지)

### 3. 세션 초기화
첫 메모리 접근 시:
- .sync-conflict 존재 → "동기화 충돌이 있습니다. /memory sync로 해결해주세요."
- 정상 → git pull --rebase 실행 (실패 시 로컬 그대로 진행)

### 4. 과장·모호 표현 확인
finance/ 수량/가격 변경 시 과장·모호 표현("다 팔았어", "올인", "풀매수", "손절", "정리했어", "좀 줄였어", "많이 샀어") 확인 필수.

### 5. 금융 거래 감지 시 저장 제안
금융 거래(매수/매도, 가격, 수량)가 대화에서 감지되면 반드시 저장을 제안한다.
코딩/디버깅 중이라도 금융 거래는 1줄 알림으로 제안한다.

### 6. 금융 데이터 충돌 시 상세 확인
finance/ 데이터가 기존 값과 다를 때 수량/가격/날짜를 반드시 상세 확인한다.

### 7. _index.yaml 동기화 필수
새 파일/폴더 생성, 삭제, 이동 시 해당 대분류의 `_index.yaml`을 반드시 함께 업데이트한다.
- investing/_index.yaml: 종목 데이터 변경 시
- 대분류 _index.yaml (finance/, work/, life/): 하위 구조 변경 시
- _index.yaml 업데이트는 관련 작업 승인에 포함 (별도 승인 불필요)

### 8. 정리 시 정보 유실 금지
정리(tidy) 작업에서 정보가 유실되어서는 안 된다.
- diary 파일: 어떤 작업도 금지 (수정/삭제/이동 불가)
- 나머지 파일: 분리/병합/이동/삭제 모두 허용 (승인 필수)
- 정리 실행 전 반드시 git commit으로 현재 상태 스냅샷
- 모든 정리 작업은 /undo로 복원 가능

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

### 충돌 해결
- 의견/판단: opinion_log에 이전 값 보존 후 업데이트
- 사실 정보: 변경일 기록 후 덮어쓰기

### 콘텐츠 가드레일
공개 콘텐츠(유튜브 스크립트, 블로그, SNS) 생성 시 finance/ 보유 수량, 평단가, 거래 내역은 포함하지 않는다.
포함이 필요하면 사용자에게 "보유 정보를 공개 콘텐츠에 포함할까요?"로 확인한다.
```

---

## 8. 커맨드 상세 명세 [v9]

### 8.1 /remember

```markdown
---
description: "기억에 정보를 저장합니다"
argument-hint: "<기억할 내용>"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

사용자가 다음과 같이 요청했습니다: $ARGUMENTS

## 동작
1. $ARGUMENTS 분석. 없으면 직전 대화에서 저장할 정보 탐색.
2. 대상 대분류 판단 → 해당 _index.yaml 읽기 → 적절한 위치 결정.
3. 저장할 파일과 내용의 제안 생성.
4. 사용자 승인 대기.
5. 승인 → 파일 기록 + _index.yaml 동기화 + git commit.
6. 결과 보고.

## 일기 라우팅
- "일기 써줘", "일기 기록해줘" → life/diary/ (일상일기)
- "투자일기 기록해줘", "투자일기 써줘" → finance/diary/ (투자회고)
- "기록해줘", "기억해줘" → 내용 분석하여 라우팅:
  - 금융 키워드(매수/매도/수익률/종목명/가격/지출) → finance/
  - 업무 키워드(회의/프로젝트/업무/팀/회사/배포) → work/
  - 그 외 → life/
  - 다중 도메인 해당 시 → 각 도메인별로 제안 (사용자가 번호로 선택)
  - 키워드 목록은 대표 예시이며 에이전트는 의미 기반으로 판단한다. 판단이 모호하면 다중 도메인 제안으로 분기

## 제안 블록 공식 포맷

태그: `[finance]`, `[work]`, `[life]` — 대분류명 사용.

---
📋 메모리 저장 제안:

1. [life] life/diary/2026/03/2026-03-12.md
   → 일상일기 원문 추가

2. [finance] finance/investing/stocks/TSLA.yaml
   → TSLA 10주 @$250 매수 + opinion_log 추가
   확인: 테슬라 10주를 주당 $250에 매수한 것이 맞습니까?

3. [work] work/projects/life-memory-plugin.yaml
   → 프로젝트 상태 업데이트

(y/n/번호선택)
---

## 승인 입력
- y/ㅇ/응 → 전체 승인
- n/ㄴ/아니 → 전부 거부
- 1,3 → 해당 번호만 승인
- 그 외 텍스트 → 수정 요청

5개 이상 항목은 요약 모드 (d로 상세 전환).

## smart 모드 자동 저장 범위
- 자동: diary 원문 추가, work/·life/ 기존 파일에 항목 append, finance/investing/ opinion_log append (conviction 미변경 시), catalysts/tags 수정
- 승인 필요: holdings/transactions 변경, conviction/thesis 변경, 새 파일 생성, finance/budget·accounts·transactions 변경
- fallback: 명시되지 않은 경우 → 기존 파일 수정/추가는 자동, 새 파일 생성은 승인, finance/ 금액/수량 변경은 항상 승인

## 자동 저장 알림
`✓ 일상일기 + 삼성전자 실적 메모 저장됨 · /undo`
파일 경로 대신 사람이 이해하는 내용 요약. 중립적 톤.

## 운영 규칙

### _index.yaml 동기화 (MUST 7 준수)
종목/프로젝트 추가/삭제/수정 시 investing/_index.yaml, 하위 구조 변경 시 대분류 _index.yaml 함께 업데이트.

### opinion_log 아카이빙
10건 초과 시 가장 오래된 항목을 archive/opinion-logs/{TICKER}-{year}.yaml로 이동.
종목 파일의 opinion_archive_years에 해당 연도 추가.

### transactions 아카이빙
30건 초과 시 가장 오래된 항목을 archive/transactions/{TICKER}-{year}.yaml로 이동.
종목 파일의 transaction_archive_years에 해당 연도 추가.
holdings는 변경하지 않음 (현재 보유 상태만 반영).

### conviction 가이드라인
| 레벨 | 의미 | 표현 |
|------|------|------|
| high | 적극 매수/보유 | "확실해", "베팅할 만해" |
| medium | 관망/유지 | "괜찮은 것 같아" |
| low | 불안/매도 고려 | "불안해", "빠져야 하나" |
| none | 관심 없음 | "모르겠어" |

### 자산 클래스 확장
finance/investing/ 하위에 stocks/ 외에 crypto/, etf/ 등 새 자산 클래스 디렉토리를 필요 시 생성.
- 새 자산 클래스 등장 시: "finance/investing/crypto/ 디렉토리를 생성할까요?" 확인 후 생성
- 각 자산 클래스에 동일한 investing/_index.yaml 항목 + 개별 파일 구조 적용
- setup.sh에서는 stocks/만 초기 생성

### git commit 메시지
- 수동 승인: `memory: [요약]` (예: `memory: TSLA 10주 매수 + FSD 투자의견`)
- 자동 저장: `memory(auto): [요약]` (예: `memory(auto): 일상일기 + 삼성전자 실적 메모`)
- 정리: `memory(tidy): [요약]` (예: `memory(tidy): life/ 하위 건강 기록 분리`)
```

### 8.2 /recall

```markdown
---
description: "기억을 검색합니다"
argument-hint: "<검색할 내용>"
allowed-tools: [Read, Glob, Grep]
---

사용자가 다음을 검색합니다: $ARGUMENTS

## 동작
1. $ARGUMENTS에서 검색 키워드/시간범위/종목명 파싱
2. 검색 실행 → 결과 정리

## 검색 전략
- 종목/인물명 → investing/_index.yaml 또는 대분류 _index.yaml 확인 → 해당 파일 직접 읽기
  - opinion_archive_years/transaction_archive_years 확인 → 과거 데이터 요청 시 archive/ 포함
- 시간 범위("2월에", "지난주") → diary 파일 검색 (life/diary/ + finance/diary/) + opinion_log 날짜 필터
  - archive_years 확인 → 필요 시 archive/ 파일도 검색
- "투자일기" 명시 → finance/diary/만 검색
- "일상일기" 명시 → life/diary/만 검색
- "일기" (단독) → life/diary/ + finance/diary/ 양쪽 검색
- 검색 결과에 출처 표시: `[일상일기]` / `[투자일기]`
- 주제 키워드 → 대분류 _index.yaml 우선 확인 → 관련 파일 검색
  - finance/transactions/는 "거래", "지출", "얼마" 등 재무 키워드 시에만 포함
- 월간 지출 ("이번 달 얼마 썼어?") → finance/transactions/ 합산. 투자 거래 포함 여부는 사용자에게 확인.

## 빈 결과
"[키워드]에 대한 기억이 없습니다."
```

### 8.3 /forget

```markdown
---
description: "기억을 삭제합니다"
argument-hint: "<삭제할 내용>"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

사용자가 삭제를 요청합니다: $ARGUMENTS

## 동작
1. $ARGUMENTS로 삭제 대상 검색
2. 영향 범위 제안 (제안-승인)
3. 승인 → 삭제/수정 + _index.yaml 동기화 + git commit

## 삭제 범위
- work/, life/ 파일: 삭제 가능 (일반 확인)
- finance/ 파일: 삭제 가능 (항상 상세 확인)
- **/diary/: 원문 보존 → 삭제하지 않음 (안내)

## 통합 파일 부분 삭제
종목 파일(finance/investing/stocks/*.yaml)은 분석+보유가 통합되어 있으므로:
- 단순 삭제 요청("지워줘") → 기본적으로 전부 삭제 제안
- "분석 지워줘/초기화" → thesis/conviction/catalysts 초기화 (conviction: "none", thesis: null, catalysts: {bull: [], bear: []}), holdings/transactions 유지
- "보유 정보 지워줘" → holdings 초기화 (quantity: 0, avg_price: 0), transactions 유지, 분석 데이터 유지
- "전부 지워줘" → 파일 삭제 + _index.yaml 동기화
- 3가지 옵션을 매번 제시하지 않음. 사용자 발화에 "분석" 또는 "보유"가 명시된 경우에만 부분 삭제.

## 대상 없음
"[키워드]에 대한 기억이 없어 삭제할 항목이 없습니다."

## 동기화
모든 관련 파일 변경을 하나의 git commit으로 묶음.
```

### 8.4 /memory

```markdown
---
description: "메모리 시스템을 관리합니다"
argument-hint: "<sync|status|setup|rebuild|tidy|help>"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

서브커맨드: $ARGUMENTS

## /memory (인자 없음) 또는 /memory help

Life Memory 커맨드 목록:
- /remember <내용> — 기억 저장
- /recall <검색어> — 기억 검색
- /forget <내용> — 기억 삭제
- /memory sync — 동기화
- /memory status — 현재 상태
- /memory setup — 초기 설정
- /memory rebuild — 인덱스 재생성
- /memory tidy — 구조 정리
- /undo — 되돌리기

## /memory sync
- .sync-conflict 존재 시: 충돌 내용 표시 + 로컬/원격 선택 → 해결 후 .sync-conflict 삭제
- 정상 시: git pull --rebase + git push + 결과 보고

## /memory status
- 대분류별 하위 구조 요약 (_index.yaml 기반)
- 마지막 동기화 시각
- 미커밋 변경 여부
- 최근 저장 5건 (git log --oneline -5 --grep="memory")

## /memory setup
- 초기 설정 + 설정 변경 통합
- 초기: 디렉토리 생성 + config 생성 + git 설정
- 기존: 현재 설정 표시 + 변경 가이드

## /memory rebuild [디렉토리]
- 지정 디렉토리의 _index.yaml을 실제 파일/폴더 기준으로 재생성
- 인자 없으면 전체 재생성
- 사용자가 명시적으로 요청한 관리 작업이므로 별도 승인 불필요

## /memory tidy [대분류]
구조 정리 작업을 실행한다.
1. 지정 대분류(또는 전체)의 _index.yaml과 실제 폴더 비교
2. 정리 필요 항목 분석:
   - 파일이 많은 폴더 → 하위 분류 제안
   - _index.yaml에 없는 파일 → 인덱스 추가 제안
   - 유사 파일 분산 → 통합 제안
   - 빈 폴더 → 삭제 제안
3. 변경 계획을 사용자 친화적 목록으로 제안:
   ```
   📋 정리 제안 (life/):

   1. life/exercise-log.yaml → life/health/exercise-log.yaml로 이동
   2. life/ 아래 건강 기록 3개 → life/health/ 폴더로 통합
   3. work/ 아래 빈 폴더 1개 삭제

   (y/n/번호선택) — 문제 시 /undo로 되돌릴 수 있습니다.
   ```
4. 사용자 승인 대기 (번호 선택으로 부분 승인 가능)
5. 승인 → git commit(스냅샷) → 정리 실행 → git commit(정리 완료)
6. 결과 보고

### 정리 작업 규칙 (MUST 8 준수)
- diary 파일: 어떤 작업도 금지
- 나머지: 분리/병합/이동/삭제 모두 허용
- 정리 전 반드시 git commit (스냅샷)
- 정보 유실 금지 — 내용을 버리는 정리는 하지 않음
- /undo로 복원 가능

## 온보딩
- $LIFE_MEMORY_PATH 경로 없거나 .memory-config.yaml 없으면 setup 안내
- 첫 /remember 성공 시: "저장 완료! /recall로 검색할 수 있습니다."
- 첫 자동 저장 발생 시 1회: "smart 모드: 금액/핵심판단 변경 외에는 자동 저장됩니다. /undo로 되돌릴 수 있습니다."
- 도메인별 첫 사용 시 1회 팁:
  - work/ 첫 기록: "work/ 도메인에 처음 기록합니다. 내용에 맞는 구조를 자동으로 생성합니다."
  - life/ 첫 기록 (diary 외): "life/ 도메인에 새 카테고리를 생성합니다."
  - finance/ 첫 투자 기록: "투자 정보를 기록합니다. /recall로 언제든 검색할 수 있습니다."
```

### 8.5 /undo

```markdown
---
description: "메모리 변경을 되돌립니다"
argument-hint: "[번호|--more|--since 날짜]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

옵션: $ARGUMENTS

## 동작
1. 최근 memory 커밋 목록 표시 (기본 10건, memory: 또는 memory(auto): 또는 memory(tidy): 접두사)
2. 되돌릴 커밋 선택 (기본: 가장 최근)
3. 변경 파일 목록 + 미리보기 → 승인
4. 승인 → 되돌리기 + _index.yaml 동기화 + git commit

## 옵션
- /undo → 최근 10건 표시
- /undo --more → 최근 30건 표시
- /undo --since 3d → 3일 이내 커밋만 표시
- /undo 3 → 목록의 3번 커밋 되돌리기

## 연쇄 /undo
revert 커밋은 건너뛰고 다음 memory 커밋을 대상으로 함.

## 부분 되돌리기
변경 파일 번호 표시 → "2번만 되돌려줘" 가능.
git revert --no-commit 후 원하는 파일만 복원 → 새 커밋.

## diary 보호 (MUST 2 준수)
**/diary/ 파일이 포함된 커밋을 되돌릴 때, diary 파일은 자동 제외.
- revert 대상에 diary 파일이 포함되면: "diary 파일은 원본 보존 규칙에 따라 제외됩니다." 안내
- git revert --no-commit → diary 파일 checkout으로 원복 → 나머지만 커밋
- diary 파일만 포함된 커밋은 되돌리기 불가 안내
```

---

## 9. hooks.json

```json
{
  "hooks": {
    "Stop": [
      {
        "type": "command",
        "command": "bash ${CLAUDE_PLUGIN_ROOT}/hooks/scripts/on-stop.sh",
        "timeout": 30
      }
    ]
  }
}
```

---

## 10. on-stop.sh

```bash
#!/bin/bash
set -euo pipefail

MEMORY_PATH="${LIFE_MEMORY_PATH:-$HOME/.life-memory}"

if [[ ! -d "$MEMORY_PATH/.git" ]]; then
  exit 0
fi

cd "$MEMORY_PATH"

# 미커밋 변경사항 경고
if [[ -n $(git status --porcelain 2>/dev/null) ]]; then
  echo "[life-memory] 경고: 커밋되지 않은 변경사항이 있습니다."
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
  git rebase --abort 2>/dev/null || true
  echo "conflict_detected: $(date -u +%Y-%m-%dT%H:%M:%SZ)" > .sync-conflict
  echo "[life-memory] 동기화 충돌 발생. /memory sync로 해결해주세요."
  exit 0
fi

git push "$REMOTE" "$BRANCH" --quiet 2>/dev/null || {
  echo "[life-memory] push 실패. /memory sync를 실행해주세요."
}
```

---

## 11. setup.sh [v9 — 유연한 구조]

```bash
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
  git init
  echo "✓ Git 초기화"
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
  echo "Remote 미설정. GitHub private repo 생성 후:"
  echo "  git remote add origin git@github.com:USERNAME/life-memory.git"
  echo "  git push -u origin main"
fi

if [[ -z "${LIFE_MEMORY_PATH:-}" ]]; then
  echo ""
  echo "환경변수 설정 권장:"
  echo "  echo 'export LIFE_MEMORY_PATH=$MEMORY_PATH' >> ~/.zshrc"
fi

echo ""
echo "=== 설정 완료 ==="
echo "커맨드: /remember, /recall, /forget, /memory, /undo"
```

---

## 12. 버전 이력 요약

| 버전 | 핵심 변경 | 시뮬레이션 |
|------|----------|-----------|
| v4 | 맥락 격리, 제안-승인, 능동적 제안 도입 | 8개 시나리오 |
| v5 | state/ 폐지, _index.yaml, portfolio 분할, opinion_log 아카이빙 | 12개 엣지케이스 |
| v6 | SKILL.md 간소화, 버그 수정, UX 정제 | 10개 V5 검증 |
| v7 | plugin.json/frontmatter/hooks 구조 수정, MUST 보강 | 8개 장기 사용 + 15개 E2E |
| v8 | 격리 제거, facts/ 삭제, 투자+보유 통합, 도메인 플랫 구조 | 30+ 시나리오, 5회 Ralph Loop |
| **v9** | **diary 분리, 하위 자율 구조, _index.yaml 범용화, /memory tidy, 재구성 규칙** | — |

> V9이 최초 배포 버전입니다. V4~V8은 설계 과정의 중간 산물이며, 마이그레이션은 해당 없습니다.
