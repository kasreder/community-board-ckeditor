# Vibe Coding Fullstack Spec for Community Board — CKEditor 5

## 목적
게시판 커뮤니티 서비스를 Flutter + Node.js + MySQL로 구현하며, **문서 작성기는 CKEditor 5 단일 버전**을 사용한다.

## 스택
- Frontend: Flutter 3.29 (Provider, GoRouter) + **CKEditor 5 Classic**
- Backend: Node.js 22 (Express + Sequelize), Multer 업로드
- DB: MySQL 8
- Auth: JWT + OAuth (Google, Naver, Kakao)
- Deploy: Docker Compose + Traefik (SSL)

## 요구사항
1. `overview.md`, `features_spec.md`, `db_schema.md`를 기준으로 프로젝트 스캐폴딩 생성
2. 프론트엔드
   - CKEditor 5를 WebView/HtmlElementView로 임베드 (웹/모바일 지원)
   - 에디터 설정:
     - 플러그인: Essentials, Paragraph, Heading, Bold, Italic, Underline, Strikethrough, Link, List, BlockQuote, Alignment, CodeBlock, Table, TableToolbar, Image, ImageToolbar, **ImageUpload**, **ImageResize**, MediaEmbed, PasteFromOffice
     - 툴바 구성은 features_spec 참고
     - `simpleUpload.uploadUrl = '/api/files/upload'` + JWT 헤더 사용
   - 저장 포맷: **HTML 문자열** (Delta 금지)
   - 에디터 ↔ Flutter 브릿지: onChange로 HTML 반환, setData로 초기값 주입
3. 백엔드
   - REST API: `/api/auth`, `/api/posts`, `/api/comments`, `/api/files`, `/api/boards`, `/api/admin/*`
   - 파일 업로드: `POST /api/files/upload` (Multer) → `{ url }` 반환
   - 보안: HTML sanitize, 파일 확장자/용량 제한, JWT 인증 미들웨어
4. Docker Compose
   - backend, frontend, db, traefik 포함
   - SSL 자동 발급 및 reverse proxy 설정
5. 마이그레이션/시드
   - boards 기본 시드: notice, free, tech, photo
   - 관리자 계정 1개, 일반 계정 3개
6. 테스트
   - 게시글 작성/수정/삭제, 이미지 업로드/리사이즈, 댓글 작성, 권한 체크 E2E

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
