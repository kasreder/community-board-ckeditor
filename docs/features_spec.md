# 기능 명세 (API/화면/정책)

## 1) API 요약
- Boards
  - `GET /api/boards` : 전체 보드 목록
  - `POST /api/boards`(admin) : 생성
  - `PUT /api/boards/:id`(admin) : 수정
  - `DELETE /api/boards/:id`(admin) : 삭제
- Posts
  - `GET /api/boards/:slug/posts` : 보드별 목록(페이지네이션, 고정글 우선, 뉴스 카드형 옵션)
  - `POST /api/boards/:slug/posts` : 생성(**응답: 전체 Post 객체**)
  - `GET /api/posts/:id` : 상세(**조회수 증가 처리**)
  - `PUT /api/posts/:id` : 수정(**응답: 전체 Post 객체**)
  - `DELETE /api/posts/:id` : 삭제
- Comments
  - `POST /api/posts/:id/comments` : 생성(**유저 점수 +1**)

## 2) 관리자 화면
- 게시판 관리: 목록/생성/수정/삭제, 옵션(type, is_private, is_hidden, order_no, settings JSON)
- 저장 시 `/api/boards` 캐시 무효화 → 프론트 자동 반영

## 3) 사용자 화면
- 동적 메뉴/라우팅: `/api/boards` 기반 사이드바/탭 구성
- 목록
  - 최신/인기/댓글순 정렬 + **is_pinned 우선**
  - 뉴스형: 썸네일, 발행일(published_at) 카드형
  - **👁 view_count** 뱃지 표시
- 상세
  - 본문 렌더, 태그, 썸네일, 발행정보, 조회수
- 작성/수정
  - CKEditor5(이미지 업로드/크기조정)
  - 상태(status), 예약발행(published_at), 고정글, 썸네일, 태그

## 4) 낙관적 UI & SWR
- 작성: temp post를 목록에 선삽입 → 서버 응답으로 교체 → SWR 재동기화
- 수정: 목록의 항목을 즉시 패치 → 응답으로 확정 → SWR 보정
- 실패 시 롤백

## 5) 조회수 & 유저 점수 정책
- 조회수(view_count)
  - 상세 조회 시 증가 (세션/IP 기준 30분 내 중복 제외 권장)
  - 비공개 게시판은 인증 사용자만 카운트
- 유저 점수(score)
  - 글 작성 성공 시 **+10점**
  - 댓글 작성 성공 시 **+1점**
  - 삭제 시 회수 여부는 운영 선택(기본: 회수 안 함)

## 6) 백엔드 구현 스니펫(요약)
- 마이그레이션: users.score, posts.view_count 추가
- 상세 GET: Redis 등으로 `pv:{session/ip}:{postId}` 키 30분 캐시 후 `increment('view_count')`
- 글/댓글 생성: DB 트랜잭션으로 `User.increment({ score: 10|1 })`

## 7) 보안/운영
- 봇/스크래퍼 차단(User-Agent/RateLimit)
- 작성 빈도 제한(분당/시간당)
- 권한: is_private 읽기 가드, 보드/글/댓글 수정 권한 확인
