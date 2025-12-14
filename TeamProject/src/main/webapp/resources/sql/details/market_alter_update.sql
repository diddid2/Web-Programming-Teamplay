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
