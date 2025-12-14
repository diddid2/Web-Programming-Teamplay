-- ==========================================
-- KangnamTime 프로젝트 MySQL 전체 DDL
-- (Oracle → MySQL 변환 버전)
-- ==========================================

-- 0. 데이터베이스 생성 및 선택
CREATE DATABASE IF NOT EXISTS kangnamtime
  DEFAULT CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE kangnamtime;

-- kangnamtime 라는 계정 생성 (비번은 너가 원하는 걸로)
CREATE USER 'kangnamtime'@'localhost'
  IDENTIFIED WITH mysql_native_password BY '4321';

-- DB 권한 주기 (DB 이름 kangnamtime 라고 가정)
GRANT ALL PRIVILEGES ON kangnamtime.* TO 'kangnamtime'@'localhost';
FLUSH PRIVILEGES;

-- 안전하게 드랍 (처음 세팅할 때 한 번만 사용)
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS BOARD_LIKE;
DROP TABLE IF EXISTS BOARD_SCRAP;
DROP TABLE IF EXISTS BOARD_COMMENT;
DROP TABLE IF EXISTS BOARD_POST;
DROP TABLE IF EXISTS ASSIGNMENT;
DROP TABLE IF EXISTS LECTURE;
DROP TABLE IF EXISTS USER_INTEGRATION;
DROP TABLE IF EXISTS MEMBER;

SET FOREIGN_KEY_CHECKS = 1;

