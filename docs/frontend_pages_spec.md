# Frontend Pages Spec (Flutter + Provider + GoRouter)

> 본 문서는 **페이지별 기능 정의**와 라우팅/상태/이벤트 흐름을 상세히 규정합니다.  
> 기존 `features_spec.md`의 프론트 관련 섹션을 구체화/세분화한 문서이며, 우선 적용 기준입니다.

## 0) 공통 아키텍처
- 라우팅: GoRouter
- 상태: Provider (BoardsProvider, PostsProvider, MeProvider, CommentsProvider, AuthProvider)
- 네트워킹: Dio (services/api.dart)
- 모델: models/(Board, Post, Comment, User)
- 위젯: widgets/ (PostCard, PostList, EditorToolbar 등)
- 에디터: CKEditor5(WebView/iframe 임베디드) + 업로드 엔드포인트 연동
- 낙관적 UI: 작성/수정/댓글 작성 시 선반영 → 서버 응답/재검증(SWR)로 보정
- 접근성: 모든 주요 버튼에 semanticLabel, 키보드 포커스, 스크린리더 라벨

### 디렉터리 구조 제안
```
lib/
  main.dart
  router.dart
  models/
    board.dart
    post.dart
    comment.dart
    user.dart
  providers/
    boards_provider.dart
    posts_provider.dart
    comments_provider.dart
    me_provider.dart
    auth_provider.dart
  pages/
    home/
      home_page.dart
    board/
      board_list_page.dart
    post/
      post_detail_page.dart
      post_editor_page.dart
    admin/
      admin_boards_page.dart
      admin_posts_page.dart
    auth/
      sign_in_page.dart
      sign_up_page.dart
    profile/
      profile_page.dart
    search/
      search_page.dart
    notifications/
      notifications_page.dart
  widgets/
    app_scaffold.dart
    post_card.dart
    post_list.dart
    error_view.dart
    empty_view.dart
  services/
    api.dart         // Dio 클라이언트 + API 래퍼
    ckeditor_bridge.dart // 에디터와 데이터 동기 모듈
```

### 라우트 테이블
| 경로 | 페이지 | 설명 |
|---|---|---|
| `/` | HomePage | 초기/대시보드 |
| `/b/:slug` | BoardListPage | 게시판 목록(뉴스/실험/자유/커스텀) |
| `/p/:id` | PostDetailPage | 게시글 상세(조회수 증가) |
| `/post/new?slug=:slug` | PostEditorPage | 새 글 작성 |
| `/post/edit/:id` | PostEditorPage | 글 수정 |
| `/admin/boards` | AdminBoardsPage | 게시판 관리(추가/수정/삭제) |
| `/admin/posts` | AdminPostsPage | 게시글 관리(필터/일괄 처리) |
| `/auth/sign-in` | SignInPage | 로그인 |
| `/auth/sign-up` | SignUpPage | 회원가입 |
| `/me` | ProfilePage | 내 정보/점수 |
| `/search` | SearchPage | 통합 검색 |
| `/notifications` | NotificationsPage | 알림 |

---

## 1) AppScaffold (공용 레이아웃)
**목표**: 공통 헤더/내비/푸터 및 보드 동적 메뉴 반영

- **UI 요소**: 앱바(검색 버튼, 알림, 프로필), 사이드 내비(BoardsProvider 기반), 컨텐츠 슬롯
- **상태/데이터**: `BoardsProvider.load()` 결과 기반으로 메뉴 구성
- **상호작용**: 보드 클릭 → `/b/:slug` 이동
- **에러/로딩**: 보드 목록 로딩 스피너, 에러 시 재시도 버튼
- **반응형**: 사이드바(>1024px) / 바텀 내비(<1024px)

---

## 2) HomePage
**목표**: 진입 페이지. 최근 글/고정글/뉴스 카드 섹션

- **데이터**: 인기 글 Top N, 각 보드 최신 5건 (캐시 허용)
- **상호작용**: 카드 클릭→ 상세, 보드 섹션 더보기→ 해당 보드 목록
- **API**: `/api/boards` + `/api/boards/:slug/posts?limit=5`
- **수용 기준**: 1초 내 초기 렌더(캐시 사용), 네트워크 후 보정

