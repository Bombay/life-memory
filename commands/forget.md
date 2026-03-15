---
description: "기억을 삭제합니다"
argument-hint: "<삭제할 내용>"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

사용자가 삭제를 요청합니다: $ARGUMENTS

## 기본 동작

**기본 = archive/ 이동.** 완전 삭제는 사용자가 "완전히 지워줘"라고 명시할 때만 수행한다.

1. $ARGUMENTS로 삭제 대상 검색
2. 영향 범위 제안 (파일 목록 + dangling link 대상) → 승인
3. **삭제 전 git commit 스냅샷** (`/undo` 복구 가능하도록)
4. 연쇄 삭제 실행 + git commit

## 삭제 범위

- work/, life/ 파일: 삭제 가능 (일반 확인)
- finance/ 파일: 삭제 가능 (항상 상세 확인)
- **/diary/: 원문 보존 → 삭제하지 않음. "diary는 불변 기록이라 /forget 대상이 아닙니다"라고 안내 (MUST)

## 연쇄 삭제 프로토콜

### 단일 파일 삭제
1. 파일 → `archive/`로 이동 (또는 완전 삭제)
2. 부모 `_index.yaml`에서 해당 항목 제거
3. `_meta/registry.yaml`에서 해당 파일의 태그/링크 항목 제거

### 디렉토리 삭제
1. 하위 파일 전체 → `archive/`로 이동 (또는 완전 삭제)
2. 상위 `_index.yaml`에서 해당 디렉토리 항목 제거
3. `_meta/registry.yaml`에서 관련 태그/링크 항목 제거

### dangling link 처리
삭제 후 깨진 링크가 생기는 파일을 정리한다:
- `_meta/registry.yaml`의 `reverse_links`에서 삭제 대상 경로를 참조하는 파일 목록 추출
- 목록이 있으면 사용자에게 표시: "이 파일들의 링크도 정리할까요?"
- 승인 시: 해당 파일들의 `links:`에서 삭제된 경로 제거

## 통합 파일 부분 삭제

종목 파일(finance/knowledge/stocks/*.yaml 또는 디렉토리)은 분석+보유가 통합되어 있으므로:
- 단순 삭제 요청("지워줘") → 기본적으로 전부 삭제(archive 이동) 제안
- "분석 지워줘/초기화" → thesis/conviction/catalysts 초기화 (conviction: "none", thesis: null, catalysts: {bull: [], bear: []}), holdings/transactions 유지
- "보유 정보 지워줘" → holdings 초기화 (quantity: 0, avg_price: 0), transactions 유지, 분석 데이터 유지
- "전부 지워줘" → 파일 삭제 + _index.yaml 동기화
- 3가지 옵션을 매번 제시하지 않음. 사용자 발화에 "분석" 또는 "보유"가 명시된 경우에만 부분 삭제.

## 안전장치

- **삭제 전 git commit 스냅샷 필수** — 메시지: `snapshot: before /forget <대상>` (`/undo`로 복구 가능)
- **기본 동작: archive/ 이동** — 완전 삭제는 "완전히 지워줘" 명시 시에만
- **diary 불변** — diary 파일은 /forget 대상이 아님을 안내 (MUST)

## 대상 없음

"[키워드]에 대한 기억이 없어 삭제할 항목이 없습니다."

## 동기화

모든 관련 파일 변경(archive 이동, _index.yaml, registry.yaml, dangling link 정리)을 하나의 git commit으로 묶음.
