


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