---

## 3) BoardListPage (`/b/:slug`)
**목표**: 특정 보드의 목록 + 고정글 상단 + 정렬/필터 + 페이지네이션

- **UI**: 
  - 헤더: 보드명/설명/글쓰기 버튼
  - 툴바: 정렬(최신/인기/댓글순), 검색(제목/본문/태그), 태그 필터
  - 목록: **PostCard**(뉴스: 썸네일 카드 / 일반: 리스트형)
- **상태/데이터**:
  - `PostsProvider.list(slug)`
  - 첫 진입 시 `PostsProvider.load(slug)` (캐시 있으면 즉시 표시)
- **상호작용**:
  - 글쓰기 → `/post/new?slug=:slug`
  - 카드 클릭 → `/p/:id`
- **Optimistic**:
  - 작성 성공/수정 성공 시 **즉시 목록 반영**(이미 구현된 Provider 메서드 사용)
- **API**: `GET /api/boards/:slug/posts`
- **수용 기준**: 
  - 고정글은 항상 최상단, 동일 정렬 기준 유지
  - 로딩/빈 상태/에러 처리 명확

---

## 4) PostDetailPage (`/p/:id`)
**목표**: 본문, 메타(작성자/발행일/조회수), 태그, 첨부, 댓글

- **UI**: 제목, 메타(👁 view_count 포함), 본문 렌더(HTML), 태그, 첨부파일 리스트
- **댓글 섹션**: 입력창(로그인 필요), 댓글 리스트(최신순/추천순 토글)
- **상태/데이터**: `PostsProvider.fetchById(id)` + `CommentsProvider.load(id)`
- **조회수 증가**: 진입 시 `GET /api/posts/:id` 호출 → 서버가 `view_count` 증가 후 최신값 반환
- **상호작용**:
  - 수정 버튼(권한 시) → `/post/edit/:id`
  - 댓글 작성 → 낙관적 추가 **즉시 리스트 반영** → 서버 응답으로 보정, MeProvider.score +1 낙관 반영
- **API**: `GET /api/posts/:id`, `GET/POST /api/posts/:id/comments`
- **수용 기준**: 새로고침 없이 view_count 갱신된 값 표시

---

## 5) PostEditorPage (`/post/new`, `/post/edit/:id`)
**목표**: CKEditor5로 글 작성/수정 (이미지 업로드, 예약 발행, 고정글)

- **UI**: 제목 입력, 에디터(본문), 썸네일(뉴스형), 고정글, 상태, 예약 발행, 태그
- **상태/데이터**: 
  - 작성: `boardSlug`가 URL 파라미터로 전달
  - 수정: 기존 포스트 로드 후 입력 값 채우기
- **저장 흐름(작성)**:
  1) 저장 클릭 → `PostsProvider.create(slug, ...)` 호출
  2) **낙관적**: temp post를 목록에 삽입
  3) 서버 응답 수신 → temp 교체, `MeProvider.score += 10` 낙관 반영
  4) SWR 재검증
- **저장 흐름(수정)**: 목록 내 항목 패치 → 응답으로 확정 → SWR 보정
- **API**: `POST /api/boards/:slug/posts`, `PUT /api/posts/:id`
- **수용 기준**: 저장 후 목록에서 즉시 반영, 뒤로가기 시 새로고침 불필요

---

## 6) AdminBoardsPage (`/admin/boards`)
**목표**: 게시판 CRUD 및 설정

- **UI**: 목록(검색/정렬), 생성/수정 다이얼로그
- **필드**: name, slug(유니크), type, is_private, is_hidden, order_no, settings(JSON)
- **상호작용**: 저장 시 `/api/boards` 캐시 무효화 → AppScaffold 메뉴 자동 반영
- **API**: `GET/POST/PUT/DELETE /api/boards`
- **수용 기준**: 생성 즉시 사용자 메뉴에 노출(다음 라우트 재탐색 시)

---

## 7) AdminPostsPage (`/admin/posts`)
**목표**: 게시글 관리(보드/상태/기간/작성자 필터, 일괄 고정/해제/삭제)

