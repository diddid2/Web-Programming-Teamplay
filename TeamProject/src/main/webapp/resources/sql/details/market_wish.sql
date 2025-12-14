-- 강남마켓 찜(위시) 테이블
-- MySQL 기준

CREATE TABLE IF NOT EXISTS market_wish (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  item_id BIGINT NOT NULL,
  member_no INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_item_member (item_id, member_no),
  INDEX idx_member (member_no)
);

-- (선택) 외래키를 걸고 싶다면 아래를 사용하세요. (기존 테이블/컬럼명 확인 필요)
-- ALTER TABLE market_wish
--   ADD CONSTRAINT fk_wish_item FOREIGN KEY (item_id) REFERENCES market_item(id) ON DELETE CASCADE,
--   ADD CONSTRAINT fk_wish_member FOREIGN KEY (member_no) REFERENCES MEMBER(MEMBER_NO) ON DELETE CASCADE;
