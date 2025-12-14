package dao;

import dao.MarketChatDao;
import dto.BuyerAddress;
import dto.MarketOrder;
import util.DBUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;







public class MarketOrderDao {

    


    public List<Long> checkoutInstantCart(int buyerId) throws SQLException {
        throw new SQLException("배송지 정보가 필요합니다. 구매 화면에서 배송지를 입력해주세요.");
    }

    







    public List<Long> checkoutInstantCart(int buyerId, BuyerAddress addr) throws Exception {
        List<Long> roomIds = new ArrayList<>();

        if (addr == null
                || isBlank(addr.getRecipientName())
                || isBlank(addr.getPhone())
                || isBlank(addr.getPostcode())
                || isBlank(addr.getAddress1())) {
            throw new SQLException("배송지 정보가 올바르지 않습니다.");
        }

        String cartSql =
                "SELECT c.item_id " +
                "FROM market_cart c " +
                "WHERE c.member_no=? AND c.cart_type='IMMEDIATE' " +
                "ORDER BY c.created_at ASC, c.cart_id ASC";

        String lockItemSql =
        		  "SELECT id, writer_id, price, status, instant_buy, title " +
        		  "FROM market_item WHERE id=? FOR UPDATE";

        String insertOrderSql =
                "INSERT INTO market_order (" +
                "  item_id, seller_id, buyer_id, price, status, " +
                "  recipient_name, phone, postcode, address1, address2, memo, paid_at" +
                ") VALUES (?, ?, ?, ?, 'PAID', ?, ?, ?, ?, ?, ?, NOW())";

        String updateItemSql =
                "UPDATE market_item SET status='SOLD_OUT', buyer_id=?, sold_at=NOW() " +
                "WHERE id=? AND status='ON_SALE'";

        String clearCartSql = "DELETE FROM market_cart WHERE member_no=? AND cart_type='IMMEDIATE'";

        try (Connection conn = DBUtil.getConnection()) {
            conn.setAutoCommit(false);
            try {
                List<Long> itemIds = new ArrayList<>();
                try (PreparedStatement ps = conn.prepareStatement(cartSql)) {
                    ps.setInt(1, buyerId);
                    try (ResultSet rs = ps.executeQuery()) {
                        while (rs.next()) itemIds.add(rs.getLong(1));
                    }
                }

                if (itemIds.isEmpty()) {
                    conn.rollback();
                    return roomIds;
                }

                
                upsertBuyerDefaultAddress(conn, buyerId, addr);

                MarketChatDao chatDao = new MarketChatDao();

                for (Long itemId : itemIds) {
                    int sellerId;
                    int price;
                    String status;
                    int instantBuy;
                    String itemTitle = null;

                    
                    try (PreparedStatement ps = conn.prepareStatement(lockItemSql)) {
                        ps.setLong(1, itemId);
                        try (ResultSet rs = ps.executeQuery()) {
                            if (!rs.next()) {
                                throw new SQLException("상품 정보를 찾을 수 없습니다.");
                            }
                            sellerId = rs.getInt("writer_id");
                            price = rs.getInt("price");
                            status = rs.getString("status");
                            instantBuy = rs.getInt("instant_buy");
                        
                            itemTitle = rs.getString("title");}
                    }

                    if (sellerId == buyerId) {
                        throw new SQLException("내가 올린 상품은 구매할 수 없습니다.");
                    }
                    if (instantBuy != 1) {
                        throw new SQLException("즉시구매 상품만 구매할 수 있습니다.");
                    }
                    if (status == null || !"ON_SALE".equalsIgnoreCase(status)) {
                        throw new SQLException("이미 거래가 진행/완료된 상품이 포함되어 있습니다.");
                    }

                    
                    long orderId;
                    try (PreparedStatement ps = conn.prepareStatement(insertOrderSql, Statement.RETURN_GENERATED_KEYS)) {
                        ps.setLong(1, itemId);
                        ps.setInt(2, sellerId);
                        ps.setInt(3, buyerId);
                        ps.setInt(4, price);

                        ps.setString(5, addr.getRecipientName());
                        ps.setString(6, addr.getPhone());
                        ps.setString(7, addr.getPostcode());
                        ps.setString(8, addr.getAddress1());
                        ps.setString(9, blankToNull(addr.getAddress2()));
                        ps.setString(10, blankToNull(addr.getMemo()));

                        int affected = ps.executeUpdate();
                        if (affected <= 0) throw new SQLException("주문 생성 실패");
                        try (ResultSet rs = ps.getGeneratedKeys()) {
                            if (rs.next()) orderId = rs.getLong(1);
                            else throw new SQLException("주문 생성 키 조회 실패");
                        }
                    }

                    
                    try (PreparedStatement ps = conn.prepareStatement(updateItemSql)) {
                        ps.setInt(1, buyerId);
                        ps.setLong(2, itemId);
                        int affected = ps.executeUpdate();
                        if (affected <= 0) throw new SQLException("상품 상태 변경 실패(동시구매 가능성)");
                    }

                    
                    
                    long roomId = chatDao.getOrCreateRoom(conn, itemId, sellerId, buyerId);
                    if (roomId > 0) {
                        roomIds.add(roomId);
                        chatDao.insertMessage(
                                conn,
                                roomId,
                                null,
                                "🔔 [바로구매 주문 접수] '" + (itemTitle == null ? "" : itemTitle) + "' 상품이 구매되었습니다. 주문 상세에서 배송지/연락처를 확인하고 송장번호를 입력해주세요. (주문번호: " + orderId + ")",
                                "SYSTEM"
                        );
                    }
                }

                
                try (PreparedStatement ps = conn.prepareStatement(clearCartSql)) {
                    ps.setInt(1, buyerId);
                    ps.executeUpdate();
                }

                conn.commit();
                return roomIds;
            } catch (Exception e) {
                conn.rollback();
                if (e instanceof SQLException) throw (SQLException) e;
                throw new SQLException(e);
            } finally {
                conn.setAutoCommit(true);
            }
        }
    }

    


