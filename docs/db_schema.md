# DB 스키마 정의 (Community Board Service — CKEditor 5)

## users
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | INTEGER | 사용자 PK |
| name | TEXT | 사용자 이름 |
| email | TEXT | 이메일 |
| password | TEXT | 암호화된 비밀번호 |
| avatar_url | TEXT | 프로필 이미지 경로 |
| role | ENUM('user','admin') | 사용자 권한 |
| created_at | DATETIME | 가입일 |
| updated_at | DATETIME | 수정일 |

---

## boards
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | INTEGER | 게시판 PK |
| name | TEXT | 게시판 이름 (예: notice, free, photo) |
| title | TEXT | 게시판 제목 (예: 공지사항, 자유게시판) |
| description | TEXT | 게시판 설명 |
| created_at | DATETIME | 생성일 |

---

## posts
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | INTEGER | 게시글 PK |
| board_id | INTEGER | 게시판 ID (FK: boards.id) |
| user_id | INTEGER | 작성자 ID (FK: users.id) |
| title | TEXT | 제목 |
| content | LONGTEXT | **HTML 본문 (CKEditor 5 저장 포맷)** |
| like_count | INTEGER | 좋아요 수 |
| view_count | INTEGER | 조회수 |
| created_at | DATETIME | 작성일 |
| updated_at | DATETIME | 수정일 |

---

## comments
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | INTEGER | 댓글 PK |
| post_id | INTEGER | 게시글 ID (FK: posts.id) |
| user_id | INTEGER | 작성자 ID (FK: users.id) |
| content | TEXT | **HTML 허용(짧은 포맷), 서버단 sanitize 필수** |
| created_at | DATETIME | 작성일 |

---

## files
| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | INTEGER | 파일 PK |
| post_id | INTEGER | 게시글 ID (FK: posts.id, NULL 허용 — 에디터 내 임시 업로드 지원) |
| file_url | TEXT | 파일 경로 |
| file_type | TEXT | MIME or 분류 (image/*, application/pdf 등) |
| size | INTEGER | 바이트 단위 파일 크기 |
| created_at | DATETIME | 업로드일 |

---

### 서버단 보안/무결성 참고
- HTML sanitize 화이트리스트: `a[href|target|rel]`, `img[src|alt|width|height|style]`, `p`, `h1-h6`, `ul/ol/li`, `strong/em/blockquote/code/pre`, `table/thead/tbody/tr/td/th`, `figure/figcaption`, `span[style]`
- 파일 업로드 제한: 확장자/용량(예: 5MB), 이미지 리사이즈(옵션), 썸네일 생성(옵션)
