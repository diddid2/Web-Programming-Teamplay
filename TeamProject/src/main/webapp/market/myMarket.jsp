<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, dao.MarketItemDao, dto.MarketItem" %>
<%!
String label(String s) {
        if ("RESERVED".equalsIgnoreCase(s)) return "예약중";
        if ("SOLD_OUT".equalsIgnoreCase(s)) return "거래완료";
        return "판매중";
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

    String filter = request.getParameter("status");
    if (filter == null || filter.trim().isEmpty()) filter = "ALL";

    MarketItemDao dao = new MarketItemDao();
    List<MarketItem> all = dao.findByWriter(memberNo);

    int cntSale = dao.countByWriterAndStatus(memberNo, "ON_SALE");
    int cntRes  = dao.countByWriterAndStatus(memberNo, "RESERVED");
    int cntSold = dao.countByWriterAndStatus(memberNo, "SOLD_OUT");

    List<MarketItem> items = new ArrayList<>();
    if (all != null) {
        for (MarketItem it : all) {
            if ("ALL".equals(filter) || (it.getStatus() != null && it.getStatus().equalsIgnoreCase(filter))) {
                items.add(it);
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>내 거래현황 - 강남마켓</title>
    <style>
        body { margin:0; background:#0b1220; color:#e5e7eb; font-family: system-ui, -apple-system, "Noto Sans KR", sans-serif; }
        main { max-width: 980px; margin: 0 auto; padding: 18px 14px 32px; }
        .top { display:flex; align-items:flex-end; justify-content:space-between; gap: 12px; margin: 10px 0 14px; }
        h1 { margin:0; font-size: 20px; }
        .sub { color:#94a3b8; font-size: 12px; margin-top:4px; }
        .cards { display:grid; grid-template-columns: repeat(3, 1fr); gap: 10px; margin-top: 12px; }
        .card { border-radius: 16px; border:1px solid rgba(55,65,81,.9); background: rgba(2,6,23,.85); padding: 12px; }
        .k { color:#94a3b8; font-size: 12px; }
        .v { font-size: 22px; font-weight: 900; margin-top:4px; }
        .filters { margin-top: 14px; display:flex; gap:8px; flex-wrap:wrap; }
        .pill { padding: 8px 12px; border-radius: 999px; border: 1px solid rgba(148,163,184,.25); background: rgba(148,163,184,.08); color:#e5e7eb; text-decoration:none; font-size: 12px; }
        .pill.active { border-color: rgba(96,165,250,.55); background: rgba(37,99,235,.15); }
        .list { margin-top: 12px; display:flex; flex-direction:column; gap:10px; }
        .row { display:flex; align-items:center; justify-content:space-between; gap: 12px; padding: 12px; border-radius: 16px; border:1px solid rgba(55,65,81,.9); background: rgba(2,6,23,.80); }
        .l { min-width:0; }
        .title { font-weight: 800; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .meta { color:#94a3b8; font-size: 12px; margin-top:4px; }
        .actions { display:flex; gap:8px; align-items:center; }
        select { padding: 8px 10px; border-radius: 999px; border:1px solid rgba(148,163,184,.18); background: rgba(15,23,42,.75); color:#e5e7eb; }
        button { padding: 8px 10px; border-radius: 999px; border:none; background: rgba(148,163,184,.12); color:#e5e7eb; cursor:pointer; }
        button:hover { filter: brightness(1.08); }
        .btn-blue { background:#2563eb; }
        .empty { padding: 22px 14px; border-radius: 16px; border:1px dashed rgba(148,163,184,.25); color:#94a3b8; text-align:center; }
        @media (max-width: 760px) { .cards { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
<jsp:include page="../common/gnb.jsp"/>
<main>
    <div class="top">
        <div>
            <h1>내 거래현황</h1>
            <div class="sub">내가 올린 상품들의 판매/예약/완료 상태를 관리할 수 있어요.</div>
        </div>
        <div style="display:flex; gap:8px;">
            <button class="btn-blue" onclick="location.href='<%=ctx%>/market/marketWrite.jsp'">글쓰기</button>
            <button onclick="location.href='<%=ctx%>/market/marketMain.jsp'">목록</button>
        </div>
    </div>

    <div class="cards">
        <div class="card"><div class="k">판매중</div><div class="v"><%=cntSale%></div></div>
        <div class="card"><div class="k">예약중</div><div class="v"><%=cntRes%></div></div>
        <div class="card"><div class="k">거래완료</div><div class="v"><%=cntSold%></div></div>
    </div>

    <div class="filters">
        <a class="pill <%= "ALL".equals(filter) ? "active" : "" %>" href="<%=ctx%>/market/myMarket.jsp?status=ALL">전체</a>
        <a class="pill <%= "ON_SALE".equalsIgnoreCase(filter) ? "active" : "" %>" href="<%=ctx%>/market/myMarket.jsp?status=ON_SALE">판매중</a>
        <a class="pill <%= "RESERVED".equalsIgnoreCase(filter) ? "active" : "" %>" href="<%=ctx%>/market/myMarket.jsp?status=RESERVED">예약중</a>
        <a class="pill <%= "SOLD_OUT".equalsIgnoreCase(filter) ? "active" : "" %>" href="<%=ctx%>/market/myMarket.jsp?status=SOLD_OUT">거래완료</a>
    </div>

    <div class="list">
        <% if (items == null || items.isEmpty()) { %>
            <div class="empty">표시할 상품이 없습니다.</div>
        <% } else {
               for (MarketItem it : items) { %>
            <div class="row">
                <div class="l">
                    <div class="title"><a href="<%=ctx%>/market/marketView.jsp?id=<%=it.getId()%>" style="color:#e5e7eb; text-decoration:none;"><%=it.getTitle()%></a></div>
                    <div class="meta"><%= label(it.getStatus()) %> · <%= String.format("%,d", it.getPrice()) %>원 · 채팅 <%=it.getChatCount()%> · 찜 <%=it.getWishCount()%></div>
                </div>
                <div class="actions">
                    <form method="post" action="<%=ctx%>/market/marketStatusProc.jsp" style="margin:0; display:flex; gap:6px; align-items:center;">
                        <input type="hidden" name="itemId" value="<%=it.getId()%>"/>
                        <select name="status">
                            <option value="ON_SALE"  <%= "ON_SALE".equalsIgnoreCase(it.getStatus()) ? "selected" : "" %>>판매중</option>
                            <option value="RESERVED" <%= "RESERVED".equalsIgnoreCase(it.getStatus()) ? "selected" : "" %>>예약중</option>
                            <option value="SOLD_OUT" <%= "SOLD_OUT".equalsIgnoreCase(it.getStatus()) ? "selected" : "" %>>거래완료</option>
                        </select>
                        <button type="submit">변경</button>
                    </form>
                </div>
            </div>
        <%     }
           } %>
    </div>
</main>
</body>
</html>