    public MarketOrder findByRoom(long roomId) {
        String sql =
                "SELECT o.order_id, o.item_id, o.seller_id, o.buyer_id, o.price, o.status, " +
                "       o.carrier, o.tracking_number, " +
                "       o.recipient_name, o.phone, o.postcode, o.address1, o.address2, o.memo, " +
                "       o.paid_at, o.shipped_at, o.created_at " +
                "FROM market_order o " +
                "JOIN market_chat_room r ON r.item_id = o.item_id AND r.buyer_id = o.buyer_id " +
                "WHERE r.room_id = ?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, roomId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapOrder(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    


    public boolean setTracking(long orderId, int sellerId, String carrier, String trackingNumber) {
        String sql =
                "UPDATE market_order SET carrier=?, tracking_number=?, status='SHIPPED', shipped_at=NOW() " +
                "WHERE order_id=? AND seller_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, carrier);
            ps.setString(2, trackingNumber);
            ps.setLong(3, orderId);
            ps.setInt(4, sellerId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    
    public MarketOrder findById(long orderId) {
        String sql =
                "SELECT order_id, item_id, seller_id, buyer_id, price, status, carrier, tracking_number, " +
                "       recipient_name, phone, postcode, address1, address2, memo, " +
                "       paid_at, shipped_at, created_at " +
                "FROM market_order WHERE order_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapOrder(rs);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    
    public BuyerAddress getBuyerDefaultAddress(int buyerId) {
        String sql =
                "SELECT buyer_id, recipient_name, phone, postcode, address1, address2, memo " +
                "FROM market_buyer_address WHERE buyer_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, buyerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    BuyerAddress a = new BuyerAddress();
                    a.setBuyerId(rs.getInt("buyer_id"));
                    a.setRecipientName(rs.getString("recipient_name"));
                    a.setPhone(rs.getString("phone"));
                    a.setPostcode(rs.getString("postcode"));
                    a.setAddress1(rs.getString("address1"));
                    a.setAddress2(rs.getString("address2"));
                    a.setMemo(rs.getString("memo"));
                    return a;
                }
            }
        } catch (Exception e) {
            
            e.printStackTrace();
        }
        return null;
    }

    private void upsertBuyerDefaultAddress(Connection conn, int buyerId, BuyerAddress addr) throws SQLException {
        String sql =
                "INSERT INTO market_buyer_address (buyer_id, recipient_name, phone, postcode, address1, address2, memo) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?) " +
                "ON DUPLICATE KEY UPDATE " +
                "  recipient_name=VALUES(recipient_name), " +
                "  phone=VALUES(phone), " +
                "  postcode=VALUES(postcode), " +
                "  address1=VALUES(address1), " +
                "  address2=VALUES(address2), " +
                "  memo=VALUES(memo)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, buyerId);
            ps.setString(2, addr.getRecipientName());
            ps.setString(3, addr.getPhone());
            ps.setString(4, addr.getPostcode());
            ps.setString(5, addr.getAddress1());
            ps.setString(6, blankToNull(addr.getAddress2()));
            ps.setString(7, blankToNull(addr.getMemo()));
            ps.executeUpdate();
        }
    }

    private MarketOrder mapOrder(ResultSet rs) throws SQLException {
        MarketOrder o = new MarketOrder();
        o.setOrderId(rs.getLong("order_id"));
        o.setItemId(rs.getLong("item_id"));
        o.setSellerId(rs.getInt("seller_id"));
        o.setBuyerId(rs.getInt("buyer_id"));
        o.setPrice(rs.getInt("price"));
        o.setStatus(rs.getString("status"));
        o.setCarrier(rs.getString("carrier"));
        o.setTrackingNumber(rs.getString("tracking_number"));

        try { o.setRecipientName(rs.getString("recipient_name")); } catch (SQLException ignore) {}
        try { o.setPhone(rs.getString("phone")); } catch (SQLException ignore) {}
        try { o.setPostcode(rs.getString("postcode")); } catch (SQLException ignore) {}
        try { o.setAddress1(rs.getString("address1")); } catch (SQLException ignore) {}
        try { o.setAddress2(rs.getString("address2")); } catch (SQLException ignore) {}
        try { o.setMemo(rs.getString("memo")); } catch (SQLException ignore) {}
        o.setPaidAt(rs.getTimestamp("paid_at"));
        o.setShippedAt(rs.getTimestamp("shipped_at"));
        o.setCreatedAt(rs.getTimestamp("created_at"));
        return o;
    }

    private static boolean isBlank(String s) {
        return s == null || s.trim().isEmpty();
    }

    private static String blankToNull(String s) {
        if (s == null) return null;
        String t = s.trim();
        return t.isEmpty() ? null : t;
    }
}
