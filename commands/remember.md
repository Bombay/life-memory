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
- 새 자산 클래스는 저장 제안 블록에 통합하여 별도 확인 없이 처리:
  ```
  1. [finance] finance/investing/crypto/BTC.yaml (신규 파일 + crypto/ 디렉토리 생성)
     → BTC 0.1개 @ 500만원 매수 기록
  ```
  디렉토리 생성은 저장 승인에 포함된 부수 동작 (별도 승인 불필요)
- 각 자산 클래스에 동일한 investing/_index.yaml 항목 + 개별 파일 구조 적용
- setup.sh에서는 stocks/만 초기 생성

### git commit 메시지
- 수동 승인: `memory: [요약]` (예: `memory: TSLA 10주 매수 + FSD 투자의견`)
- 자동 저장: `memory(auto): [요약]` (예: `memory(auto): 일상일기 + 삼성전자 실적 메모`)
- 정리: `memory(tidy): [요약]` (예: `memory(tidy): life/ 하위 건강 기록 분리`)
