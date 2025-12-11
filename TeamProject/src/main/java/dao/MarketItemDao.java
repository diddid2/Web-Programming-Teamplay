package dao;


import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import dto.MarketItem;
import util.DBUtil;



public class MarketItemDao {

    /**
     * 글 등록 (INSERT)
     * @return 생성된 PK(id)를 리턴, 실패하면 -1
     */
    public long insert(MarketItem item) {
        String sql = "INSERT INTO market_item " +
                "(title, category, price, status, campus, " +
                "meeting_place, meeting_time, trade_type, " +
                "wish_count, chat_count, thumbnail_url, description, writer_id) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        long generatedId = -1;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, item.getTitle());
            pstmt.setString(2, item.getCategory());
            pstmt.setInt(3, item.getPrice());
            pstmt.setString(4, item.getStatus());        // 보통 "ON_SALE"
            pstmt.setString(5, item.getCampus());
            pstmt.setString(6, item.getMeetingPlace());
            pstmt.setString(7, item.getMeetingTime());
            pstmt.setString(8, item.getTradeType());
            pstmt.setInt(9, item.getWishCount());        // 0
            pstmt.setInt(10, item.getChatCount());       // 0
            pstmt.setString(11, item.getThumbnailUrl());
            pstmt.setString(12, item.getDescription());

            if (item.getWriterId() != null) {
                pstmt.setInt(13, item.getWriterId());
            } else {
                pstmt.setNull(13, Types.INTEGER);
            }

            int affected = pstmt.executeUpdate();

            if (affected > 0) {
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        generatedId = rs.getLong(1);
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return generatedId;
    }

    /**
     * 최근 등록 순으로 최대 limit개 목록 조회
     */
    public List<MarketItem> findLatestItems(int limit) {
        List<MarketItem> list = new ArrayList<>();

        String sql = "SELECT * FROM market_item " +
                     "ORDER BY created_at DESC " +
                     "LIMIT ?";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, limit);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    MarketItem item = mapRow(rs);
                    list.add(item);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    // 필요시 상세보기용
    public MarketItem findById(long id) {
        String sql = "SELECT * FROM market_item WHERE id = ?";
        MarketItem item = null;

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setLong(1, id);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    item = mapRow(rs);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        return item;
    }

    // ResultSet → MarketItem 매핑 공통 함수
    private MarketItem mapRow(ResultSet rs) throws SQLException {
        MarketItem item = new MarketItem();
        item.setId(rs.getLong("id"));
        item.setTitle(rs.getString("title"));
        item.setCategory(rs.getString("category"));
        item.setPrice(rs.getInt("price"));
        item.setStatus(rs.getString("status"));
        item.setCampus(rs.getString("campus"));
        item.setMeetingPlace(rs.getString("meeting_place"));
        item.setMeetingTime(rs.getString("meeting_time"));
        item.setTradeType(rs.getString("trade_type"));
        item.setWishCount(rs.getInt("wish_count"));
        item.setChatCount(rs.getInt("chat_count"));
        item.setThumbnailUrl(rs.getString("thumbnail_url"));
        item.setDescription(rs.getString("description"));

        int writer = rs.getInt("writer_id");
        if (!rs.wasNull()) {
            item.setWriterId(writer);
        }

        return item;
    }
}
