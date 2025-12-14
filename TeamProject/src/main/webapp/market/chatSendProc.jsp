<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.MarketChatDao" %>
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
    try { roomId = Long.parseLong(request.getParameter("roomId")); } catch(Exception e) {}

    String msg = request.getParameter("message");
    if (msg != null) msg = msg.trim();

    if (roomId <= 0) {
        out.println("<script>alert('잘못된 요청입니다.'); history.back();</script>");
        return;
    }

    MarketChatDao dao = new MarketChatDao();
    if (!dao.isParticipant(roomId, memberNo)) {
        out.println("<script>alert('접근 권한이 없습니다.'); location.href='" + ctx + "/market/chatList.jsp';</script>");
        return;
    }

    if (msg == null || msg.isEmpty()) {
        response.sendRedirect(ctx + "/market/chatRoom.jsp?roomId=" + roomId);
        return;
    }

    dao.insertMessage(roomId, memberNo, msg);

    response.sendRedirect(ctx + "/market/chatRoom.jsp?roomId=" + roomId);
%>
