


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
