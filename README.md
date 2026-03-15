# life-memory

개인 장기 기억 관리 Claude Code 플러그인. 일기, 투자, 재무, 커리어, 생활 정보를 private GitHub repo에 저장하고 검색합니다.

## 설치

```bash
# 1. 마켓플레이스 등록
/plugin marketplace add Bombay/life-memory

# 2. 플러그인 설치
/plugin install life-memory@life-memory-marketplace

# 3. 메모리 저장소 초기 설정
/memory setup
```

`/memory setup`이 GitHub private repo 생성, 환경변수 설정까지 안내합니다.

## 사용법

| 커맨드 | 설명 | 예시 |
|--------|------|------|
| `/remember` | 기억 저장 | `/remember 테슬라 10주 250달러에 샀어` |
| `/recall` | 기억 검색 | `/recall 테슬라`, `/recall 지난주 일기` |
| `/forget` | 기억 삭제 | `/forget 테슬라` |
| `/memory` | 시스템 관리 | `/memory sync`, `/memory status`, `/memory tidy` |
| `/undo` | 되돌리기 | `/undo`, `/undo 3` |

커맨드 없이 대화해도 자동으로 기억 저장을 제안합니다.

## 데이터 구조

```
~/.life-memory/
├── finance/    재무 (투자, 예산, 거래, 투자일기)
├── work/       커리어
├── life/       개인 생활 (일상일기)
└── archive/    오래된 로그
```

- 대분류는 고정, 하위 폴더는 에이전트가 자율 관리
- 모든 데이터는 git으로 버전 관리, 세션 종료 시 자동 push
