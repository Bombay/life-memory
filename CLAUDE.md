# Life Memory Plugin

개인 장기 기억 관리 시스템. Claude Code 플러그인.

## 아키텍처
- 상세 설계: docs/ARCHITECTURE.md
- 핵심: 대분류 고정(finance/work/life/archive) + 하위 자율 구조
- 데이터 저장소: ~/.life-memory/ (git repo)

## 커맨드
/remember, /recall, /forget, /memory, /undo

## MUST (절대 규칙)
1. 제안-승인 — 메모리 기록/정리 전 반드시 사용자 승인
2. 불변 파일 보존 — **/diary/** 및 immutable:true 파일은 수정/삭제/이동 금지
3. 세션 초기화 — 첫 메모리 접근 시 충돌 체크 + git pull
4. 과장·모호 표현 확인 — finance/ 수량/가격 변경 시 재확인
5. 금융 거래 감지 시 저장 제안 — 코딩 중이라도 1줄 알림
6. 금융 데이터 충돌 시 상세 확인 — 기존 값과 다를 때 수량/가격/날짜 확인
7. _index.yaml 동기화 필수 — 파일 생성/삭제/이동 시 인덱스 업데이트
8. 정리 시 정보 유실 금지 — diary는 어떤 작업도 금지, 나머지는 승인 후 허용

## 개발 규칙
- 아키텍처 변경 시 docs/ARCHITECTURE.md 먼저 업데이트
- 플러그인 버전: 2.0.0
