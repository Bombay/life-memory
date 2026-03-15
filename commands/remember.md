---
description: "기억에 정보를 저장합니다"
argument-hint: "<기억할 내용>"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

사용자가 다음과 같이 요청했습니다: $ARGUMENTS

## 동작

1. $ARGUMENTS 분석. 없으면 직전 대화에서 저장할 정보 탐색.
2. 대분류 판단 (finance/work/life).
3. 기억 유형 판단 (diary/knowledge/procedures).
4. Tier 결정 (gist / .yaml / .md / 디렉토리).
5. 자동 공고화 판단 (§6 내부 로직).
6. 저장할 파일과 내용의 제안 생성.
7. 사용자 승인 대기.
8. 승인 → 파일 기록 + _index.yaml 동기화 + registry incremental 갱신 + git commit.
9. 결과 보고.

## 일기 라우팅

- "일기 써줘", "일기 기록해줘" → life/diary/ (일상일기)
- "투자일기 기록해줘", "투자일기 써줘" → finance/diary/ (투자회고)
- "기록해줘", "기억해줘" → 내용 분석하여 라우팅:
  - 금융 키워드(매수/매도/수익률/종목명/가격/지출) → finance/
  - 업무 키워드(회의/프로젝트/업무/팀/회사/배포) → work/
  - 그 외 → life/
  - 다중 도메인 해당 시 → 각 도메인별로 제안 (사용자가 번호로 선택)
  - 키워드 목록은 대표 예시이며 에이전트는 의미 기반으로 판단한다. 판단이 모호하면 다중 도메인 제안으로 분기

## 기억 유형 판단

내용을 분석하여 세 가지 기억 유형 중 적절한 것을 결정한다.

| 내용 성격 | 기억 유형 | 저장 경로 |
|---|---|---|
| 경험, 감상, 감정, 회고 | 에피소드 (diary) | `*/diary/` |
| 사실, 데이터, 분석, 인물/기관 정보 | 의미 (knowledge) | `*/knowledge/` |
| 원칙, 방법론, 체크리스트, 반복 패턴 추출 | 절차 (procedures) | `*/procedures/` |

## Tier 결정 로직

정보량에 따라 저장 깊이를 결정한다.

```
정보량 판단:
  한줄 메모/사실 → Tier 1 (기존 파일의 gist에 추가) 또는 Tier 2 (단일 .yaml)
  분석급 (테이블, 수치, 여러 섹션) → Tier 2 (.yaml) + Tier 3 (.md)
  이미 디렉토리인 주제에 추가 → 해당 디렉토리의 적절한 .md에 append
  새 주제 + Tier 3급 정보량 → 바로 디렉토리로 생성 (overview.yaml + .md)
```

### 디렉토리 승격 타이밍

- 새 주제 + 정보량이 Tier 3급 → 바로 디렉토리로 생성 (overview.yaml + .md)
- 기존 단일 .yaml에 상세 추가 요청 → "디렉토리로 승격할까요?" 제안
- 승격 기준: 파일 200줄 초과, 독립 하위 주제 3개+, 상세 분석 요청 2회+, opinion_log 10건 + Tier 3 데이터

## 자동 공고화 판단

에이전트가 `/remember` 실행 중 **자동으로** 아래 판단을 수행하고, 해당 사항이 있으면 제안 블록에 통합한다. 별도 프로세스가 아니다.

```
1. 언급된 주제에 대한 기존 knowledge 파일이 있는가?
   → 있으면: 새 정보가 기존 파일과 충돌/보강하는지 판단 → 갱신 제안
   → 없으면: 정보량이 Tier 2/3급이면 새 파일 생성 제안

2. 관련 diary가 3건+ 쌓여 있는가?
   → diary들에서 반복 패턴(감정, 행동, 판단)이 보이는가?
   → 보이면: procedures 생성 제안

3. conviction/감정 변화가 감지되는가?
   → overview.yaml의 opinion_log 추가 제안

4. 새로운 수치/데이터가 포함되어 있는가?
   → 기존 analysis.md에 반영 제안
```

이 판단 결과는 **제안 블록(📋)에 기존 항목과 함께 포함**된다. 사용자는 번호 선택으로 원하는 것만 승인하면 된다. 1번(diary)만 선택하면 나머지는 무시된다.

## 패턴 감지 사전 안내

