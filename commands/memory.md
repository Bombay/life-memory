---
description: "메모리 시스템을 관리합니다"
argument-hint: "<sync|status|setup|health|rebuild|tidy|help>"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

서브커맨드: $ARGUMENTS

## /memory (인자 없음) 또는 /memory help

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

## /memory sync
- .sync-conflict 존재 시:
  1. 충돌 파일 목록 표시 + 각 파일의 로컬/원격 diff 분석
  2. 에이전트가 각 파일별 판단 제안: "로컬이 최신 데이터입니다. 로컬을 유지할까요?" 또는 "원격에 더 완전한 기록이 있습니다. 원격을 유지할까요?"
  3. 사용자 승인 → 선택된 버전 적용 + .sync-conflict 삭제 + git add + git commit + git push
  4. 결과 보고
- 정상 시: git pull --rebase + git push + 결과 보고

## /memory status
- 대분류별 하위 구조 요약 (_index.yaml 기반, knowledge/ + procedures/ 포함)
- 마지막 동기화 시각
- 미커밋 변경 여부 — 미커밋 변경 발견 시 "커밋할까요?" 능동 제안
- 최근 저장 5건 (git log --oneline -5 --grep="memory")

## /memory setup
- 초기 설정 + 설정 변경 통합
- 분기 조건: `.memory-config.yaml`이 존재하고 `repository.name`이 비어있지 않으면 → 기존 설정. 그 외 → 초기 설정.

### 초기 설정 (신규 설치 또는 v9 미존재)
  1. setup.sh 실행 (v10 디렉토리 구조 + config + git init)
     - v10 디렉토리: `_meta/`, `*/knowledge/`, `*/procedures/` 포함
     - setup.sh 실행 불가 시 (Windows 네이티브 등 bash 없는 환경): 에이전트가 동일 로직을 Write/Bash 도구로 직접 실행 (mkdir, git init -b main, 파일 생성)
     - setup.sh 완료 후 Phase 0 자동 수행:
       - `_meta/registry.yaml` 초기 파일 생성 (`tag_index: {}`, `reverse_links: {}`, `last_rebuilt: null`)
       - `_meta/retrieval-failures.yaml` 초기 파일 생성
       - `_meta/consolidation-log.yaml` 초기 파일 생성
       - `.memory-config.yaml`에 `version: 10` 기록
  2. remote 미설정 시:
     - `gh auth status`로 gh 설치/인증 상태 사전 확인
     - gh 미설치 시: OS 감지 후 패키지 매니저 폴백 체인으로 직접 설치:
       - macOS: `brew install gh` → brew 없으면 gh 릴리즈 직접 다운로드 안내
       - Linux: `/etc/os-release` 파싱 → apt/dnf/pacman 등 배포판별 설치
       - Windows: `winget install GitHub.cli` → winget 없으면 `choco install gh` → `scoop install gh` → MSI 다운로드 안내
     - gh 미인증 시: "gh 인증이 필요합니다. 터미널에서 `gh auth login`을 실행해주세요. (Login with a web browser 선택이 가장 간단합니다)" 안내 → 사용자가 '완료'라고 입력하면 재시도
     - `.memory-config.yaml`에 `repository.name`이 비어있지 않은 값으로 있으면 해당 이름 사용
     - 없거나 비어있으면 사용자에게 질문: "기억 저장소로 사용할 GitHub repo 이름을 입력해주세요 (기본: life-vault):"
     - `gh repo view {입력값} --json name,description,sshUrl,isPrivate`로 존재 확인
       - 존재 → "{owner}/{name} — {description}. 이 레포를 사용할까요?" 확인 → 승인 시 `git remote add origin <sshUrl>` → `git fetch origin` → 원격 커밋 존재 여부 확인:
         - **원격에 기존 데이터가 있을 때** (새 기기에서 기존 레포 연결 등):
           1. "원격에 기존 데이터가 있습니다. 어떻게 할까요?"
           2. 선택지 제시:
              - **"원격 데이터로 교체"** (권장) → `git fetch origin` + `git reset --hard origin/main` — setup.sh의 초기 커밋을 원격 데이터로 대체
              - **"로컬 유지, 원격에 덮어쓰기"** → `git push -u origin main --force` — 원격의 기존 데이터를 로컬 초기 상태로 교체 (데이터 유실 경고)
              - **"취소"** → `git remote remove origin` — remote 연결 해제, 수동 설정 안내
           3. "원격 데이터로 교체" 후 `.memory-config.yaml`이 원격 것으로 교체된 경우, `repository.local_path`를 현재 경로로 업데이트
         - 원격이 비어있으면 → `git push -u origin main`
       - 미존재 → "GitHub private repo '{입력값}'을 생성할까요?" 확인 → 승인 시 `gh repo create {입력값} --private --source=. --push` 실행
     - 연결 완료 후 `.memory-config.yaml`에 repository 섹션 기록:
       ```yaml
       repository:
         name: "{repo-name}"
         url: "{remote-url}"
         owner: "{github-username}"
         local_path: "{MEMORY_PATH}"
       ```
  3. 환경변수 `LIFE_MEMORY_PATH` 미설정 시:
     - "LIFE_MEMORY_PATH 환경변수를 설정할까요?" 확인
     - 승인 → `$SHELL` 환경변수로 셸 감지 후 적절한 설정 파일에 추가:
       - zsh → `~/.zshrc`
       - bash → `~/.bashrc`
       - 기타 → `~/.profile`
       - Windows (PowerShell) → `[Environment]::SetEnvironmentVariable(...)` + 현재 세션에도 `$env:LIFE_MEMORY_PATH = ...` 즉시 적용
     - "현재 세션에 적용하려면 셸을 재시작하거나 설정 파일을 다시 로드해주세요." 안내

