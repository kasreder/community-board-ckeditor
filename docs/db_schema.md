# DB 스키마 (멀티 게시판 + 조회수/점수 반영)

## 1) 테이블 개요
- `users` : 사용자 계정 및 프로필, **score**(유저점수) 포함
- `boards` : 게시판 메타(동적 추가/숨김/정렬/설정)
- `posts` : 게시글(뉴스/실험/자유/커스텀) + **view_count**
- `comments` : 댓글
- `files` : 업로드 파일(첨부)

## 2) users
| 컬럼 | 타입 | 설명 |
|---|---|---|
| id | INTEGER PK | 사용자 ID |
| email | TEXT UNIQUE | 로그인 ID |
| nickname | TEXT | 표시 이름 |
| password_hash | TEXT | 비밀번호 해시 |
| score | INTEGER DEFAULT 0 NOT NULL | **유저 점수** |
| created_at | DATETIME | 생성일 |
| updated_at | DATETIME | 수정일 |

## 3) boards
| 컬럼 | 타입 | 설명 |
|---|---|---|
| id | INTEGER PK | 게시판 ID |
| name | TEXT | 게시판 이름(표시명) |
| slug | TEXT UNIQUE | 라우팅 키 (`news`, `lab`, `free`, `custom`) |
| type | ENUM('news','lab','free','custom') DEFAULT 'custom' | 게시판 유형 |
| is_private | BOOLEAN DEFAULT 0 | 비공개 여부 |
| is_hidden | BOOLEAN DEFAULT 0 | 메뉴 숨김 여부 |
| order_no | INTEGER DEFAULT 0 | 메뉴 정렬 |
| settings | JSON NULL | 게시판별 옵션(에디터, 업로드 제한 등) |
| created_by | INTEGER NULL FK users.id | 생성자 |
| created_at | DATETIME | 생성일 |
| updated_at | DATETIME | 수정일 |

## 4) posts
| 컬럼 | 타입 | 설명 |
|---|---|---|
| id | INTEGER PK | 게시글 ID |
| board_id | INTEGER FK boards.id | 소속 게시판 |
| author_id | INTEGER FK users.id | 작성자 |
| title | TEXT | 제목 |
| content | TEXT | 본문(HTML, CKEditor5) |
| status | ENUM('draft','published','archived') DEFAULT 'published' | 상태 |
| published_at | DATETIME NULL | 발행/예약발행 |
| is_pinned | BOOLEAN DEFAULT 0 | 상단 고정 |
| thumbnail_url | TEXT NULL | 썸네일(뉴스) |
| tags | JSON NULL | 태그 |
| view_count | INTEGER DEFAULT 0 NOT NULL | **조회수** |
| created_at | DATETIME | 생성일 |
| updated_at | DATETIME | 수정일 |

## 5) comments
| 컬럼 | 타입 | 설명 |
|---|---|---|
| id | INTEGER PK | 댓글 ID |
| post_id | INTEGER FK posts.id | 대상 글 |
| author_id | INTEGER FK users.id | 작성자 |
| content | TEXT | 내용 |
| created_at | DATETIME | 생성일 |
| updated_at | DATETIME | 수정일 |

## 6) files
| 컬럼 | 타입 | 설명 |
|---|---|---|
| id | INTEGER PK | 파일 ID |
| post_id | INTEGER FK posts.id | 연결 글 |
| original_name | TEXT | 원본 파일명 |
| url | TEXT | 저장 URL |
| size | INTEGER | 바이트 |
| content_type | TEXT | MIME |
| created_at | DATETIME | 업로드일 |

## 7) 초기 시드
```json
[
  {"name":"뉴스게시판","slug":"news","type":"news","order_no":10},
  {"name":"실험게시판","slug":"lab","type":"lab","order_no":20},
  {"name":"자유게시판","slug":"free","type":"free","order_no":30}
]
```

## 8) 마이그레이션(Sequelize) 포인트
- users.score (INTEGER, default 0, NOT NULL)
- boards.slug UNIQUE, type enum, is_private/is_hidden/order_no/settings/created_by
- posts.status enum, published_at, is_pinned, thumbnail_url, tags, **view_count**
