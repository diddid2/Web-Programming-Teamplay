<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.MarketItemDao, dao.MarketChatDao, dto.MarketItem" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String userId = (String) session.getAttribute("userId");
    Integer memberNo = (Integer) session.getAttribute("memberNo");
    request.setAttribute("currentMenu", "market");

    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='" + ctx + "/login.jsp';</script>");
        return;
    }

    // memberNo 보정
    if (memberNo == null) {
        try (java.sql.Connection conn = util.DBUtil.getConnection();
             java.sql.PreparedStatement ps = conn.prepareStatement("SELECT MEMBER_NO FROM MEMBER WHERE USER_ID=?")) {
            ps.setString(1, userId);
            try (java.sql.ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    memberNo = rs.getInt("MEMBER_NO");
                    session.setAttribute("memberNo", memberNo);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    String itemIdStr = request.getParameter("itemId");
    long itemId = 0;
    try { itemId = Long.parseLong(itemIdStr); } catch(Exception e) {}

    if (itemId <= 0 || memberNo == null) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='" + ctx + "/market/marketMain.jsp';</script>");
        return;
    }

    MarketItemDao itemDao = new MarketItemDao();
    MarketItem item = itemDao.findById(itemId);
    if (item == null) {
        out.println("<script>alert('상품을 찾을 수 없습니다.'); location.href='" + ctx + "/market/marketMain.jsp';</script>");
        return;
    }

    if (item.getWriterId() == null) {
        out.println("<script>alert('작성자 정보가 없어 채팅을 시작할 수 없습니다.'); history.back();</script>");
        return;
    }

    int sellerId = item.getWriterId();
    int buyerId = memberNo;

    if (buyerId == sellerId) {
        out.println("<script>alert('내가 올린 글에는 채팅을 시작할 수 없어요.'); location.href='" + ctx + "/market/marketView.jsp?id=" + itemId + "';</script>");
        return;
    }

    MarketChatDao chatDao = new MarketChatDao();
    long existingRoomId = chatDao.findRoomId(itemId, buyerId);

    long roomId = existingRoomId;
    if (roomId <= 0) {
        roomId = chatDao.getOrCreateRoom(itemId, sellerId, buyerId);
        if (roomId > 0) {
            // 채팅방이 새로 생성된 경우만 카운트 증가
            itemDao.increaseChatCount(itemId);
        }
    }

    if (roomId <= 0) {
        out.println("<script>alert('채팅방 생성 중 오류가 발생했습니다.'); history.back();</script>");
        return;
    }

    response.sendRedirect(ctx + "/market/chatRoom.jsp?roomId=" + roomId);
%>
