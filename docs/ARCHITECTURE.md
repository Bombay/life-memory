# Life Memory v10 Architecture

> v9의 "요약 전용" 한계를 극복하는 뇌과학 기반 기억 시스템 재설계.
> 핵심: 3-Tier 인코딩 + 기억 유형 분리 + 연상 네트워크 + 공고화 + 메타인지.
> 작성일: 2026-03-15

---

## 설계 동기

### v9의 4가지 문제

1. **요약 전용 한계** — 모든 파일이 요약 중심으로 설계되어 상세 분석 데이터(시설별 MW, 계약 상세, 재무 모델) 저장 불가.
2. **파일 간 연결 없음** — "AI 인프라 관련 모든 것"처럼 주제 횡단 검색 불가.
3. **패턴 추출 프로세스 없음** — 에피소드(일기)에서 의미 기억·절차 기억으로 정제하는 경로 부재.
4. **인출 실패 = 데드엔드** — 검색 실패 시 "기억이 없습니다"로 종료, 개선 피드백 없음.

### 접근

인간 뇌의 기억 시스템을 파일 기반 메모리에 매핑한다. 에피소드 기억·의미 기억·절차 기억을 디렉토리 구조로 분리하고, 해마→신피질 공고화 과정을 자동 제안 메커니즘으로 구현한다.

---

## 뇌과학 원리 매핑 테이블

| 뇌과학 원리 | 뇌에서의 역할 | 파일 시스템 매핑 |
|---|---|---|
| **에피소드 기억** (해마) | "언제, 어디서, 무엇을" 경험 기록 | `*/diary/*.md` |
| **의미 기억** (측두엽 신피질) | 맥락 분리된 사실/지식 | `*/knowledge/**` |
| **절차 기억** (기저핵/소뇌) | "어떻게" — 방법론, 원칙 | `*/procedures/*.md` |
| **인코딩 깊이** (Craik & Lockhart) | 깊을수록 강한 기억 흔적 | 3-Tier: gist → elaborated → source |
| **청킹** (Miller) | 관련 정보를 하나의 단위로 묶음 | `_index.yaml`이 하위 파일을 청크로 대표 |
| **연상 네트워크** (Collins & Loftus) | 확산 활성화 — 연관 기억 인출 | `links:` 메타데이터 + 태그 인덱스 |
| **공고화** (해마→신피질) | 에피소드가 의미 기억으로 전환 | 자동 감지 + 제안 블록 통합 |
| **메타인지** (전전두엽) | "내가 뭘 아는지 아는 것" | `_meta/` 디렉토리 |
| **적응적 망각** (Anderson & Bjork) | 인출 경쟁 감소, 관련성 향상 | `last_accessed:` 기반 아카이빙 |

---

## 디렉토리 구조

```
~/.life-memory/
├── _meta/                              # 메타인지 (전전두엽)
│   ├── registry.yaml                   # 태그 인덱스 + 역방향 링크 맵
│   ├── consolidation-log.yaml          # 공고화 실행 이력
│   ├── retrieval-failures.yaml         # 인출 실패 기록
│   └── health-report.yaml             # 구조 건강도
│
├── finance/
│   ├── diary/                          # 에피소드 기억 (v9 호환)
│   │   └── 2026/03/2026-03-15.md
│   │
│   ├── knowledge/                      # 의미 기억 (NEW)
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
│   ├── procedures/                     # 절차 기억 (NEW)
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
│   │   └── skills/
│   └── procedures/
│
├── life/
│   ├── diary/
│   ├── knowledge/
│   │   ├── _index.yaml
│   │   ├── people/
│   │   ├── health/
│   │   └── interests/
│   └── procedures/
│
└── archive/                            # v9 호환 (망각 목적지)
    ├── finance/
    ├── work/
    └── life/
```

### v9 vs v10 구조 변경 요약

| v9 | v10 | 변화 |
|---|---|---|
| `investing/` | `knowledge/stocks/` | 경로 변경 + 상위 knowledge/ 계층 추가 |
| 단일 YAML만 | YAML + .md + 디렉토리 승격 | 3-Tier 인코딩 |
| 없음 | `knowledge/sectors/`, `concepts/` | 의미 기억 확장 |
| 없음 | `procedures/` | 절차 기억 신설 |
| 없음 | `_meta/` | 메타인지 신설 |
| diary/, transactions/, budget/, archive/ | 그대로 유지 | 100% 호환 |

