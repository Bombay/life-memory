---
description: "기억을 검색합니다"
argument-hint: "<검색할 내용>"
allowed-tools: [Read, Glob, Grep, Edit]
---

사용자가 다음을 검색합니다: $ARGUMENTS

## 동작
1. $ARGUMENTS에서 검색 키워드/시간범위/종목명/주제 파싱
2. Phase 1: 검색 경로 결정
3. Phase 2-3: 점진적 깊이 인출
4. Phase 4: last_accessed 갱신

## Phase 1: 검색 경로 결정

- 종목명/인물명 → `knowledge/stocks/_index.yaml` 확인 (v10)
  - 없으면 → `_meta/compat.yaml`의 `legacy_paths` 확인 → v9 경로 silent redirect
  - v9 fallback: `investing/_index.yaml` 또는 대분류 `_index.yaml`
- 시간 범위("2월에", "지난주") → `diary/` 검색 (life/diary/ + finance/diary/) + opinion_log 날짜 필터
  - archive_years 확인 → 필요 시 archive/ 파일도 검색
- 주제 키워드 → `registry.yaml` 태그 검색 + `_index.yaml` 체인 + Glob/Grep fallback
  - finance/transactions/는 "거래", "지출", "얼마" 등 재무 키워드 시에만 포함
- "투자일기" 명시 → finance/diary/만 검색
- "일상일기" 명시 → life/diary/만 검색
- "일기" (단독) → life/diary/ + finance/diary/ 양쪽 검색
- "내 손절 기준" 등 내 규칙/기준 질문 → `procedures/` 우선 검색
- AI 인프라 등 태그 기반 교차 도메인 → registry.yaml 태그 검색 우선

## Phase 2: Tier 기반 점진적 인출

검색 경로 결정 후 아래 순서로 인출한다:

**Tier 1 (기본):** 매칭 파일의 `_index.yaml` gist만 로드 (최소 토큰)
- 단순 종목명/인물명 조회 → Tier 1 응답 + "상세 정보 있음" 안내

**Tier 2/3 (자동 심화):** 구체적 질문이면 즉시 심화 로드
- `/recall IREN Sweetwater` → 자동으로 `analysis.md` 탐색 (Tier 3)
- 구체적 수치/사건/분석 요청 → Tier 2 파일 (summary.md) → Tier 3 파일 (analysis.md) 순

```
/recall IREN              → Tier 1 gist 응답 + "상세 정보 있음" 안내
/recall IREN Sweetwater   → 자동 Tier 3 analysis.md 탐색
/recall 내 손절 기준       → procedures/ 우선 검색
/recall AI 인프라 관련     → 태그 기반 교차 도메인 검색
```

## Phase 3: 6단계 그레이스풀 디그레이드

검색 실패 시 아래 순서로 탐색 범위를 확장한다:

```
1. knowledge/ 검색
2. 못 찾으면 → procedures/ 검색
3. 못 찾으면 → diary/ 키워드 검색
4. diary에서 찾으면 → 결과 표시 + "knowledge로 정리할까요?" 제안 (📋 블록)
5. 못 찾으면 → archive/ 검색 (아카이브된 파일도 탐색)
6. 전부 못 찾으면 → "기억이 없습니다" + _meta/retrieval-failures.yaml 기록
```

**Step 4 diary 발견 시 출력 예시:**
```
📋 정리 제안: 이 내용이 일기에서만 발견되었습니다. knowledge/로 정리해둘까요?
```

**Step 6 retrieval-failures.yaml 기록:**
- query: 검색어
- result: "not_found"
- diagnosis: 추정 원인 (파일 미생성, 태그 누락 등)
- timestamp: 현재 날짜

## Phase 4: last_accessed 갱신

Phase 3에서 실제로 읽은 파일의 frontmatter `last_accessed`를 현재 날짜로 갱신한다.
Edit 툴을 사용해 해당 파일의 `last_accessed:` 값을 업데이트한다.

## contradicts 관계 표시

응답 구성 시 links에서 `contradicts` 관계가 발견되면 아래 형식으로 표시:

```
주의: 상충하는 정보가 있습니다.
- [bull] "..."
- [bear] "..."
```

## 검색 결과 출처 표시

- 일기 출처: `[일상일기]` / `[투자일기]`
- knowledge 출처: `[knowledge]`
- procedures 출처: `[procedures]`
- archive 출처: `[archive]`

## 월간 지출 쿼리

"이번 달 얼마 썼어?" 등 월간 지출 질문 → 두 수치를 모두 계산하여 함께 표시:
- 생활비: finance/transactions/ 합산
- 투자 포함: + finance/investing/ transactions 합산
- 예: "이번 달 지출: 생활비 150만원 / 투자 포함 650만원"

## 빈 결과

6단계 디그레이드를 모두 거친 후 최종 실패 시:
"[키워드]에 대한 기억이 없습니다."
