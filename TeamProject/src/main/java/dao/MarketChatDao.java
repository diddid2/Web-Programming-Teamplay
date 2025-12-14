package dao;

import dto.ChatMessage;
import dto.ChatRoom;
import util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class MarketChatDao {

    /**
     * (itemId, buyerId) 기준으로 채팅방이 있으면 가져오고, 없으면 생성합니다.
     * @return roomId
     */
    public long getOrCreateRoom(long itemId, int sellerId, int buyerId) {
        String findSql = "SELECT room_id FROM market_chat_room WHERE item_id=? AND buyer_id=?";
        String insertSql = "INSERT INTO market_chat_room (item_id, seller_id, buyer_id, seller_last_read_msg_id, buyer_last_read_msg_id) "
                + "VALUES (?, ?, ?, 0, 0)";

        try (Connection conn = DBUtil.getConnection()) {
            // 1) find
            try (PreparedStatement ps = conn.prepareStatement(findSql)) {
                ps.setLong(1, itemId);
                ps.setInt(2, buyerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getLong(1);
                }
            }

            // 2) create
            try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, itemId);
                ps.setInt(2, sellerId);
                ps.setInt(3, buyerId);
                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) return rs.getLong(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * 트랜잭션을 공유하기 위한 버전(외부에서 Connection 전달)
     * - checkout 트랜잭션 내에서 호출되어야 Lock wait timeout을 피할 수 있습니다.
     * - conn은 닫지 않습니다.
     */
    public long getOrCreateRoom(Connection conn, long itemId, int sellerId, int buyerId) {
        String findSql = "SELECT room_id FROM market_chat_room WHERE item_id=? AND buyer_id=?";
        String insertSql = "INSERT INTO market_chat_room (item_id, seller_id, buyer_id, seller_last_read_msg_id, buyer_last_read_msg_id) "
                + "VALUES (?, ?, ?, 0, 0)";

        try {
            // 1) find
            try (PreparedStatement ps = conn.prepareStatement(findSql)) {
                ps.setLong(1, itemId);
                ps.setInt(2, buyerId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) return rs.getLong(1);
                }
            }

            // 2) create
            try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setLong(1, itemId);
                ps.setInt(2, sellerId);
                ps.setInt(3, buyerId);
                int affected = ps.executeUpdate();
                if (affected > 0) {
                    try (ResultSet rs = ps.getGeneratedKeys()) {
                        if (rs.next()) return rs.getLong(1);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }


    public long findRoomId(long itemId, int buyerId) {
        String sql = "SELECT room_id FROM market_chat_room WHERE item_id=? AND buyer_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, itemId);
            ps.setInt(2, buyerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public boolean isParticipant(long roomId, int memberNo) {
        String sql = "SELECT 1 FROM market_chat_room WHERE room_id=? AND (seller_id=? OR buyer_id=?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, roomId);
            ps.setInt(2, memberNo);
            ps.setInt(3, memberNo);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public ChatRoom getRoomDetail(long roomId) {
        String sql =
                "SELECT r.room_id, r.item_id, r.seller_id, r.buyer_id, " +
                "       i.title AS item_title, i.status AS item_status, i.price AS item_price, i.thumbnail_url AS item_thumb, " +
                "       ms.NAME AS seller_name, mb.NAME AS buyer_name, " +
                "       lm.message AS last_message, lm.created_at AS last_message_at " +
                "FROM market_chat_room r " +
                "JOIN market_item i ON i.id = r.item_id " +
                "LEFT JOIN MEMBER ms ON ms.MEMBER_NO = r.seller_id " +
                "LEFT JOIN MEMBER mb ON mb.MEMBER_NO = r.buyer_id " +
                "LEFT JOIN ( " +
                "   SELECT m1.room_id, m1.message, m1.created_at " +
                "   FROM market_chat_message m1 " +
                "   JOIN (SELECT room_id, MAX(msg_id) AS max_id FROM market_chat_message GROUP BY room_id) t " +
                "     ON t.room_id = m1.room_id AND t.max_id = m1.msg_id " +
                ") lm ON lm.room_id = r.room_id " +
                "WHERE r.room_id = ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapRoom(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<ChatRoom> listRoomsByUser(int memberNo) {
        // unreadCount: 내가 마지막으로 읽은 msg_id 이후, 내가 보낸 메시지를 제외하고 카운트
        String sql =
                "SELECT r.room_id, r.item_id, r.seller_id, r.buyer_id, " +
                "       i.title AS item_title, i.status AS item_status, i.price AS item_price, i.thumbnail_url AS item_thumb, " +
                "       ms.NAME AS seller_name, mb.NAME AS buyer_name, " +
                "       lm.message AS last_message, lm.created_at AS last_message_at, " +
                "       COALESCE(uc.unread_count, 0) AS unread_count " +
                "FROM market_chat_room r " +
                "JOIN market_item i ON i.id = r.item_id " +
                "LEFT JOIN MEMBER ms ON ms.MEMBER_NO = r.seller_id " +
                "LEFT JOIN MEMBER mb ON mb.MEMBER_NO = r.buyer_id " +
                "LEFT JOIN ( " +
                "   SELECT m1.room_id, m1.message, m1.created_at " +
                "   FROM market_chat_message m1 " +
                "   JOIN (SELECT room_id, MAX(msg_id) AS max_id FROM market_chat_message GROUP BY room_id) t " +
                "     ON t.room_id = m1.room_id AND t.max_id = m1.msg_id " +
                ") lm ON lm.room_id = r.room_id " +
                "LEFT JOIN (" +
                "   SELECT m.room_id, COUNT(*) AS unread_count " +
                "   FROM market_chat_message m " +
                "   JOIN market_chat_room rr ON rr.room_id = m.room_id " +
                "   WHERE (rr.seller_id = ? OR rr.buyer_id = ?) " +
                "     AND m.msg_id > (CASE WHEN rr.seller_id = ? THEN rr.seller_last_read_msg_id ELSE rr.buyer_last_read_msg_id END) " +
                "     AND (m.sender_id IS NULL OR m.sender_id <> ?) " +
                "   GROUP BY m.room_id " +
                ") uc ON uc.room_id = r.room_id " +
                "WHERE r.seller_id = ? OR r.buyer_id = ? " +
                "ORDER BY COALESCE(lm.created_at, r.created_at) DESC";

        List<ChatRoom> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            // uc subquery
            ps.setInt(1, memberNo);
            ps.setInt(2, memberNo);
            ps.setInt(3, memberNo);
            ps.setInt(4, memberNo);
            // main where
            ps.setInt(5, memberNo);
            ps.setInt(6, memberNo);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) list.add(mapRoom(rs));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 트랜잭션 공유 버전 (외부에서 Connection 전달)
     * - conn은 닫지 않습니다.
     */
    public long insertMessage(Connection conn, long roomId, Integer senderId, String message, String messageType) {
        String sql = "INSERT INTO market_chat_message (room_id, sender_id, message, message_type) VALUES (?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, roomId);
            if (senderId != null) ps.setInt(2, senderId);
            else ps.setNull(2, Types.INTEGER);
            ps.setString(3, message);
            ps.setString(4, messageType == null ? "USER" : messageType);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getLong(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }


    public long insertMessage(long roomId, int senderId, String message) {
        return insertMessage(roomId, Integer.valueOf(senderId), message, "USER");
    }

    /**
     * 시스템 메시지/주문 상태 알림 등 (senderId NULL 허용)
     */
    public long insertMessage(long roomId, Integer senderId, String message, String messageType) {
        String sql = "INSERT INTO market_chat_message (room_id, sender_id, message, message_type) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setLong(1, roomId);
            if (senderId != null) ps.setInt(2, senderId);
            else ps.setNull(2, Types.INTEGER);
            ps.setString(3, message);
            ps.setString(4, messageType == null ? "USER" : messageType);
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) return rs.getLong(1);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    public List<ChatMessage> listMessages(long roomId, long afterMsgId, int limit) {
        String sql = "SELECT msg_id, room_id, sender_id, message, message_type, created_at " +
                     "FROM market_chat_message WHERE room_id=? AND msg_id > ? " +
                     "ORDER BY msg_id ASC LIMIT ?";
        List<ChatMessage> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, roomId);
            ps.setLong(2, afterMsgId);
            ps.setInt(3, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ChatMessage m = new ChatMessage();
                    m.setMsgId(rs.getLong("msg_id"));
                    m.setRoomId(rs.getLong("room_id"));
                    Integer sender = (Integer) rs.getObject("sender_id");
                    m.setSenderId(sender);
                    m.setMessage(rs.getString("message"));
                    m.setMessageType(rs.getString("message_type"));
                    m.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(m);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 채팅방 읽음 처리: 현재 사용자(seller/buyer)에 해당하는 last_read_msg_id를 올립니다.
     */
    public void markRead(long roomId, int memberNo, long lastMsgId) {
        if (roomId <= 0 || memberNo <= 0 || lastMsgId <= 0) return;
        String sqlSeller = "UPDATE market_chat_room SET seller_last_read_msg_id = GREATEST(seller_last_read_msg_id, ?) "
                + "WHERE room_id=? AND seller_id=?";
        String sqlBuyer = "UPDATE market_chat_room SET buyer_last_read_msg_id = GREATEST(buyer_last_read_msg_id, ?) "
                + "WHERE room_id=? AND buyer_id=?";
        try (Connection conn = DBUtil.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlSeller)) {
                ps.setLong(1, lastMsgId);
                ps.setLong(2, roomId);
                ps.setInt(3, memberNo);
                ps.executeUpdate();
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlBuyer)) {
                ps.setLong(1, lastMsgId);
                ps.setLong(2, roomId);
                ps.setInt(3, memberNo);
                ps.executeUpdate();
            }
        } catch (Exception e) {
            // 읽음처리는 실패해도 서비스 진행에는 영향 없게
            e.printStackTrace();
        }
    }

    /**
     * GNB 배지용: 전체 안읽은 메시지 개수
     */
    public int countUnreadTotal(int memberNo) {
        String sql =
                "SELECT COUNT(*) " +
                "FROM market_chat_message m " +
                "JOIN market_chat_room r ON r.room_id = m.room_id " +
                "WHERE (r.seller_id=? OR r.buyer_id=?) " +
                "  AND m.msg_id > (CASE WHEN r.seller_id=? THEN r.seller_last_read_msg_id ELSE r.buyer_last_read_msg_id END) " +
                "  AND (m.sender_id IS NULL OR m.sender_id <> ?)";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberNo);
            ps.setInt(2, memberNo);
            ps.setInt(3, memberNo);
            ps.setInt(4, memberNo);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    private ChatRoom mapRoom(ResultSet rs) throws SQLException {
        ChatRoom r = new ChatRoom();
        r.setRoomId(rs.getLong("room_id"));
        r.setItemId(rs.getLong("item_id"));
        r.setSellerId(rs.getInt("seller_id"));
        r.setBuyerId(rs.getInt("buyer_id"));
        r.setItemTitle(rs.getString("item_title"));
        r.setItemStatus(rs.getString("item_status"));
        r.setItemPrice(rs.getInt("item_price"));
        r.setItemThumbnailUrl(rs.getString("item_thumb"));
        r.setSellerName(rs.getString("seller_name"));
        r.setBuyerName(rs.getString("buyer_name"));
        r.setLastMessage(rs.getString("last_message"));
        r.setLastMessageAt(rs.getTimestamp("last_message_at"));
        try {
            r.setUnreadCount(rs.getInt("unread_count"));
        } catch (SQLException ignore) {}
        return r;
    }
}