<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.MarketOrderDao, dao.MarketChatDao, dto.MarketOrder" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String userId = (String) session.getAttribute("userId");
    Integer memberNo = (Integer) session.getAttribute("memberNo");

    if (userId == null || memberNo == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='" + ctx + "/login.jsp';</script>");
        return;
    }

    long roomId = 0;
    long orderId = 0;
    try { roomId = Long.parseLong(request.getParameter("roomId")); } catch (Exception ignored) {}
    try { orderId = Long.parseLong(request.getParameter("orderId")); } catch (Exception ignored) {}

    String carrier = request.getParameter("carrier");
    String trackingNumber = request.getParameter("trackingNumber");
    if (carrier != null) carrier = carrier.trim();
    if (trackingNumber != null) trackingNumber = trackingNumber.trim();

    if (roomId <= 0 || orderId <= 0 || carrier == null || carrier.isEmpty() || trackingNumber == null || trackingNumber.isEmpty()) {
        out.println("<script>alert('송장 정보를 확인해주세요.'); history.back();</script>");
        return;
    }

    MarketOrderDao orderDao = new MarketOrderDao();
    MarketOrder order = orderDao.findByRoom(roomId);
    if (order == null || order.getOrderId() != orderId) {
        out.println("<script>alert('주문 정보를 찾을 수 없습니다.'); location.href='" + ctx + "/market/chatRoom.jsp?roomId=" + roomId + "';</script>");
        return;
    }

    if (order.getSellerId() != memberNo.intValue()) {
        out.println("<script>alert('판매자만 송장 등록이 가능합니다.'); location.href='" + ctx + "/market/chatRoom.jsp?roomId=" + roomId + "';</script>");
        return;
    }

    boolean ok = orderDao.setTracking(orderId, memberNo, carrier, trackingNumber);
    if (!ok) {
        out.println("<script>alert('송장 등록에 실패했습니다.'); location.href='" + ctx + "/market/chatRoom.jsp?roomId=" + roomId + "';</script>");
        return;
    }

    // 채팅방에 시스템 메시지로 진행상황 UI 전송
    MarketChatDao chatDao = new MarketChatDao();
    if (chatDao.isParticipant(roomId, memberNo)) {
        chatDao.insertMessage(roomId, null,
                "🚚 [배송시작] 송장이 등록되었습니다. (" + carrier + " / " + trackingNumber + ")",
                "SYSTEM");
    }

    out.println("<script>alert('송장번호가 등록되었습니다.'); location.href='" + ctx + "/market/chatRoom.jsp?roomId=" + roomId + "';</script>");
%>
