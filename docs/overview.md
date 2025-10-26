# 게시판 커뮤니티 서비스 (Community Board Service)

## 1. 목적
사용자들이 다양한 주제로 소통할 수 있는 커뮤니티 플랫폼을 제공합니다.  
공지, 자유게시판, 기술게시판, 사진게시판 등 여러 카테고리를 지원하며,  
**문서 작성기는 Flutter 전용이 아닌 CKEditor 5(이미지 업로드, 크기조절 가능) 단일 버전**으로 사용합니다.

## 2. 주요 목표
- 다중 게시판(공지, 자유, 사진 등) 관리
- 로그인 및 소셜 인증 지원
- 게시글/댓글 CRUD
- 좋아요, 신고 기능
- **CKEditor 5 기반 글쓰기(이미지 업로드/리사이즈 지원, HTML 저장)**
- 관리자 페이지를 통한 사용자 및 게시글 관리
- 모바일/웹 반응형 UI

## 3. 기술 스택
| 구분 | 기술 |
|------|------|
| 프론트엔드 | Flutter 3.29 (Provider + GoRouter), **CKEditor 5 (Classic)** |
| 백엔드 | Node.js 22 (Express + Sequelize) |
| 데이터베이스 | MySQL 8 |
| 배포 | Docker Compose + Traefik (SSL) |
| 인증 | JWT + OAuth (Google, Naver, Kakao) |
| 파일저장 | Local / AWS S3 (Multer 업로드 엔드포인트) |

## 4. 대상 사용자
- 일반 사용자: 게시글 및 댓글 작성, 프로필 관리
- 관리자: 회원, 게시글, 신고 관리

## 5. 환경
- 웹: 데스크탑/모바일 브라우저 대응
- 앱: Flutter 기반 Android / iOS (WebView로 CKEditor 5 사용)
