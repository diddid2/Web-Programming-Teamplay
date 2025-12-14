<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, dao.MarketChatDao, dto.ChatRoom" %>
<%!
    public String thumbSrc(String ctx, String raw) {
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
    request.setAttribute("currentMenu", "chat");

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
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    MarketChatDao dao = new MarketChatDao();
    List<ChatRoom> rooms = (memberNo != null) ? dao.listRoomsByUser(memberNo) : new ArrayList<>();

    SimpleDateFormat sdf = new SimpleDateFormat("MM/dd HH:mm");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>채팅 내역 - 강남마켓</title>
    <style>
        body { margin:0; background:#0b1220; color:#e5e7eb; font-family: system-ui, -apple-system, "Noto Sans KR", sans-serif; }
        main { max-width: 920px; margin: 0 auto; padding: 18px 14px 32px; }
        .title-row { display:flex; align-items:flex-end; justify-content:space-between; gap:12px; margin: 10px 0 14px; }
        h1 { margin:0; font-size: 20px; letter-spacing:-.2px; }
        .sub { color:#94a3b8; font-size: 12px; }
        .list { display:flex; flex-direction:column; gap:10px; }
        .card {
            display:flex; gap:12px; align-items:center;
            padding: 12px; border-radius: 16px;
            border: 1px solid rgba(55,65,81,.9);
            background: rgba(2, 6, 23, .85);
            cursor:pointer;
            transition: transform .08s ease, border-color .12s ease;
        }
        .card:hover { transform: translateY(-1px); border-color: rgba(96,165,250,.55); }
        .thumb { width:62px; height:62px; border-radius: 14px; overflow:hidden; background: rgba(148,163,184,.15); flex:0 0 auto; display:flex; align-items:center; justify-content:center; }
        .thumb img { width:100%; height:100%; object-fit:cover; }
        .meta { flex:1; min-width: 0; }
        .row1 { display:flex; align-items:center; justify-content:space-between; gap:10px; }
        .item-title { font-size: 14px; font-weight: 700; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .time { font-size: 11px; color:#94a3b8; flex:0 0 auto; }
        .row2 { margin-top:4px; display:flex; align-items:center; justify-content:space-between; gap:10px; }
        .preview { font-size: 12px; color:#cbd5e1; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .chips { display:flex; gap:6px; align-items:center; flex:0 0 auto; }
        .chip { font-size: 11px; padding: 4px 8px; border-radius: 999px; border:1px solid rgba(148,163,184,.25); color:#cbd5e1; background: rgba(148,163,184,.08); }
        .chip-green { background: rgba(22,163,74,.20); border-color: rgba(22,163,74,.35); color:#bbf7d0; }
        .chip-yellow { background: rgba(234,179,8,.20); border-color: rgba(234,179,8,.35); color:#fde68a; }
        .chip-gray { background: rgba(107,114,128,.20); border-color: rgba(107,114,128,.35); color:#e5e7eb; }
        .chip-red { background: rgba(239,68,68,.18); border-color: rgba(239,68,68,.35); color:#fecaca; }
        .empty { padding: 22px 14px; border-radius: 16px; border:1px dashed rgba(148,163,184,.25); color:#94a3b8; text-align:center; }
        .btn {
            border:none; border-radius: 999px; padding: 10px 14px;
            background:#2563eb; color:white; font-weight: 700; cursor:pointer;
        }
        .btn:hover { filter: brightness(1.05); }
    </style>
</head>
<body>
<jsp:include page="../common/gnb.jsp"/>
<main>
    <div class="title-row">
        <div>
            <h1>채팅 내역</h1>
            <div class="sub">강남마켓에서 생성된 채팅방 목록이에요.</div>
        </div>
        <button class="btn" onclick="location.href='<%=ctx%>/market/marketMain.jsp'">강남마켓 가기</button>
    </div>

    <div class="list">
        <% if (rooms == null || rooms.isEmpty()) { %>
            <div class="empty">아직 채팅이 없어요. 상품 상세에서 “채팅으로 거래하기”를 눌러 시작해보세요.</div>
        <% } else { 
               for (ChatRoom r : rooms) {
                   String status = (r.getItemStatus() == null) ? "ON_SALE" : r.getItemStatus();
                   String chipClass = "chip-green";
                   String statusLabel = "판매중";
                   if ("RESERVED".equalsIgnoreCase(status)) { chipClass = "chip-yellow"; statusLabel = "예약중"; }
                   else if ("SOLD_OUT".equalsIgnoreCase(status)) { chipClass = "chip-gray"; statusLabel = "거래완료"; }

                   String otherName = (memberNo != null) ? r.getOtherUserName(memberNo) : "";
                   String lastMsg = (r.getLastMessage() == null || r.getLastMessage().trim().isEmpty()) ? "대화를 시작해보세요!" : r.getLastMessage();
                   String timeStr = (r.getLastMessageAt() != null) ? sdf.format(r.getLastMessageAt()) : "";
        %>
            <div class="card" onclick="location.href='<%=ctx%>/market/chatRoom.jsp?roomId=<%=r.getRoomId()%>'">
                <div class="thumb">
                    <% if (r.getItemThumbnailUrl() != null && !r.getItemThumbnailUrl().trim().isEmpty()) { %>
                        <% String src = thumbSrc(ctx, r.getItemThumbnailUrl()); %>
                                <% if (src != null) { %><img src="<%=src%>" alt="thumb"/><% } %>
                    <% } else { %>
                        🛍️
                    <% } %>
                </div>
                <div class="meta">
                    <div class="row1">
                        <div class="item-title"><%= r.getItemTitle() %> <span style="color:#94a3b8; font-weight:600;">· <%= otherName %></span></div>
                        <div class="time"><%= timeStr %></div>
                    </div>
                    <div class="row2">
                        <div class="preview"><%= lastMsg %></div>
                        <div class="chips">
                            <% if (r.getUnreadCount() > 0) { %>
                                <span class="chip chip-red">안읽음 <%= r.getUnreadCount() > 99 ? "99+" : r.getUnreadCount() %></span>
                            <% } %>
                            <span class="chip <%=chipClass%>"><%=statusLabel%></span>
                            <span class="chip"><%= String.format("%,d", r.getItemPrice()) %>원</span>
                        </div>
                    </div>
                </div>
            </div>
        <%     } 
           } %>
    </div>
</main>
</body>
</html>
