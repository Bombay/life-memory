---
description: "메모리 변경을 되돌립니다"
argument-hint: "[번호|--more|--since 날짜]"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

옵션: $ARGUMENTS

## 동작
1. 최근 memory 커밋 목록 표시 (기본 10건, memory: 또는 memory(auto): 또는 memory(tidy): 또는 memory(v10-migration): 접두사)
2. 되돌릴 커밋 선택 (기본: 가장 최근)
3. 변경 파일 목록 + 미리보기 → 승인
4. 승인 → 되돌리기 + _index.yaml 동기화 + `_meta/registry.yaml` 갱신 + git commit

## registry 갱신 (v10)
revert 완료 후 `_meta/registry.yaml`도 반드시 갱신한다:
- 되돌린 파일의 태그/링크를 `_meta/registry.yaml`에서 제거
- 복원된 파일의 태그/링크를 `_meta/registry.yaml`에 재추가

## 디렉토리 승격 되돌리기
디렉토리 승격은 단일 git commit으로 수행되므로, `/undo`로 승격 전체를 원자적으로 되돌릴 수 있다. 특별 처리 불필요 — 기존 git revert 로직으로 자연스럽게 지원된다.

## 옵션
- /undo → 최근 10건 표시
- /undo --more → 최근 30건 표시
- /undo --since 3d → 3일 이내 커밋만 표시
- /undo 3 → 목록의 3번 커밋 되돌리기

## 연쇄 /undo
revert 커밋은 건너뛰고 다음 memory 커밋을 대상으로 함.

## 부분 되돌리기
변경 파일 번호 표시 → "2번만 되돌려줘" 가능.
git revert --no-commit 후 원하는 파일만 복원 → 새 커밋.

## diary 보호 (MUST 2 준수)
**/diary/ 파일이 포함된 커밋을 되돌릴 때, diary 파일은 자동 제외.
- revert 대상에 diary 파일이 포함되면: "diary 파일은 원본 보존 규칙에 따라 제외됩니다." 안내
- git revert --no-commit → diary 파일 checkout으로 원복 → 나머지만 커밋
- diary 파일만 포함된 커밋은 되돌리기 불가 안내
