<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, dao.MarketCartDao, dto.CartItem" %>
<%!
    String thumbSrc(String ctx, String raw) {
        if (raw == null) return null;
        String s = raw.trim();
        if (s.isEmpty()) return null;
        if (s.startsWith("http://") || s.startsWith("https://")) return s;
        if (s.startsWith(ctx + "/")) return s;
        if (s.startsWith("/")) return ctx + s;
        return ctx + "/" + s;
    }
%>
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

    if (memberNo == null) {
        out.println("<script>alert('회원 정보를 확인할 수 없습니다.'); location.href='" + ctx + "/main.jsp';</script>");
        return;
    }

    MarketCartDao cartDao = new MarketCartDao();
    List<CartItem> all = cartDao.listCart(memberNo);

    List<CartItem> instant = new ArrayList<>();
    long sum = 0;

    if (all != null) {
        for (CartItem ci : all) {
            if (!"IMMEDIATE".equalsIgnoreCase(ci.getCartType())) continue;
            instant.add(ci);
            sum += (long) ci.getPrice() * (long) ci.getQuantity();
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>장바구니 - 강남마켓</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <style>
        body { margin:0; background:#0b1220; color:#e5e7eb; font-family: system-ui, -apple-system, "Noto Sans KR", sans-serif; }
        main { max-width: 980px; margin: 0 auto; padding: 18px 14px 34px; }
        h1 { margin: 12px 0 6px; font-size: 20px; }
        .sub { color:#94a3b8; font-size: 12px; margin-bottom: 14px; }
        .card { border-radius: 18px; border:1px solid rgba(55,65,81,.9); background: rgba(2,6,23,.85); padding: 14px; }
        .card-head { display:flex; justify-content:space-between; align-items:flex-end; gap:10px; flex-wrap:wrap; }
        .title { font-weight: 900; font-size: 14px; }
        .muted { color:#94a3b8; font-size: 12px; margin-top:4px; }
        .btn { border:none; border-radius: 999px; padding: 8px 12px; cursor:pointer; background: rgba(148,163,184,.12); color:#e5e7eb; }
        .btn:hover { filter: brightness(1.08); }
        .btn-blue { background:#2563eb; }
        .btn-red { background: rgba(239,68,68,.18); border:1px solid rgba(239,68,68,.35); }
        .btn-disabled { opacity: .55; cursor: not-allowed; }
        .list { margin-top: 12px; display:flex; flex-direction:column; gap:10px; }
        .row { display:flex; align-items:center; justify-content:space-between; gap: 12px; padding: 12px; border-radius: 16px; border:1px solid rgba(55,65,81,.9); background: rgba(2,6,23,.70); }
        .left { display:flex; gap:10px; align-items:center; min-width:0; }
        .thumb { width: 54px; height: 54px; border-radius: 14px; overflow:hidden; background: rgba(148,163,184,.12); display:flex; align-items:center; justify-content:center; flex: 0 0 auto; }
        .thumb img { width:100%; height:100%; object-fit:cover; }
        .meta { min-width:0; }
        .name { font-weight: 800; font-size: 13px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .info { color:#94a3b8; font-size: 12px; margin-top: 3px; }
        .right { display:flex; align-items:center; gap: 10px; flex: 0 0 auto; }
        .price { font-weight: 900; color:#fbbf24; font-size: 14px; text-align:right; min-width: 90px; }
        .qty { font-size: 12px; color:#94a3b8; text-align:right; }
        .empty { padding: 18px 12px; border-radius: 14px; border:1px dashed rgba(148,163,184,.25); color:#94a3b8; text-align:center; }
        .footer-actions { margin-top: 14px; display:flex; justify-content:space-between; gap:10px; flex-wrap:wrap; }
        @media (max-width: 560px) {
            .row { align-items:flex-start; }
            .right { flex-direction:column; align-items:flex-end; gap:6px; }
        }
    </style>
</head>
<body>
<jsp:include page="../common/gnb.jsp"/>
<main>
    <h1>장바구니</h1>
    <div class="sub">바로구매(즉시구매) 상품만 담을 수 있어요. 상품당 수량은 1개입니다.</div>

    <section class="card">
        <div class="card-head">
            <div>
                <div class="title">바로구매 장바구니</div>
                <div class="muted">구매하면 담긴 상품들은 모두 거래완료로 전환되고, 채팅방에 진행상황 UI가 자동으로 전송돼요.</div>
            </div>
            <div style="display:flex; gap:8px; align-items:center;">
                <div class="price"><%= String.format("%,d원", sum) %></div>
                <form method="post" action="<%=ctx%>/market/cartClearProc.jsp" style="margin:0;">
                    <input type="hidden" name="cartType" value="IMMEDIATE"/>
                    <button type="submit" class="btn btn-red" onclick="return confirm('장바구니를 비울까요?');">비우기</button>
                </form>
            </div>
        </div>

        <div class="list">
            <% if (instant.isEmpty()) { %>
                <div class="empty">담긴 상품이 없습니다.</div>
            <% } else {
                   for (CartItem ci : instant) {
                       String src = thumbSrc(ctx, ci.getThumbnailUrl());
            %>
                <div class="row">
                    <div class="left">
                        <div class="thumb">
                            <% if (src != null) { %><img src="<%=src%>" alt="thumb"/><% } else { %>🛍️<% } %>
                        </div>
                        <div class="meta">
                            <div class="name">
                                <a href="<%=ctx%>/market/marketView.jsp?id=<%=ci.getItemId()%>" style="color:#e5e7eb; text-decoration:none;">
                                    <%=ci.getTitle()%>
                                </a>
                            </div>
                            <div class="info"><%=ci.getCampus()%> · 수량 <%=ci.getQuantity()%></div>
                        </div>
                    </div>
                    <div class="right">
                        <div>
                            <div class="price"><%= String.format("%,d원", (long)ci.getPrice() * ci.getQuantity()) %></div>
                            <div class="qty"><%= String.format("%,d원", ci.getPrice()) %> × <%=ci.getQuantity()%></div>
                        </div>
                        <form method="post" action="<%=ctx%>/market/cartRemoveProc.jsp" style="margin:0;">
                            <input type="hidden" name="cartId" value="<%=ci.getCartId()%>"/>
                            <button type="submit" class="btn btn-red" onclick="return confirm('장바구니에서 삭제할까요?');">삭제</button>
                        </form>
                    </div>
                </div>
            <%     }
               } %>
        </div>
    </section>

    <div class="footer-actions">
        <button class="btn" onclick="location.href='<%=ctx%>/market/marketMain.jsp'">계속 둘러보기</button>

        <button class="btn btn-blue <%= instant.isEmpty() ? "btn-disabled" : "" %>"
                <%= instant.isEmpty() ? "disabled" : "" %>
                onclick="if(!this.disabled) location.href='<%=ctx%>/market/cartCheckout.jsp'">
            구매하기
        </button>
    </div>
</main>
</body>
</html>