- **2회째 감지 시:** diary 기록 제안과 함께 가벼운 안내 추가: "비슷한 패턴이 이전에도 있었습니다 ([날짜] diary 참고)."
- **사용자 자기 인식 신호** ("또", "반복", "같은 실수", "지난번에도"): 카운트와 관계없이 "원칙으로 정리해볼까요?" 제안 허용.
- **패턴 카운팅:** `_meta/consolidation-log.yaml`의 `detected_patterns:` 섹션에서 캐싱. diary 전수 스캔을 매번 하지 않는다.

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

## links 자동 추론

저장할 파일과 기존 knowledge 파일 사이의 관계를 에이전트가 자동 추론하여 제안에 포함한다.

### 관계 유형 (4종)

| 관계 | 의미 | 예시 |
|---|---|---|
| `related` | 동등 수준 연관 (양방향) | IREN ↔ NVDA |
| `derived_from` | 이 지식의 출처 | analysis.md → diary/2026-03-15.md |
| `depends_on` | 이해에 필요한 선행 지식 | IREN → PPA 계약 개념 |
| `contradicts` | 상충하는 정보 (파일 간, 양방향) | 분석A.md ↔ 분석B.md |

### 추론 규칙

- 동일 섹터/테마 → `related`
- diary에서 추출한 knowledge → `derived_from`
- 선행 개념이 필요한 분석 → `depends_on`
- 기존 분석과 상충하는 새 정보 → `contradicts`

## tags 정규화

- kebab-case 영문 소문자로 저장 (예: "AI 인프라" → `ai-infra`)
- 한국어 태그는 영문 변환 필수 (에이전트가 자동 변환)
- `_meta/registry.yaml`의 `tag_index`에서 기존 태그 목록 확인 → 매칭 우선
- 기존 태그에 없는 경우에만 새 태그 생성

## 제안 블록 공식 포맷 (v10)

태그: `[finance/knowledge]`, `[finance/diary]`, `[work/knowledge]`, `[life/procedures]` 등 — 대분류/기억유형 사용. links 표시 포함.

---
📋 메모리 저장 제안:

1. [finance/knowledge] finance/knowledge/stocks/IREN/overview.yaml (신규)
   → thesis, conviction high, catalysts, 보유 0주

2. [finance/knowledge] finance/knowledge/stocks/IREN/analysis.md (신규)
   → 시설 4.5GW, MSFT $9.7B, 재무 모델, 경쟁사
   links: sectors/ai-infrastructure.md (related)

3. [finance/diary] finance/diary/2026/03/2026-03-15.md
   → "IREN 분석글 리뷰, 대체로 동의"

(y/n/번호선택)
---

### 공고화 제안 통합 예시

일기 기록 중 자동 공고화가 감지된 경우:

---
📋 메모리 저장 제안:

1. [finance/diary] finance/diary/2026/03/2026-03-22.md
   → 투자일기 기록

2. [finance/knowledge] IREN/overview.yaml — opinion_log 추가 (제안)
   → conviction 변화: "Sweetwater 지연으로 불안감 표현"

3. [finance/knowledge] IREN/analysis.md — 타임라인 갱신 (제안)
   → Sweetwater 1 상태: "지연 가능성 보도"

(y/n/번호선택) — 1만 선택하면 일기만 기록됩니다.
---

### 패턴 감지 → procedures 제안 예시

---
📋 메모리 저장 제안:

1. [finance/diary] finance/diary/2026/04/2026-04-02.md
   → 투자일기 기록

2. [finance/procedures] finance/procedures/anti-fomo.md (신규 — 제안)
   → "FOMO 추격매수 패턴 3회 반복. 원칙: 신규 종목 첫 매수는 목표의 30% 이내"
   → 근거: 3/15, 3/22, 4/02 diary

(y/n/번호선택) — 1만 선택하면 일기만 기록됩니다.
---

## 승인 입력

- y/ㅇ/응 → 전체 승인
- n/ㄴ/아니 → 전부 거부
- 1,3 → 해당 번호만 승인
- 그 외 텍스트 → 수정 요청

5개 이상 항목은 요약 모드 (d로 상세 전환).

### 제안 블록 항목 간 의존성

- 의존 관계가 있는 항목은 묶어서 표시한다 (예: `1+2: IREN 디렉토리 생성 + analysis.md`)
- 의존 항목은 개별 거부 불가 — 묶음 단위로 y/n
- diary(1번)를 거부하고 knowledge(2번, `derived_from` diary)만 승인하는 경우: `derived_from` 링크를 제거하고 저장
- 다중 파일 생성 시 `_index.yaml` 갱신은 승인에 자동 포함된다 (번호로 별도 표시하지 않음)

## 다중 도메인 동시 기록

