<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.MarketItemDao" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String userId = (String) session.getAttribute("userId");
    Integer memberNo = (Integer) session.getAttribute("memberNo");

    if (userId == null || memberNo == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='" + ctx + "/login.jsp';</script>");
        return;
    }

    long itemId = 0;
    try { itemId = Long.parseLong(request.getParameter("itemId")); } catch(Exception e) {}

    String status = request.getParameter("status");
    if (status == null) status = "ON_SALE";

    String roomIdStr = request.getParameter("roomId");
    long roomId = 0;
    try { roomId = Long.parseLong(roomIdStr); } catch(Exception ignore) {}

    if (itemId <= 0) {
        out.println("<script>alert('잘못된 요청입니다.'); history.back();</script>");
        return;
    }

    MarketItemDao dao = new MarketItemDao();
    boolean ok = dao.updateStatus(itemId, memberNo, status);

    if (!ok) {
        out.println("<script>alert('거래 상태 변경에 실패했습니다. (작성자만 변경 가능)'); history.back();</script>");
        return;
    }

    if (roomId > 0) response.sendRedirect(ctx + "/market/chatRoom.jsp?roomId=" + roomId);
    else response.sendRedirect(ctx + "/market/marketView.jsp?id=" + itemId);
%>
