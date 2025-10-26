# Vibe Coding 스펙 (풀스택 작업 순서)

## 스택
- Frontend: Flutter 3.29 (Provider, GoRouter) + **CKEditor 5 Classic**
- Backend: Node.js 22 (Express + Sequelize), Multer 업로드
- DB: MySQL 8
- Auth: JWT + OAuth (Google, Naver, Kakao)
- Deploy: Docker Compose + Traefik (SSL)

##요구사항
1. `overview.md`, `features_spec.md`, `db_schema.md`를 기준으로 프로젝트 스캐폴딩 생성
2. 멀티게시판이니 만큼 관리자페이지에서 게시판종류를 추가하면 자동으로 코드에 반영됨

### 1) 백엔드 (Node + Sequelize)
1. 마이그레이션/모델 생성: users/boards/posts/comments/files + 보강 컬럼(score, view_count 등)
2. 시드: news/lab/free 3개 보드
3. 라우트:
   - Boards: GET `/api/boards`, POST/PUT/DELETE `/api/boards/:id`
   - Posts: GET `/api/boards/:slug/posts`, POST 동일, GET/PUT/DELETE `/api/posts/:id`
   - Comments: POST `/api/posts/:id/comments`
4. 정책:
   - 상세 GET 시 `view_count` 증가(30분 중복 방지 캐싱)
   - 글 작성 성공 시 `users.score += 10`, 댓글 작성 성공 시 `+= 1` (트랜잭션)
5. 응답 규약: 생성/수정 시 **전체 객체 반환**(낙관적 UI 보정용)

### 2) 프론트 (Flutter)
1 CKEditor 5를 WebView/HtmlElementView로 임베드 (웹/모바일 지원)
2. Provider 설계
   - `BoardsProvider`: `/api/boards` 로딩/캐시
   - `PostsProvider`: 목록/상세 + **create/update 낙관적 업데이트 + SWR**
   - `MeProvider`: 로그인 사용자, **score** 관리(낙관 반영 + SWR)
3. 라우팅(GoRouter)
   - `'/b/:slug'` 목록, `'/p/:id'` 상세, `'/post/new'` 작성/수정
4. 작성/수정 플로우
   - 저장 누르는 즉시 Provider 목록에 **임시 항목 삽입 또는 패치**
   - 서버 응답 수신 후 temp 교체 → SWR로 서버 정합 반영
5. 조회수/점수 UI
   - 목록/상세에 👁 `view_count` 뱃지
   - 헤더/프로필에 `score` 노출, 작성/댓글 성공 직후 낙관적 +10/+1


## 산출물 구조(예시)
```
/community-board-ckeditor
 ├─ backend/
 │   ├─ server.js
 │   ├─ routes/
 │   ├─ models/
 │   └─ config/
 ├─ frontend/
 │   ├─ lib/
 │   ├─ web/               # Flutter Web에서 CKEditor 5 리소스 로딩 시 사용 가능
 │   ├─ pubspec.yaml
 │   └─ main.dart
 ├─ docker-compose.yml
 ├─ traefik/
 │   └─ dynamic_config.yml
 └─ docs/
     ├─ overview.md
     ├─ features_spec.md
     ├─ db_schema.md
     └─ vibe_coding_spec.md
```
