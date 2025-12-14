<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.MarketCartDao, dao.MarketItemDao, dto.MarketItem" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String userId = (String) session.getAttribute("userId");
    Integer memberNo = (Integer) session.getAttribute("memberNo");

    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='" + ctx + "/login.jsp';</script>");
        return;
    }

    
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

    long itemId = 0;
    try { itemId = Long.parseLong(request.getParameter("itemId")); } catch(Exception ignore) {}

    if (memberNo == null || itemId <= 0) {
        out.println("<script>alert('잘못된 요청입니다.'); history.back();</script>");
        return;
    }

    
    String cartType = "IMMEDIATE";

    MarketItemDao itemDao = new MarketItemDao();
    MarketItem item = itemDao.findById(itemId);
    if (item == null) {
        out.println("<script>alert('상품을 찾을 수 없습니다.'); location.href='" + ctx + "/market/marketMain.jsp';</script>");
        return;
    }

    
    if (item.getWriterId() != null && item.getWriterId().intValue() == memberNo.intValue()) {
        out.println("<script>alert('내가 올린 상품은 장바구니에 담을 수 없어요.'); location.href='" + ctx + "/market/marketView.jsp?id=" + itemId + "';</script>");
        return;
    }

    
    if (!item.isInstantBuy()) {
        out.println("<script>alert('바로구매 상품만 장바구니에 담을 수 있어요.'); location.href='" + ctx + "/market/marketView.jsp?id=" + itemId + "';</script>");
        return;
    }

    
    if (item.getStatus() != null && !"ON_SALE".equalsIgnoreCase(item.getStatus())) {
        out.println("<script>alert('판매중인 상품만 담을 수 있습니다.'); location.href='" + ctx + "/market/marketView.jsp?id=" + itemId + "';</script>");
        return;
    }

    
    String tradeType = (item.getTradeType() == null) ? "" : item.getTradeType().toUpperCase();
    boolean allowDelivery = "DELIVERY".equals(tradeType) || "BOTH".equals(tradeType);
    if (!allowDelivery) {
        out.println("<script>alert('바로구매는 택배(또는 직거래+택배) 상품만 가능합니다.'); location.href='" + ctx + "/market/marketView.jsp?id=" + itemId + "';</script>");
        return;
    }

    MarketCartDao cartDao = new MarketCartDao();
    boolean ok = cartDao.addToCart(memberNo, itemId, cartType);

    if (!ok) {
        out.println("<script>alert('장바구니 담기에 실패했습니다.'); history.back();</script>");
        return;
    }

    response.sendRedirect(ctx + "/market/cart.jsp");
%>
