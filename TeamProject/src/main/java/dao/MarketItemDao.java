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
            pstmt.setString(4, item.getStatus());
            pstmt.setString(5, item.getCampus());
            pstmt.setString(6, item.getMeetingPlace());
            pstmt.setString(7, item.getMeetingTime());
            pstmt.setString(8, item.getTradeType());
            pstmt.setInt(9, item.getWishCount());
            pstmt.setInt(10, item.getChatCount());
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
     * 검색/필터/정렬 목록 조회
     */
    public List<MarketItem> findByFilter(
            String keyword,
            String category,
            String campus,
            String tradeType,
            String sort,
            int limit
    ) {
        List<MarketItem> list = new ArrayList<>();

        StringBuilder sb = new StringBuilder("SELECT * FROM market_item WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.trim().isEmpty()) {
            sb.append(" AND (title LIKE ? OR description LIKE ?)");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
        }

        if (category != null && !category.trim().isEmpty()
                && !"ALL".equalsIgnoreCase(category)
                && !"전체 카테고리".equals(category)) {
            sb.append(" AND category = ?");
            params.add(category);
        }

        if (campus != null && !campus.trim().isEmpty()
                && !"ALL".equalsIgnoreCase(campus)
                && !"전체 캠퍼스".equals(campus)) {
            sb.append(" AND campus = ?");
            params.add(campus);
        }

        if (tradeType != null && !tradeType.trim().isEmpty()
                && !"ALL".equalsIgnoreCase(tradeType)
                && !"거래 방식 전체".equals(tradeType)) {
            sb.append(" AND trade_type = ?");
            params.add(tradeType);
        }

        String orderBy = "created_at DESC";
        if (sort != null) {
            switch (sort) {
                case "price_asc":  orderBy = "price ASC"; break;
                case "price_desc": orderBy = "price DESC"; break;
                case "wish_desc":  orderBy = "wish_count DESC, created_at DESC"; break;
                default:           orderBy = "created_at DESC";
            }
        }
        sb.append(" ORDER BY ").append(orderBy);
        sb.append(" LIMIT ?");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sb.toString())) {

            int idx = 1;
            for (Object p : params) {
                if (p instanceof String) pstmt.setString(idx++, (String)p);
                else if (p instanceof Integer) pstmt.setInt(idx++, (Integer)p);
                else if (p instanceof Long) pstmt.setLong(idx++, (Long)p);
            }
            pstmt.setInt(idx, limit);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

        return list;
    }

    /**
     * 상세조회
     */
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

    /**
     * 글 수정
     * 썸네일이 null이면 썸네일은 수정하지 않음
     */
    public boolean update(MarketItem item) {
        StringBuilder sb = new StringBuilder(
                "UPDATE market_item SET " +
                        "title=?, category=?, price=?, campus=?, " +
                        "meeting_place=?, meeting_time=?, trade_type=?, " +
                        "description=?, status=?"
        );

        if (item.getThumbnailUrl() != null) {
            sb.append(", thumbnail_url=?");
        }
        sb.append(" WHERE id=? AND writer_id=?");

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sb.toString())) {

            int idx = 1;
            pstmt.setString(idx++, item.getTitle());
            pstmt.setString(idx++, item.getCategory());
            pstmt.setInt(idx++, item.getPrice());
            pstmt.setString(idx++, item.getCampus());
            pstmt.setString(idx++, item.getMeetingPlace());
            pstmt.setString(idx++, item.getMeetingTime());
            pstmt.setString(idx++, item.getTradeType());
            pstmt.setString(idx++, item.getDescription());
            pstmt.setString(idx++, item.getStatus());

            if (item.getThumbnailUrl() != null) {
                pstmt.setString(idx++, item.getThumbnailUrl());
            }

            pstmt.setLong(idx++, item.getId());
            pstmt.setInt(idx, item.getWriterId());

            int affected = pstmt.executeUpdate();
            return affected > 0;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 삭제 (작성자 본인만)
     */
    public boolean delete(long id, int writerId) {
        String sql = "DELETE FROM market_item WHERE id=? AND writer_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            pstmt.setInt(2, writerId);
            int affected = pstmt.executeUpdate();
            return affected > 0;
        } catch (Exception e){
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 상태 변경 (판매중 / 예약중 / 거래완료)
     */
    public boolean updateStatus(long id, int writerId, String status) {
        String sql = "UPDATE market_item SET status=? WHERE id=? AND writer_id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setLong(2, id);
            pstmt.setInt(3, writerId);
            int affected = pstmt.executeUpdate();
            return affected > 0;
        } catch (Exception e){
            e.printStackTrace();
            return false;
        }
    }

    /**
     * 찜 카운트 +1
     */
    public void increaseWishCount(long id) {
        String sql = "UPDATE market_item SET wish_count = wish_count + 1 WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            pstmt.executeUpdate();
        } catch (Exception e){
            e.printStackTrace();
        }
    }

    /**
     * 채팅 카운트 +1
     */
    public void increaseChatCount(long id) {
        String sql = "UPDATE market_item SET chat_count = chat_count + 1 WHERE id=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setLong(1, id);
            pstmt.executeUpdate();
        } catch (Exception e){
            e.printStackTrace();
        }
    }

    /**
     * 특정 유저의 판매글 목록
     */
    public List<MarketItem> findByWriter(int writerId) {
        List<MarketItem> list = new ArrayList<>();
        String sql = "SELECT * FROM market_item WHERE writer_id = ? ORDER BY created_at DESC";

        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, writerId);

            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * 나의 거래현황 (상태별 개수)
     */
    public int countByWriterAndStatus(int writerId, String status) {
        String sql = "SELECT COUNT(*) FROM market_item WHERE writer_id=? AND status=?";
        try (Connection conn = DBUtil.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, writerId);
            pstmt.setString(2, status);

            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }

        } catch (Exception e){
            e.printStackTrace();
        }
        return 0;
    }

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
        if (!rs.wasNull()) item.setWriterId(writer);

        return item;
    }
}