### 기존 설정 — v9 감지 시 업그레이드 제안
  - `.memory-config.yaml`의 `version`이 9 이하이거나 `_meta/` 디렉토리가 없으면 v9로 판단
  - "v10으로 업그레이드할까요? (knowledge/, procedures/, _meta/ 구조가 추가됩니다)" 제안
  - 승인 시 마이그레이션 실행:
    1. `_meta/` 디렉토리 생성 + 초기 파일 생성 (`registry.yaml`, `retrieval-failures.yaml`, `consolidation-log.yaml`)
    2. `*/knowledge/`, `*/procedures/` 디렉토리 생성
    3. `finance/investing/stocks/` → `finance/knowledge/stocks/` (git mv)
    4. `finance/investing/sectors/` → `finance/knowledge/sectors/` (git mv)
    5. 빈 `finance/investing/` 삭제
    6. 대분류 `_index.yaml`을 v10 스키마로 갱신 (knowledge/, procedures/ 카테고리 추가)
    7. `.memory-config.yaml`의 `version` → `10` 갱신
    8. `_meta/compat.yaml` 생성 (v9 경로 역방향 호환용):
       ```yaml
       version: 10
       legacy_paths:
         "finance/investing/stocks/": "finance/knowledge/stocks/"
       ```
  - 거부 시: 기존 v9 구조 유지, 언제든 다시 실행 가능 안내

### 기존 설정 (v10 이미 설치 완료 시)
  - `.memory-config.yaml`의 repository 섹션 읽기 → 연결 정보 표시
  - 현재 상태 요약:
    - 디렉토리 ✓/✗ (경로)
    - git ✓/✗
    - GitHub 레포 ✓/✗ ({owner}/{name} — {url})
    - 환경변수 ✓/✗ (LIFE_MEMORY_PATH={경로})
    - v10 구조 ✓/✗ (_meta/, knowledge/, procedures/)
  - 변경 원하는 항목이 있으면 해당 단계만 재실행

## /memory health
구조 건강도 점검 + 정리 제안을 실행한다.

1. 전체 파일 스캔 (Glob + registry.yaml 참조)
2. 다음 항목 점검:

   **고아 파일 탐색** (§7.3)
   - registry.yaml의 reverse_links에서 링크 0건인 파일 목록

   **오래된 gist 탐색** (§7.3)
   - knowledge/procedures 파일 중 `last_updated` 또는 git 마지막 수정일이 30일+ 경과한 것

   **디렉토리 승격 후보** (§7.3)
   - 단일 yaml 파일인데 3개 이상의 하위 항목이 있는 knowledge 파일
   - 상세 분석(.md)이 누락된 중요도 high 항목
   - links가 3개 이상인 단일 파일 (연관 정보가 많아 디렉토리로 분리 유리)
   - opinion_log 5건 이상 누적된 종목 파일

   **아카이브 후보** (§8.2)
   - 조건 1: `last_accessed`가 6개월 이상 전
   - AND 조건 2: `importance`가 "high"가 아님 (또는 미설정 = medium)
   - AND 조건 3: registry reverse_links 0건

   **누락된 역방향 링크** (§7.3)
   - 파일에 `links:` 항목이 있으나 registry.yaml에 역방향 링크가 없는 경우

   **미반영 diary 항목** (§6.1)
   - consolidation-log.yaml에 기록되지 않은 diary 파일 중 knowledge 파일과 동일 주제 언급이 3건 이상인 것
   - ("diary는 있으나 knowledge로 정리되지 않은 항목")

3. 결과를 리포트 형식으로 출력:
   ```
   📊 메모리 구조 건강도 리포트

   고아 파일: N건
   오래된 gist (30일+): N건
   디렉토리 승격 후보: N건
   아카이브 후보: N건
   누락된 역방향 링크: N건
   미반영 diary 항목: N건

   [상세 목록 및 개선 제안]
   ```
4. 결과를 `_meta/health-report.yaml`에 저장 (날짜 + 항목별 파일 목록)
5. 개선 사항이 있으면 "지금 정리할까요?" → 승인 시 /memory tidy 방식으로 제안-승인 사이클 진행

## /memory rebuild [디렉토리]
- 지정 디렉토리의 _index.yaml을 실제 파일/폴더 기준으로 재생성
- 인자 없으면 전체 재생성 (knowledge/, procedures/ 경로 포함)
- 전체 재생성 시 `_meta/registry.yaml`도 재구축:
  - 모든 파일의 `tags:` 메타데이터 스캔 → `tag_index` 재구성
  - 모든 파일의 `links:` 메타데이터 스캔 → `reverse_links` 재구성
  - `last_rebuilt` 현재 시각으로 갱신
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
