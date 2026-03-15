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
| `/memory health` | 구조 건강도 점검 + 정리 제안 | `/memory health` |
| `/undo` | 되돌리기 | `/undo`, `/undo 3` |

커맨드 없이 대화해도 자동으로 기억 저장을 제안합니다.

## 데이터 구조

```
~/.life-memory/
├── diary/          에피소드 기억 (일기, 이벤트) — 불변
├── knowledge/      의미 기억 (학습, 개념, 인물)
│   └── stocks/     주식/투자 지식
├── procedures/     절차 기억 (방법, 루틴, 워크플로)
├── finance/        재무 (거래, 예산)
├── work/           커리어
├── life/           개인 생활
├── _meta/          구조 건강도 모니터링
└── archive/        오래된 로그
```

- 대분류는 고정, 하위 폴더는 에이전트가 자율 관리
- 모든 데이터는 git으로 버전 관리, 세션 종료 시 자동 push
- 디렉토리 승격된 knowledge 항목은 `_index.yaml` + `overview.yaml` 필수

## v10 주요 변경사항

- **3-Tier 인코딩**: gist(_index.yaml) → elaborated(.yaml) → source(.md) 단계별 저장
- **기억 유형 분리**: diary(에피소드) + knowledge(의미) + procedures(절차)
- **연상 네트워크**: 파일 간 links + 태그 인덱스로 교차 검색
- **자동 공고화**: /remember, /recall 중 에이전트가 지식 정리를 자동 제안
- **메타인지**: _meta/ 디렉토리로 구조 건강도 모니터링
- **`/memory health`**: 고아 파일, 아카이브 후보, 승격 후보 점검
- **경로 변경**: investing/ → knowledge/stocks/ (자동 마이그레이션 지원)
