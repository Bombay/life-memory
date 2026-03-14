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
