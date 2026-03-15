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
