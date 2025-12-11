<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.MarketItemDao" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String idStr = request.getParameter("id");
    long id = 0;
    try { id = Long.parseLong(idStr); } catch(Exception e){}

    if (id > 0) {
        MarketItemDao dao = new MarketItemDao();
        dao.increaseChatCount(id);
    }

    // 실제 채팅 기능은 나중에, 일단 카운트만 올리고 상세페이지로
    response.sendRedirect(ctx + "/market/marketView.jsp?id=" + id);
%>