---

## 3-Tier 인코딩

Craik & Lockhart의 처리 수준 이론을 파일 구조에 반영한다.

### Tier 1: Gist (얕은 인코딩)

`_index.yaml`의 한 줄 요약. `/recall`의 1차 응답. 최소 토큰 소비. **gist는 50자 이내 1문장 권장.**

**conviction 레벨 (투자 종목 필수):**

```
watching — 관심 종목, 아직 분석 전 (기본값: 사용자가 미명시 시)
low     — 분석했으나 확신 낮음
medium  — 투자 고려 중
high    — 강한 확신, 보유 중이거나 매수 의향
```

투자 종목의 gist에는 반드시 conviction을 포함한다. 포맷: `"{thesis 한줄}. conviction {level}."` conviction이 변경되면 gist도 반드시 갱신한다.

### Tier 2: Elaborated (정교화 인코딩)

`overview.yaml` — v9 종목 스키마 수준 + `links:`, `sources:`, `relevance:`, `last_accessed:` 확장. 기존 파일을 열지 않고도 핵심 정보를 파악할 수 있는 수준으로 작성한다.

### Tier 3: Source (깊은 인코딩)

`.md` 파일 — 상세 데이터, 테이블, 출처, 근거. 필요할 때만 로드. 첫 조회 시 Tier 2 응답 후 "상세 정보 있음" 안내.

### 디렉토리 승격 4가지 조건

단일 `.yaml` 파일이 아래 조건 중 하나를 충족하면 디렉토리 승격을 제안한다.

```
1. 파일 200줄 초과
2. 독립적 하위 주제 3개 이상
3. 상세 분석 요청 2회 이상
4. opinion_log 10건 + Tier 3 데이터 존재
```

승격 패턴: `IREN.yaml` → `IREN/` (`_index.yaml` + `overview.yaml` + `analysis.md`). 에이전트가 제안하고 사용자가 승인해야 실행. 단일 git commit으로 수행하며 `/undo`로 전체 되돌리기 가능.

---

## 연상 네트워크

### 4가지 관계 유형

| 관계 | 의미 | 예시 |
|---|---|---|
| `related` | 동등 수준 연관 (양방향) | IREN ↔ NVDA |
| `derived_from` | 이 지식의 출처 | analysis.md → diary/2026-03-15.md |
| `depends_on` | 이해에 필요한 선행 지식 | IREN → PPA 계약 개념 |
| `contradicts` | 상충하는 정보 — 파일 간에만 적용 (양방향) | 분석A.md ↔ 분석B.md |

모든 YAML/MD 파일의 frontmatter에 선택적 `links:` 필드로 outgoing link를 관리한다.

### 역방향 인덱스 (registry 중앙 관리)

개별 파일은 outgoing link만 관리한다. 역방향 인덱스는 `_meta/registry.yaml`에서 중앙 관리한다. `/remember`로 파일 생성/수정 시 incremental 갱신, `/memory health` 시 전체 재구축.

```yaml
# _meta/registry.yaml 구조
reverse_links:
  finance/knowledge/sectors/ai-infrastructure.md:
    - path: finance/knowledge/stocks/IREN/overview.yaml
      relation: related
tag_index:
  ai-infra:
    - finance/knowledge/stocks/IREN/_index.yaml
    - finance/knowledge/sectors/ai-infrastructure.md
```

이렇게 하면 파일 편집 시 한 곳만 수정하고, 역방향 탐색은 registry 조회, 동기화 실패 위험이 최소화된다.

### 태그 정규화

태그는 항상 **kebab-case 영문 소문자**로 저장한다 (예: "AI 인프라" → `ai-infra`). 한국어 태그는 에이전트가 자동 변환. 태그 기반 검색으로 도메인(finance/work/life)을 가로지르는 연상 인출을 지원한다.

---

## 지식 정리 (Knowledge Consolidation)

뇌의 시스템 공고화(해마 → 신피질)를 모방한다. 에피소드(diary)에서 패턴을 추출하여 knowledge와 procedures로 정제한다.

**핵심 원칙: 에이전트가 자동 감지하고 제안한다. 사용자가 별도 커맨드를 지시하지 않는다.** 기존 커맨드(`/remember`, `/recall`) 실행 중 자동으로 판단하여 제안 블록에 포함한다.

