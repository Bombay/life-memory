---
description: "기억을 삭제합니다"
argument-hint: "<삭제할 내용>"
allowed-tools: [Read, Write, Edit, Bash, Glob, Grep]
---

사용자가 삭제를 요청합니다: $ARGUMENTS

## 동작
1. $ARGUMENTS로 삭제 대상 검색
2. 영향 범위 제안 (제안-승인)
3. 승인 → 삭제/수정 + _index.yaml 동기화 + git commit

## 삭제 범위
- work/, life/ 파일: 삭제 가능 (일반 확인)
- finance/ 파일: 삭제 가능 (항상 상세 확인)
- **/diary/: 원문 보존 → 삭제하지 않음 (안내)

## 통합 파일 부분 삭제
종목 파일(finance/investing/stocks/*.yaml)은 분석+보유가 통합되어 있으므로:
- 단순 삭제 요청("지워줘") → 기본적으로 전부 삭제 제안
- "분석 지워줘/초기화" → thesis/conviction/catalysts 초기화 (conviction: "none", thesis: null, catalysts: {bull: [], bear: []}), holdings/transactions 유지
- "보유 정보 지워줘" → holdings 초기화 (quantity: 0, avg_price: 0), transactions 유지, 분석 데이터 유지
- "전부 지워줘" → 파일 삭제 + _index.yaml 동기화
- 3가지 옵션을 매번 제시하지 않음. 사용자 발화에 "분석" 또는 "보유"가 명시된 경우에만 부분 삭제.

## 대상 없음
"[키워드]에 대한 기억이 없어 삭제할 항목이 없습니다."

## 동기화
모든 관련 파일 변경을 하나의 git commit으로 묶음.
