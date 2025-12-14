


CREATE TABLE IF NOT EXISTS market_wish (
  id BIGINT AUTO_INCREMENT PRIMARY KEY,
  item_id BIGINT NOT NULL,
  member_no INT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_item_member (item_id, member_no),
  INDEX idx_member (member_no)
);





