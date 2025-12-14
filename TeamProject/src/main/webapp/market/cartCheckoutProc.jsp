<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, dao.MarketOrderDao, dto.BuyerAddress" %>
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

    if (memberNo == null) {
        out.println("<script>alert('회원 정보를 확인할 수 없습니다.'); location.href='" + ctx + "/main.jsp';</script>");
        return;
    }

    
    String recipientName = request.getParameter("recipientName");
    String phone = request.getParameter("phone");
    String postcode = request.getParameter("postcode");
    String address1 = request.getParameter("address1");
    String address2 = request.getParameter("address2");
    String memo = request.getParameter("memo");

    if (recipientName != null) recipientName = recipientName.trim();
    if (phone != null) phone = phone.trim();
    if (postcode != null) postcode = postcode.trim();
    if (address1 != null) address1 = address1.trim();
    if (address2 != null) address2 = address2.trim();
    if (memo != null) memo = memo.trim();

    if (recipientName == null || recipientName.isEmpty()
            || phone == null || phone.isEmpty()
            || postcode == null || postcode.isEmpty()
            || address1 == null || address1.isEmpty()) {
        out.println("<script>alert('배송지 정보를 모두 입력해주세요.'); location.href='" + ctx + "/market/cartCheckout.jsp';</script>");
        return;
    }

    try {
        MarketOrderDao orderDao = new MarketOrderDao();
        BuyerAddress addr = new BuyerAddress();
        addr.setBuyerId(memberNo);
        addr.setRecipientName(recipientName);
        addr.setPhone(phone);
        addr.setPostcode(postcode);
        addr.setAddress1(address1);
        addr.setAddress2(address2);
        addr.setMemo(memo);

        List<Long> roomIds = orderDao.checkoutInstantCart(memberNo, addr);

        if (roomIds == null || roomIds.isEmpty()) {
            out.println("<script>alert('구매할 상품이 없습니다.'); location.href='" + ctx + "/market/cart.jsp';</script>");
            return;
        }

        if (roomIds.size() == 1) {
            long roomId = roomIds.get(0);
            out.println("<script>alert('구매가 완료되었습니다!'); location.href='" + ctx + "/market/chatRoom.jsp?roomId=" + roomId + "';</script>");
        } else {
            out.println("<script>alert('구매가 완료되었습니다!'); location.href='" + ctx + "/market/chatList.jsp';</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('구매 처리 중 오류가 발생했습니다.'); location.href='" + ctx + "/market/cart.jsp';</script>");
    }
%>