- **UI**: 필터/검색, 테이블(체크박스 멀티 선택), 일괄 작업 버튼
- **API**: `GET /api/admin/posts`, `PUT /api/admin/posts/bulk`
- **수용 기준**: 일괄 작업 후 목록 재검증, 실패 항목 피드백

---

## 8) Auth (SignIn/SignUp)
**목표**: 인증/권한

- **SignIn**: 이메일/비밀번호, 소셜 로그인(선택)
- **SignUp**: 필수 정보, 약관 동의
- **상태**: `AuthProvider`가 토큰/세션 유지, `MeProvider`가 현재 사용자/점수 유지
- **수용 기준**: 로그인 후 이전 위치 복귀

---

## 9) ProfilePage (`/me`)
**목표**: 사용자 프로필/점수/활동 요약

- **UI**: 아바타/닉네임/이메일, 현재 **score**, 최근 글/댓글
- **API**: `GET /api/me`
- **상호작용**: 닉네임/아바타 수정(선택)

---

## 10) SearchPage (`/search`)
**목표**: 통합 검색(제목/본문/태그/작성자)

- **UI**: 검색 바, 결과 탭(글/댓글)
- **API**: `GET /api/search?q=...`

---

## 11) NotificationsPage (`/notifications`)
**목표**: 시스템/댓글/멘션 알림 목록

- **데이터**: 서버 푸시(WebSocket/SSE) 또는 폴링(초기 폴링 후 푸시 전환 권장)
- **상호작용**: 항목 클릭 → 해당 글/댓글 이동

---

## 12) 에러/로딩/빈 상태 표준
- 로딩 스피너: 주요 리스트/상세/저장 시 표시
- 에러 뷰: 사유 + 재시도 버튼
- 빈 상태: 가이드 메시지 + CTA(예: “첫 글을 작성해 보세요”)

---

## 13) 성능/접근성/국제화
- 이미지 lazy-load(뉴스 썸네일)
- 목록 가상화(대량 데이터 시)
- Semantics 라벨, 포커스 이동/단축키(에디터 툴바)
- 다국어 i18n(ko 기본, en 확장)

---

## 14) 수용 기준(샘플 E2E 시나리오)
1) **게시판 동적 생성 → 메뉴 자동 반영**
   - AdminBoardsPage에서 새 보드 생성 → 홈/사이드 메뉴에 표시됨
2) **작성/수정 즉시 반영**
   - BoardListPage에서 글 작성 → 저장 직후 목록 선두에서 보임(새로고침 불필요)
3) **조회수/점수**
   - PostDetailPage 진입 시 view_count 증가 표시
   - 글 작성 후 ProfilePage에서 score +10 반영(낙관→SWR 보정)
4) **댓글 작성**
   - 상세에서 댓글 작성 → 즉시 리스트 반영, 프로필 점수 +1

---

## 15) TODOs
- [ ] CKEditor5 업로드/이미지 리사이즈 핸들러 연결
- [ ] MeProvider/Dio 인터셉터(401 핸들링, 재시도)
- [ ] 알림 채널(WebSocket/SSE) 설계
- [ ] AdminPostsPage 일괄 작업 API 구체화
- [ ] 보드/글 권한 매트릭스(읽기/쓰기/관리) 세부화

---

## HomePage (추가 상세)
- **목표**: 보드별 최신글 **5개**를 한 화면에 제공
- **API**: 
  - `GET /api/boards` 로 보드 수집
  - 각 보드: `GET /api/boards/:slug/posts?limit=5`
- **UI/동작**: 보드 섹션 카드 + `더보기` → `/b/:slug`, 항목 탭 → `/p/:id`
- **성능/캐시**: 캐시 우선 렌더 + SWR로 최신화
- **수용 기준**: N개 보드 → N개 섹션, 각 섹션 **최대 5개** 항목

## Responsive Navigation (신규 섹션)
- **Breakpoint**: width **<= 640px** → Bottom **NavigationBar**(NavigationDestination)
- **Breakpoint**: width **> 640px** → Left **NavigationRail**(NavigationRailDestination)
- **일관성**: 목적지/상태 동기화, 동일한 접근성 라벨/툴팁 제공
- **전환 기준**: 런타임 레이아웃 계산(LayoutBuilder) 기반