### 자동 감지 트리거 4가지

| 사용자 행동 | 에이전트 감지 | 제안 |
|---|---|---|
| 일기 쓰기 (`/remember 투자일기...`) | 언급된 주제의 knowledge 파일 확인 + 관련 diary 건수 확인 | "분석 파일도 업데이트할까요?" |
| 새 정보 기록 (`기억해줘...`) | 기존 knowledge와 충돌/보강 여부 판단 | "기존 분석에 이 정보를 반영할까요?" |
| 검색 실패 (`/recall`) | 인출 실패인데 diary에 관련 내용 존재 | "diary에서 찾았습니다. 정리해둘까요?" |
| 건강도 점검 (`/memory health`) | 전체 스캔으로 정리 후보 탐색 | "정리 후보 N건 발견" 리포트 |

### 추출 기준 요약

**knowledge로 추출:**
- 새로운 수치/데이터 (매출, MW, 가격 등) — 1회 등장이면 충분
- 확인된 인과 관계 ("A 때문에 B가 됐다") — 추측은 미추출
- 새로운 인물/기관 정보 — 1회 등장이면 충분

**procedures로 추출:**
- 동일 패턴 3회 이상 반복 (예: "FOMO 매수 → 후회" 3회)
- 명시적 원칙 선언 ("다시는 이렇게 안 하겠다") — 1회라도 명시적이면 추출
- 체크리스트, 프레임워크 — 1회 등장이면 충분

**diary에만 유지 (추출 안 함):**
- 그날의 감정, 일시적 시장 반응, 맥락 없는 단편 메모, 추측성 인과

**"에이전트가 제안, 사용자가 승인" 원칙:** 모든 추출 제안은 기존 📋 저장 제안 블록에 번호 항목으로 통합된다. 사용자는 번호 선택으로 원하는 것만 승인하면 된다.

---

## 메타인지 시스템

### `_meta/` 4개 파일

- `registry.yaml` — 태그 인덱스 + 역방향 링크 맵. 전체 기억의 지도.
- `consolidation-log.yaml` — 공고화 실행 이력. diary에서 knowledge로 추출된 내역 추적.
- `retrieval-failures.yaml` — 인출 실패 기록. 실패 3건+ 누적 시 패턴 분석 + 구조 개선 제안.
- `health-report.yaml` — `/memory health` 커맨드로 생성되는 구조 건강도 리포트.

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

---

## 아카이빙 정책

v9의 건수 기반 아카이빙을 **접근 빈도 + 중요도 기반**으로 개편한다 (knowledge/procedures 파일에만 적용).

### 아카이브 후보 3가지 조건 (모두 충족 시)

```
조건 1: last_accessed가 6개월 이상 전
AND
조건 2: importance가 "high"가 아님
AND
조건 3: 다른 파일에서 링크되지 않음 (registry 역방향 링크 0건)
```

### last_accessed / importance

- `last_accessed` — `/recall` 시 자동 갱신. 단독 git commit 안 함. `on-stop.sh`에서 세션 종료 시 포함.
- `importance` — 기본값: `medium`. 자동 설정: `holdings.quantity > 0` 또는 conviction `high` → `high`.

기존 opinion_log 10건, transactions 30건 건수 기반 아카이빙은 v9과 동일하게 유지. diary는 불변(MUST 2), 아카이빙 대상 아님.

---

## 커맨드 동작 요약

### /remember
3-Tier 인코딩에 따라 대분류(finance/work/life) → 기억 유형(diary/knowledge/procedures) → Tier(gist/elaborated/source) 순으로 저장 위치를 결정한다. 저장 제안 블록에 지식 정리(공고화) 제안을 자동으로 포함한다.

### /recall
점진적 깊이 인출(Progressive Depth Retrieval)을 적용한다. Tier 1 gist 응답 후 구체적 질문이면 자동으로 Tier 2/3 심화. 6단계 그레이스풀 디그레이드:

```
1. knowledge/ 검색
2. 못 찾으면 → procedures/ 검색
3. 못 찾으면 → diary/ 키워드 검색
4. diary에서 찾으면 → 결과 표시 + "knowledge로 정리할까요?" 제안
5. 못 찾으면 → archive/ 검색
6. 전부 못 찾으면 → "기억이 없습니다" + retrieval-failures.yaml 기록
```