-- ==========================================
-- 1. MEMBER (회원)
-- ==========================================
CREATE TABLE MEMBER (
    MEMBER_NO   INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID     VARCHAR(50)  NOT NULL UNIQUE,
    USER_PW     VARCHAR(200) NOT NULL,        -- 해시된 비밀번호
    NAME        VARCHAR(50)  NOT NULL,
    MAJOR       VARCHAR(100),
    CREATED_AT  DATETIME     DEFAULT NOW()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- 2. USER_INTEGRATION (외부 계정 연동)
--    에브리타임 / 이캠퍼스 계정 저장 등
-- ==========================================
CREATE TABLE USER_INTEGRATION (
    USER_ID       VARCHAR(50)  NOT NULL,
    EVERYTIME_ID  VARCHAR(100),
    EVERYTIME_PW  VARCHAR(200),
    KANGNAM_ID  VARCHAR(100),
    KANGNAM_PW  VARCHAR(200),
    ECAMPUS_ID    VARCHAR(100),
    ECAMPUS_PW    VARCHAR(200),
    UPDATED_AT    DATETIME     DEFAULT NOW(),
    CONSTRAINT PK_USER_INTEGRATION PRIMARY KEY (USER_ID),
    CONSTRAINT FK_UI_MEMBER FOREIGN KEY (USER_ID)
        REFERENCES MEMBER(USER_ID)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- 3. BOARD_POST (게시글)
-- ==========================================
CREATE TABLE BOARD_POST (
    POST_NO        INT AUTO_INCREMENT PRIMARY KEY,   -- NUMBER → INT + AUTO_INCREMENT
    USER_ID        VARCHAR(50) NOT NULL,             -- FK → MEMBER.USER_ID
    TITLE          VARCHAR(200) NOT NULL,
    CONTENT        TEXT NOT NULL,                    -- CLOB → TEXT
    HIT            INT DEFAULT 0,                    -- NUMBER
    LIKE_COUNT     INT DEFAULT 0,                    -- NUMBER
    SCRAP_COUNT    INT DEFAULT 0,                    -- NUMBER
    COMMENT_COUNT  INT DEFAULT 0,                    -- NUMBER
    CREATED_AT     DATETIME DEFAULT NOW(),

    CONSTRAINT FK_POST_MEMBER
        FOREIGN KEY (USER_ID)
        REFERENCES MEMBER(USER_ID)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ==========================================
-- 4. BOARD_COMMENT (댓글)
-- ==========================================
CREATE TABLE BOARD_POST (
    POST_NO        INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID        VARCHAR(50) NOT NULL,
    TITLE          VARCHAR(200) NOT NULL,
    CONTENT        TEXT NOT NULL,
    HIT            INT DEFAULT 0,
    LIKE_COUNT     INT DEFAULT 0,
    SCRAP_COUNT    INT DEFAULT 0,
    COMMENT_COUNT  INT DEFAULT 0,
    CREATED_AT     DATETIME DEFAULT NOW(),

    CONSTRAINT FK_POST_MEMBER
        FOREIGN KEY (USER_ID)
        REFERENCES MEMBER(USER_ID)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- ==========================================
-- 5. BOARD_LIKE (게시글 공감)
-- ==========================================
CREATE TABLE BOARD_LIKE (
    POST_NO      INT         NOT NULL,
    USER_ID      VARCHAR(50) NOT NULL,
    CREATED_AT   DATETIME    DEFAULT NOW(),
    CONSTRAINT PK_BOARD_LIKE PRIMARY KEY (POST_NO, USER_ID),
    CONSTRAINT FK_BL_POST FOREIGN KEY (POST_NO)
        REFERENCES BOARD_POST(POST_NO)
        ON DELETE CASCADE,
    CONSTRAINT FK_BL_MEMBER FOREIGN KEY (USER_ID)
        REFERENCES MEMBER(USER_ID)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- 6. BOARD_SCRAP (게시글 스크랩)
-- ==========================================
CREATE TABLE BOARD_SCRAP (
    POST_NO      INT         NOT NULL,
    USER_ID      VARCHAR(50) NOT NULL,
    CREATED_AT   DATETIME    DEFAULT NOW(),
    CONSTRAINT PK_BOARD_SCRAP PRIMARY KEY (POST_NO, USER_ID),
    CONSTRAINT FK_BS_POST FOREIGN KEY (POST_NO)
        REFERENCES BOARD_POST(POST_NO)
        ON DELETE CASCADE,
    CONSTRAINT FK_BS_MEMBER FOREIGN KEY (USER_ID)
        REFERENCES MEMBER(USER_ID)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- 7. ASSIGNMENT (과제 스케줄러)
-- ==========================================
CREATE TABLE ASSIGNMENT (
    ASSIGN_NO      INT AUTO_INCREMENT PRIMARY KEY,   -- NUMBER → INT + AUTO_INCREMENT
    USER_ID        VARCHAR(50)  NOT NULL,            -- VARCHAR2(50)
    TITLE          VARCHAR(200) NOT NULL,            -- VARCHAR2(200)
    COURSE_NAME    VARCHAR(200),                     -- VARCHAR2(200)
    DESCRIPTION    TEXT,                             -- CLOB → TEXT
    START_DATE     DATE,                             -- DATE
    DUE_DATE       DATE        NOT NULL,             -- DATE NOT NULL
    PRIORITY       INT,                              -- NUMBER
    STATUS         VARCHAR(20),                      -- VARCHAR2(20)
    CREATED_AT     DATETIME DEFAULT NOW(),           -- DATE → DATETIME
    UPDATED_AT     DATETIME,                         -- DATE → DATETIME
    IS_PASSED      TINYINT(1),                       -- NUMBER(1) → TINYINT(1)
    LINK           VARCHAR(1000),                    -- VARCHAR2(1000)

    CONSTRAINT FK_ASSIGN_MEMBER
        FOREIGN KEY (USER_ID)
        REFERENCES MEMBER(USER_ID)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ==========================================
-- 8. LECTURE (시간표 / 강의 정보)
--    timetableMain.jsp에서 사용
-- ==========================================
CREATE TABLE LECTURE (
    LECTURE_ID   INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID      VARCHAR(50)  NOT NULL,
    TITLE        VARCHAR(200) NOT NULL,       -- 과목명
    DAY          VARCHAR(10),                 -- 요일 (MON, TUE / 월, 화 등)
    START_MIN    INT,                         -- 하루 기준 분 단위 시작시간
    END_MIN      INT,                         -- 분 단위 종료시간
    LOCATION     VARCHAR(200),                -- 강의실
    COLOR        VARCHAR(20),                 -- 블록 색상(선택)
    CREATED_AT   DATETIME     DEFAULT NOW(),
    UPDATED_AT   DATETIME,
    CONSTRAINT FK_LEC_MEMBER FOREIGN KEY (USER_ID)
        REFERENCES MEMBER(USER_ID)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE market_item (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,      -- 글 번호
    title VARCHAR(100) NOT NULL,              -- 제목
    category VARCHAR(30) NOT NULL,            -- 교재 · 전공책 / 전자기기 / 자취템 / 패션 · 잡화 / 기타
    price INT NOT NULL,                       -- 가격 (원)
    status VARCHAR(20) NOT NULL,              -- ON_SALE / RESERVED / SOLD_OUT
    campus VARCHAR(30) NOT NULL,              -- 강남대 정문 / 기숙사 / 역 인근 등
    meeting_place VARCHAR(100) NULL,          -- 교양관 근처 등
    meeting_time VARCHAR(100) NULL,           -- 오늘 18:00 직거래 가능 등 간단 텍스트
    trade_type VARCHAR(20) NOT NULL,          -- DIRECT / DELIVERY / BOTH
    wish_count INT NOT NULL DEFAULT 0,        -- 찜 수
    chat_count INT NOT NULL DEFAULT 0,        -- 채팅 수
    thumbnail_url VARCHAR(255) NULL,          -- 썸네일 이미지 경로 (나중에 파일 업로드 붙일 때 사용)
    description TEXT NULL,                    -- 상세 설명 (글쓰기 페이지에서 작성)
    writer_id INT NULL,                       -- 작성자 (회원 PK)
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE BOARD_NOTICE (
    NOTICE_NO   INT AUTO_INCREMENT PRIMARY KEY,
    USER_ID     VARCHAR(50)  NOT NULL,
    TITLE       VARCHAR(200) NOT NULL,
    CONTENT     MEDIUMTEXT   NOT NULL,
    HIT         INT          NOT NULL DEFAULT 0,
    CREATED_AT  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_general_ci;

CREATE TABLE USER_TIMETABLE (
    TT_NO       INT AUTO_INCREMENT PRIMARY KEY,   -- 시간표 번호 (자동 증가)
    USER_ID     VARCHAR(50)      NOT NULL,        -- 로그인 유저 ID
    TITLE       VARCHAR(200)     NOT NULL,        -- 과목명
    PROFESSOR   VARCHAR(100),                     -- 교수명
    DAY         TINYINT          NOT NULL,        -- 요일 (0~4 or 1~5; 기존 로직 그대로)
    START_MIN   INT              NOT NULL,        -- 시작 시간 (분 단위, 9시=540)
    END_MIN     INT              NOT NULL,        -- 종료 시간 (분 단위)
    UPDATED_AT  DATETIME         NOT NULL DEFAULT CURRENT_TIMESTAMP  -- 동기화 시각
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE market_buyer_address (
  buyer_id INT PRIMARY KEY,
  recipient_name VARCHAR(50) NOT NULL,
  phone VARCHAR(20) NOT NULL,
  postcode VARCHAR(10) NOT NULL,
  address1 VARCHAR(255) NOT NULL,
  address2 VARCHAR(255),
  memo VARCHAR(255),
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 강남마켓 장바구니 테이블 (MySQL)
-- 실행 전: market_item(id), MEMBER(MEMBER_NO) 존재 가정

CREATE TABLE IF NOT EXISTS market_cart (
    cart_id    BIGINT AUTO_INCREMENT PRIMARY KEY,
    member_no  INT NOT NULL,
    item_id    BIGINT NOT NULL,
    cart_type  ENUM('IMMEDIATE','DELIVERY') NOT NULL,
    quantity   INT NOT NULL DEFAULT 1,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_member_item_type (member_no, item_id, cart_type),
    KEY idx_member (member_no),

    CONSTRAINT fk_cart_member FOREIGN KEY (member_no) REFERENCES MEMBER(MEMBER_NO) ON DELETE CASCADE,
    CONSTRAINT fk_cart_item   FOREIGN KEY (item_id) REFERENCES market_item(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 강남마켓 채팅 테이블 (MySQL)
-- 실행 전: market_item(id), MEMBER(MEMBER_NO) 존재 가정

CREATE TABLE IF NOT EXISTS market_chat_room (
    room_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    item_id     BIGINT NOT NULL,
    seller_id   INT NOT NULL,
    buyer_id    INT NOT NULL,
    created_at  DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    UNIQUE KEY uq_item_buyer (item_id, buyer_id),
    KEY idx_seller (seller_id),
    KEY idx_buyer (buyer_id),
    CONSTRAINT fk_chat_room_item FOREIGN KEY (item_id) REFERENCES market_item(id) ON DELETE CASCADE,
    CONSTRAINT fk_chat_room_seller FOREIGN KEY (seller_id) REFERENCES MEMBER(MEMBER_NO) ON DELETE CASCADE,
    CONSTRAINT fk_chat_room_buyer FOREIGN KEY (buyer_id) REFERENCES MEMBER(MEMBER_NO) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS market_chat_message (
    msg_id     BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_id    BIGINT NOT NULL,
    sender_id  INT NOT NULL,
    message    TEXT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    KEY idx_room_msg (room_id, msg_id),
    CONSTRAINT fk_chat_msg_room FOREIGN KEY (room_id) REFERENCES market_chat_room(room_id) ON DELETE CASCADE,
    CONSTRAINT fk_chat_msg_sender FOREIGN KEY (sender_id) REFERENCES MEMBER(MEMBER_NO) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE market_order (
  order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  item_id BIGINT NOT NULL,
  seller_id INT NOT NULL,
  buyer_id INT NOT NULL,
  price INT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'PAID',
  carrier VARCHAR(50),
  tracking_number VARCHAR(100),
  paid_at DATETIME NULL DEFAULT CURRENT_TIMESTAMP,
  shipped_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE market_order
  ADD COLUMN recipient_name VARCHAR(50) NOT NULL,
  ADD COLUMN phone VARCHAR(20) NOT NULL,
  ADD COLUMN postcode VARCHAR(10) NOT NULL,
  ADD COLUMN address1 VARCHAR(255) NOT NULL,
  ADD COLUMN address2 VARCHAR(255) NULL,
  ADD COLUMN memo VARCHAR(255) NULL;

CREATE TABLE IF NOT EXISTS market_wish (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  item_id BIGINT NOT NULL,
  member_no INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_item_member (item_id, member_no),
  INDEX idx_member (member_no)
);


ALTER TABLE market_item 
ADD COLUMN instant_buy TINYINT(1) NOT NULL DEFAULT 0,
ADD COLUMN buyer_id INT NULL,
ADD COLUMN sold_at DATETIME NULL;

ALTER TABLE market_cart 
ADD UNIQUE KEY uk_cart (member_no, item_id, cart_type);

ALTER TABLE market_chat_message
ADD COLUMN message_type VARCHAR(20) NOT NULL DEFAULT 'USER',
MODIFY COLUMN sender_id INT NULL;

ALTER TABLE market_chat_room
ADD COLUMN seller_last_read_msg_id BIGINT NOT NULL DEFAULT 0,
ADD COLUMN buyer_last_read_msg_id BIGINT NOT NULL DEFAULT 0;

