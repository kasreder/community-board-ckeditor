# 기능 정의서 (Features Spec) — CKEditor 5 버전

## 1. 회원 / 인증
- 회원가입, 로그인, 로그아웃
- 소셜 로그인(Google, Naver, Kakao)
- JWT 기반 토큰 인증
- 프로필 편집(닉네임, 아바타 이미지)

---

## 2. 메인 페이지 (`/home`)
- 최신 게시글 요약 (공지, 자유, 기술 등)
- 인기 게시글 TOP 5
- 검색창(제목, 내용, 작성자 검색)

---

## 3. 게시판 목록 페이지 (`/board/:boardName`)
- 게시글 목록 조회 (무한스크롤 or 페이지네이션)
- 정렬: 최신순 / 인기순 / 댓글많은순
- 게시글 작성 버튼 (로그인 사용자만)

---

## 4. 게시글 상세 페이지 (`/post/:id`)
- 제목, 내용(HTML 렌더링), 작성자, 작성일 표시
- 첨부 이미지 또는 파일 미리보기
- 댓글 목록 / 댓글 입력
- 좋아요 / 신고 기능
- 작성자 본인일 경우 수정/삭제 버튼 표시

---

## 5. 게시글 작성/수정 (`/post/new`, `/post/:id/edit`)
- **CKEditor 5 Classic Editor** 사용 (Flutter에서는 WebView/HtmlElementView로 임베드)
- 저장 포맷: **HTML** (Delta 사용 안 함)
- 플러그인: Essentials, Paragraph, Heading, Bold, Italic, Underline, Strikethrough, Link, List, BlockQuote, Alignment, CodeBlock, Table, TableToolbar, Image, ImageToolbar, **ImageUpload**, **ImageResize**, MediaEmbed, PasteFromOffice
- 툴바(예시):
  - `['heading','|','bold','italic','underline','link','bulletedList','numberedList','blockQuote','|','insertTable','mediaEmbed','codeBlock','|','undo','redo','|','imageUpload','imageStyle:inline','imageStyle:block','imageStyle:side','|','alignment:left','alignment:center','alignment:right']`
- **이미지 업로드**:
  - 엔드포인트: `POST /api/files/upload` (Multer)
  - 응답(JSON): `{ "url": "https://.../uploads/{filename}" }`
  - CKEditor 설정: `simpleUpload: { uploadUrl: '/api/files/upload', withCredentials: true, headers: { Authorization: 'Bearer <JWT>' } }`
- **이미지 크기 조절(ImageResize)**: 드래그 핸들 제공, `maxWidth`는 에디터 컨테이너 폭 기준
- **자동 임시저장**(선택): 10초 주기 로컬 저장, 새 글 작성 재방문 시 복원 옵션
- XSS 방지: 서버 저장 전 허용 태그/속성 화이트리스트 필터링(서버단 sanitize 옵션)

---

## 6. 관리자 페이지 (`/admin`)
- 사용자 관리 (권한 변경, 계정 정지)
- 게시글/댓글 관리 (삭제, 신고처리)
- 통계 대시보드 (게시글 수, 활성유저 등)

---

## 7. 공통 기능
- 반응형 UI (모바일/PC 대응)
- 다크모드 지원
- 로딩/에러 처리
- 다국어 지원 (ko/en)

---

## 8. Flutter에서 CKEditor 5 임베드 가이드 (핵심)
- **웹(Flutter Web)**: `HtmlElementView` + 플랫폼 뷰 레지스트리로 CKEditor 5 DOM 마운트
- **모바일(Android/iOS)**: `flutter_inappwebview` 또는 `webview_flutter` 사용
- 에디터 ↔ Flutter 통신:
  - 에디터 → Flutter: `window.flutter_inappwebview.callHandler('onChange', html)`
  - Flutter → 에디터: `controller.evaluateJavascript(source: 'editor.setData(`<기존HTML>`);')`
- 저장: Flutter에서 HTML을 받아 API `POST /api/posts`의 `content` 필드로 전달
