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
- .sync-conflict 존재 시:
  1. 충돌 파일 목록 표시 + 각 파일의 로컬/원격 diff 분석
  2. 에이전트가 각 파일별 판단 제안: "로컬이 최신 데이터입니다. 로컬을 유지할까요?" 또는 "원격에 더 완전한 기록이 있습니다. 원격을 유지할까요?"
  3. 사용자 승인 → 선택된 버전 적용 + .sync-conflict 삭제 + git add + git commit + git push
  4. 결과 보고
- 정상 시: git pull --rebase + git push + 결과 보고

## /memory status
- 대분류별 하위 구조 요약 (_index.yaml 기반)
- 마지막 동기화 시각
- 미커밋 변경 여부 — 미커밋 변경 발견 시 "커밋할까요?" 능동 제안
- 최근 저장 5건 (git log --oneline -5 --grep="memory")

## /memory setup
- 초기 설정 + 설정 변경 통합
- 분기 조건: `.memory-config.yaml`이 존재하고 `repository.name`이 비어있지 않으면 → 기존 설정. 그 외 → 초기 설정.

### 초기 설정
  1. setup.sh 실행 (디렉토리 + config + git init)
     - setup.sh 실행 불가 시 (Windows 네이티브 등 bash 없는 환경): 에이전트가 동일 로직을 Write/Bash 도구로 직접 실행 (mkdir, git init -b main, 파일 생성)
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

### 기존 설정 (이미 setup 완료 시)
  - `.memory-config.yaml`의 repository 섹션 읽기 → 연결 정보 표시
  - 현재 상태 요약:
    - 디렉토리 ✓/✗ (경로)
    - git ✓/✗
    - GitHub 레포 ✓/✗ ({owner}/{name} — {url})
    - 환경변수 ✓/✗ (LIFE_MEMORY_PATH={경로})
  - 변경 원하는 항목이 있으면 해당 단계만 재실행

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
