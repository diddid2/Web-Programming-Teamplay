package dao;

import dto.CartItem;
import util.DBUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class MarketCartDao {

    public boolean addToCart(int memberNo, long itemId, String cartType) {
        String sql =
                "INSERT INTO market_cart (member_no, item_id, cart_type, quantity) " +
                "VALUES (?, ?, ?, 1) " +
                
                "ON DUPLICATE KEY UPDATE quantity = 1";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberNo);
            ps.setLong(2, itemId);
            ps.setString(3, cartType);
            ps.executeUpdate(); 
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean removeCartItem(int memberNo, long cartId) {
        String sql = "DELETE FROM market_cart WHERE cart_id=? AND member_no=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, cartId);
            ps.setInt(2, memberNo);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean clearCart(int memberNo, String cartType) {
        String sql = "DELETE FROM market_cart WHERE member_no=? AND cart_type=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberNo);
            ps.setString(2, cartType);
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<CartItem> listCart(int memberNo) {
        String sql =
                "SELECT c.cart_id, c.member_no, c.item_id, c.cart_type, c.quantity, " +
                "       i.title, i.price, i.thumbnail_url, i.trade_type, i.status, i.campus " +
                "FROM market_cart c " +
                "JOIN market_item i ON i.id = c.item_id " +
                "WHERE c.member_no = ? " +
                "ORDER BY c.created_at DESC, c.cart_id DESC";

        List<CartItem> list = new ArrayList<>();
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, memberNo);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem ci = new CartItem();
                    ci.setCartId(rs.getLong("cart_id"));
                    ci.setMemberNo(rs.getInt("member_no"));
                    ci.setItemId(rs.getLong("item_id"));
                    ci.setCartType(rs.getString("cart_type"));
                    ci.setQuantity(rs.getInt("quantity"));
                    ci.setTitle(rs.getString("title"));
                    ci.setPrice(rs.getInt("price"));
                    ci.setThumbnailUrl(rs.getString("thumbnail_url"));
                    ci.setTradeType(rs.getString("trade_type"));
                    ci.setStatus(rs.getString("status"));
                    ci.setCampus(rs.getString("campus"));
                    list.add(ci);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
