# 개요 (멀티 게시판 프로젝트)

## 목표
- 하나의 코드베이스로 **여러 게시판을 동적 운용**한다.
- 초기 게시판: 뉴스(`news`), 실험(`lab`), 자유(`free`)
- **관리자에서 게시판 생성/수정/삭제** → 프런트 메뉴/라우팅 **자동 반영**
- 에디터는 **CKEditor5** 단일 버전 사용(이미지 업로드/크기조정/표/코드블록 지원)
- 사용자 활동에 **유저 점수** 반영(글 +10, 댓글 +1), 글은 **조회수** 집계

## 핵심 기능
- 동적 네비게이션: `/api/boards` 결과로 메뉴/라우팅 구성
- 게시판 타입별 렌더링: 뉴스는 카드형(썸네일/발행일/고정글)
- 낙관적 UI(Optimistic): 작성/수정 즉시 목록 반영, SWR로 보정
- 조회수: 상세 진입 시 서버 증가(세션/IP 30분 캐싱 권장)
- 점수: 글 작성 +10, 댓글 작성 +1(삭제 회수는 선택)

## Homepage & Navigation (추가 규격)

### Homepage
- **목표**: 홈에서 각 게시판의 **최신글 5개**를 한 눈에 제공합니다.
- **데이터 소스**: `GET /api/boards`로 활성 보드 목록을 조회 후,
  각 보드에 대해 `GET /api/boards/:slug/posts?limit=5` 요청.
- **UI**: 보드별 섹션(Card/Grid). 섹션 상단에 보드명과 `더보기` → `/b/:slug` 링크.
- **성능**: 최초 진입 시 캐시된 결과 먼저 표시, 비동기 최신화로 보정(SWR).
- **수용 기준**: 보드가 N개면 N개의 섹션이 노출되고, 각 섹션에는 **최대 5개**의 글이 표시됨.

### Responsive Navigation
- **브레이크포인트**: 가로폭 **640px 이하**에서는 하단 **NavigationBar(NavigationDestination)**,
  **640px 초과**에서는 좌측 **NavigationRail(NavigationRailDestination)** 사용.
- **일관성**: 양쪽 컴포넌트의 목적지는 동일하게 유지(홈/게시판/프로필 등).
- **접근성**: 각 Destination에 `tooltip/semanticLabel` 제공.


## 기술 스택
| 구분 | 기술 |
|------|------|
| 프론트엔드 | Flutter 3.29 (Provider + GoRouter), **CKEditor 5 (Classic)** |
| 백엔드 | Node.js 22 (Express + Sequelize) |
| 데이터베이스 | MySQL 8 |
| 배포 | Docker Compose + Traefik (SSL) |
| 인증 | JWT + OAuth (Google, Naver, Kakao) |
| 파일저장 | Local / AWS S3 (Multer 업로드 엔드포인트) |

## 동작 흐름(관리자 → 사용자)
1) 관리자에서 게시판 생성(예: 과학뉴스 `slug=science-news`)
2) 서버 저장 및 캐시 무효화
3) 사용자는 다음 로드에서 `/api/boards`로 신규 게시판 수신
4) 메뉴/라우팅 자동 반영 → `/b/science-news` 접근 가능

## 대상 사용자
- 일반 사용자: 게시글 및 댓글 작성, 프로필 관리
- 관리자: 회원, 게시글, 신고 관리
- 관라자등급: 마스터, 대관리자, 소관리자 

## 환경
- 웹: 데스크탑/모바일 브라우저 대응
- 앱: Flutter 기반 Android / iOS (WebView로 CKEditor 5 사용)