### /forget
cascade delete + dangling link 정리 + 기본 동작은 archive/ 이동 (완전 삭제는 사용자 명시 시에만). 삭제 전 git commit 스냅샷 필수.

### /memory health
구조 건강도 점검 (고아 파일, 오래된 gist, 디렉토리 승격 후보, 아카이브 후보, 누락 역방향 링크) + 정리 제안. `health-report.yaml`로 저장.

### /undo
되돌리기 시 `_meta/registry.yaml` 갱신을 함께 수행한다 (v9 대비 추가). diary 파일은 자동 제외.

---

## MUST 규칙 (1-10)

1. **제안-승인** — 메모리 기록/정리 전 반드시 사용자 승인 (smart 모드 자동 범위 제외).
2. **불변 파일 보존** — `**/diary/**` 경로 파일 및 `immutable: true` 항목은 절대 수정/삭제/이동 금지.
3. **세션 초기화** — 첫 접근 시 `.sync-conflict` 확인 → 정상이면 git pull --rebase.
4. **과장·모호 표현 확인** — finance/ 수량/가격 변경 시 "다 팔았어", "올인" 등 모호 표현 반드시 확인.
5. **금융 거래 감지 시 저장 제안** — 코딩 중이라도 금융 거래 감지 시 1줄 알림 제안.
6. **금융 데이터 충돌 상세 확인** — finance/ 데이터가 기존 값과 다를 때 수량/가격/날짜 상세 확인.
7. **_index.yaml 동기화** — 파일 변경 시 직계 부모 `_index.yaml` 필수 갱신. 상위 계층은 gist 변경 시에만 갱신 (최대 3단계).
8. **정리 시 정보 유실 금지** — 정리 실행 전 git commit 스냅샷. diary 파일은 어떤 정리 작업도 금지.
9. **3-Tier 일관성** — 디렉토리 승격된 항목은 반드시 `_index.yaml`(Tier 1) + `overview.yaml`(Tier 2) 보유. Tier 3(.md)는 선택.
10. **공고화 시 diary 원본 완전 보존** — diary 내용을 knowledge로 추출할 때 diary 파일은 일체 수정 금지. 추적은 `_meta/consolidation-log.yaml`에만 기록.

> 상세 동작 규칙은 `skills/life-memory/SKILL.md` 참조.

---

## v9 호환

### legacy_paths 매핑

```yaml
# _meta/compat.yaml
version: 10
legacy_paths:
  "finance/investing/stocks/": "finance/knowledge/stocks/"
  "finance/investing/sectors/": "finance/knowledge/sectors/"
```

v9 경로로 접근 시 v10 경로로 자동 리다이렉트.

### lazy migration 전략

빅뱅 전환 없이 접근 시점에 점진적으로 마이그레이션한다.

- **Phase 0 (즉시)** — `/memory setup` 또는 첫 `/remember` 시: `_meta/` 디렉토리 생성, `knowledge/` + `procedures/` 디렉토리 생성, `finance/investing/stocks/` → `finance/knowledge/stocks/` 이동 (git mv), `.memory-config.yaml` version 2 → 10 갱신.
- **Phase 1 (점진)** — 새 파일은 `knowledge/` 경로에 생성. 기존 `investing/` 파일은 접근 시 자동 인식.
- **Phase 2 (주기)** — `/memory health` 실행 시 diary에서 knowledge/procedures 추출 후보 리포트. `registry.yaml` 재구축.

---

## v10 이후 로드맵

검증 과정에서 확인된, v10에서 의도적으로 제외하는 기능:

| 기능 | 뇌과학 원리 | 제외 이유 | 시기 |
|---|---|---|---|
| 간격 반복 (`review_interval`) | Ebbinghaus 망각 곡선 | 복잡도 대비 ROI 불확실 | v11 |
| 스키마 (`_schema.yaml`) | Bartlett 스키마 이론 | 멘탈 모델 표현이 불명확 | v11 |
| 작업 기억 (`working-set`) | Baddeley 작업 기억 | 세션 간 상태 관리 난이도 | v11 |
| 연결 강도 (`link strength`) | Hebb 학습 규칙 | 관리 복잡도 과중 | v11 |
