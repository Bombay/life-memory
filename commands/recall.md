---
description: "기억을 검색합니다"
argument-hint: "<검색할 내용>"
allowed-tools: [Read, Glob, Grep]
---

사용자가 다음을 검색합니다: $ARGUMENTS

## 동작
1. $ARGUMENTS에서 검색 키워드/시간범위/종목명 파싱
2. 검색 실행 → 결과 정리

## 검색 전략
- 종목/인물명 → investing/_index.yaml 또는 대분류 _index.yaml 확인 → 해당 파일 직접 읽기
  - opinion_archive_years/transaction_archive_years 확인 → 과거 데이터 요청 시 archive/ 포함
- 시간 범위("2월에", "지난주") → diary 파일 검색 (life/diary/ + finance/diary/) + opinion_log 날짜 필터
  - archive_years 확인 → 필요 시 archive/ 파일도 검색
- "투자일기" 명시 → finance/diary/만 검색
- "일상일기" 명시 → life/diary/만 검색
- "일기" (단독) → life/diary/ + finance/diary/ 양쪽 검색
- 검색 결과에 출처 표시: `[일상일기]` / `[투자일기]`
- 주제 키워드 → 대분류 _index.yaml 우선 확인 → 관련 파일 검색
  - finance/transactions/는 "거래", "지출", "얼마" 등 재무 키워드 시에만 포함
- 월간 지출 ("이번 달 얼마 썼어?") → finance/transactions/ 합산. 투자 거래 포함 여부는 사용자에게 확인.

## 빈 결과
"[키워드]에 대한 기억이 없습니다."
