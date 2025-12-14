<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.MarketCartDao" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String userId = (String) session.getAttribute("userId");
    Integer memberNo = (Integer) session.getAttribute("memberNo");

    if (userId == null || memberNo == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='" + ctx + "/login.jsp';</script>");
        return;
    }

    String cartType = request.getParameter("cartType");
    if (cartType == null) cartType = "IMMEDIATE";
    cartType = cartType.trim().toUpperCase();

    if (!"IMMEDIATE".equals(cartType) && !"DELIVERY".equals(cartType)) {
        out.println("<script>alert('잘못된 요청입니다.'); history.back();</script>");
        return;
    }

    MarketCartDao dao = new MarketCartDao();
    dao.clearCart(memberNo, cartType);

    response.sendRedirect(ctx + "/market/cart.jsp");
%>