- **blocking 질문 우선**: 금융 거래 가격 확인 등 MUST 4/5 질문은 제안 블록 생성 전에 먼저 해결한다
- **제안 블록 항목 상한**: 5개 초과 시 도메인별로 분리 제안한다 ("finance 먼저 처리할까요?")
- **MUST 5 보존**: 금융 거래 제안은 SHOULD 소멸 규칙의 예외이다. 다른 주제로 넘어가도 1회 리마인드 후 소멸
- **부분 완료**: 사용자가 번호 선택으로 일부만 승인 시, 미승인 항목 중 MUST 5 대상은 다음 턴에 리마인드

## smart 모드 자동 저장 범위

- 자동: diary 원문 추가, work/·life/ 기존 파일에 항목 append, finance/knowledge/stocks/ opinion_log append (conviction 미변경 시), catalysts/tags 수정
- 승인 필요: holdings/transactions 변경, conviction/thesis 변경, 새 파일 생성, finance/budget·accounts·transactions 변경, procedures 원칙 변경
- fallback: 명시되지 않은 경우 → 기존 파일 수정/추가는 자동, 새 파일 생성은 승인, finance/ 금액/수량 변경은 항상 승인
- diary 디렉토리 내 날짜 기반 신규 파일 생성은 자동 대상 예외 (별도 승인 불필요)

## 자동 저장 알림

`✓ 일상일기 + 삼성전자 실적 메모 저장됨 · /undo`
파일 경로 대신 사람이 이해하는 내용 요약. 중립적 톤.

## 운영 규칙

### _index.yaml 동기화 (MUST 7 v10)

파일 변경 시, 해당 파일이 속한 **직계 부모** `_index.yaml`을 반드시 업데이트한다. 상위 계층의 `_index.yaml`은 gist가 변경되는 경우에만 갱신. **연쇄 갱신 최대 깊이: 3단계.**

예: `IREN/analysis.md` 갱신 시 → `IREN/_index.yaml` 필수 갱신. `stocks/_index.yaml`은 IREN gist가 변하지 않으면 갱신 불필요.

### registry incremental 갱신

파일 생성/수정 후 `_meta/registry.yaml`에 해당 파일의 태그와 링크를 incremental append한다.
- `tag_index`: 파일의 tags를 태그별 파일 목록에 추가
- `reverse_links`: 파일의 outgoing links를 대상 파일의 역방향 링크에 추가

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
| watching | 관심 종목, 분석 전 (기본값) | "관심 가는데", "한번 봐볼까" |
| high | 적극 매수/보유 | "확실해", "베팅할 만해" |
| medium | 관망/유지 | "괜찮은 것 같아" |
| low | 불안/매도 고려 | "불안해", "빠져야 하나" |
| none | 관심 없음 | "모르겠어" |

사용자가 conviction을 명시하지 않으면 `watching`을 기본값으로 적용한다.
투자 종목 gist에는 반드시 conviction을 포함한다. 포맷: `"{thesis 한줄}. conviction {level}."`

### 자산 클래스 확장

finance/knowledge/ 하위에 stocks/ 외에 crypto/, etf/ 등 새 자산 클래스 디렉토리를 필요 시 생성.
- 새 자산 클래스는 저장 제안 블록에 통합하여 별도 확인 없이 처리:
  ```
  1. [finance/knowledge] finance/knowledge/crypto/BTC.yaml (신규 파일 + crypto/ 디렉토리 생성)
     → BTC 0.1개 @ 500만원 매수 기록
  ```
  디렉토리 생성은 저장 승인에 포함된 부수 동작 (별도 승인 불필요)
- 각 자산 클래스에 동일한 knowledge/_index.yaml 항목 + 개별 파일 구조 적용

### git commit 메시지

- 수동 승인: `memory: [요약]` (예: `memory: TSLA 10주 매수 + FSD 투자의견`)
- 자동 저장: `memory(auto): [요약]` (예: `memory(auto): 일상일기 + 삼성전자 실적 메모`)
- 정리: `memory(tidy): [요약]` (예: `memory(tidy): life/ 하위 건강 기록 분리`)

### consolidation-log 기록

공고화 제안이 승인되면 `_meta/consolidation-log.yaml`에 기록한다.

```yaml
entries:
  - date: "2026-03-15"
    source: finance/diary/2026/03/2026-03-15.md
    extracted_to:
      - finance/knowledge/stocks/IREN/analysis.md
      - finance/knowledge/stocks/IREN/overview.yaml
```

패턴이 감지되면 `detected_patterns`에 추가/갱신한다.
