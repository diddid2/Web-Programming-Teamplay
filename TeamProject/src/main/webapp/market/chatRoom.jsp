<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, java.net.URLEncoder, dao.MarketChatDao, dao.MarketItemDao, dao.MarketOrderDao, dto.ChatRoom, dto.ChatMessage, dto.MarketOrder" %>
<%!
public String esc(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;")
                .replace("<","&lt;")
                .replace(">","&gt;")
                .replace("\"","&quot;")
                .replace("'","&#39;");
    }

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
        } catch (Exception e) { e.printStackTrace(); }
    }

    String roomIdStr = request.getParameter("roomId");
    long roomId = 0;
    try { roomId = Long.parseLong(roomIdStr); } catch(Exception e) {}

    if (roomId <= 0 || memberNo == null) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='" + ctx + "/market/chatList.jsp';</script>");
        return;
    }

    MarketChatDao chatDao = new MarketChatDao();
    if (!chatDao.isParticipant(roomId, memberNo)) {
        out.println("<script>alert('접근 권한이 없습니다.'); location.href='" + ctx + "/market/chatList.jsp';</script>");
        return;
    }

    ChatRoom room = chatDao.getRoomDetail(roomId);
    if (room == null) {
        out.println("<script>alert('채팅방을 찾을 수 없습니다.'); location.href='" + ctx + "/market/chatList.jsp';</script>");
        return;
    }

    List<ChatMessage> messages = chatDao.listMessages(roomId, 0, 100);

    SimpleDateFormat timeFmt = new SimpleDateFormat("HH:mm");
    SimpleDateFormat dateFmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");

    String status = (room.getItemStatus() == null) ? "ON_SALE" : room.getItemStatus();
    String statusLabel = "판매중";
    String statusStyle = "background: rgba(22, 163, 74, 0.18); border-color: rgba(22,163,74,.35); color:#bbf7d0;";
    if ("RESERVED".equalsIgnoreCase(status)) {
        statusLabel = "예약중";
        statusStyle = "background: rgba(234, 179, 8, 0.18); border-color: rgba(234,179,8,.35); color:#fde68a;";
    } else if ("SOLD_OUT".equalsIgnoreCase(status)) {
        statusLabel = "거래완료";
        statusStyle = "background: rgba(107,114,128,0.18); border-color: rgba(107,114,128,.35); color:#e5e7eb;";
    }

    boolean isSeller = room.isSeller(memberNo);

    // 즉시구매(택배) 주문이 존재하면, 채팅 상단에 진행상황 UI를 띄웁니다.
    MarketOrderDao orderDao = new MarketOrderDao();
    MarketOrder order = orderDao.findByRoom(roomId);
    boolean hasOrder = (order != null);
    boolean shipped = hasOrder && order.getTrackingNumber() != null && !order.getTrackingNumber().trim().isEmpty();

    String trackingUrl = null;
    if (shipped) {
        try {
            String q = (order.getCarrier() == null ? "택배" : order.getCarrier()) + " " + order.getTrackingNumber() + " 배송조회";
            trackingUrl = "https://search.naver.com/search.naver?query=" + URLEncoder.encode(q, "UTF-8");
        } catch(Exception ignore) {}
    }

    long lastMsgId = 0;
    if (messages != null && !messages.isEmpty()) lastMsgId = messages.get(messages.size()-1).getMsgId();
    // 초기 진입 시점에 읽음 처리
    if (lastMsgId > 0) chatDao.markRead(roomId, memberNo, lastMsgId);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>채팅 - 강남마켓</title>
    <style>
        body { margin:0; background:#0b1220; color:#e5e7eb; font-family: system-ui, -apple-system, "Noto Sans KR", sans-serif; }
        .wrap { max-width: 920px; margin: 0 auto; padding: 0 14px 22px; }
        .header-card {
            margin-top: 14px;
            padding: 12px 12px;
            border-radius: 16px;
            border: 1px solid rgba(55,65,81,.9);
            background: rgba(2,6,23,.85);
            display:flex; gap:12px; align-items:center; justify-content:space-between;
        }
        .left { display:flex; gap:12px; align-items:center; min-width:0; }
        .thumb { width:44px; height:44px; border-radius: 12px; overflow:hidden; background: rgba(148,163,184,.15); display:flex; align-items:center; justify-content:center; flex:0 0 auto; }
        .thumb img { width:100%; height:100%; object-fit:cover; }
        .title { font-weight: 800; font-size: 14px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis; }
        .sub { color:#94a3b8; font-size: 12px; margin-top:2px; }
        .chip { font-size: 11px; padding: 4px 8px; border-radius: 999px; border: 1px solid rgba(148,163,184,.25); }
        .btn {
            border:none; border-radius: 999px; padding: 9px 12px; cursor:pointer;
            background: rgba(148,163,184,.12); color:#e5e7eb;
        }
        .btn:hover { filter: brightness(1.08); }
        .chatbox {
            margin-top: 10px;
            border-radius: 16px;
            border: 1px solid rgba(55,65,81,.9);
            background: rgba(2,6,23,.72);
            height: calc(100vh - 290px);
            min-height: 380px;
            overflow: auto;
            padding: 14px 12px;
        }
        .msg-row { display:flex; margin: 10px 0; gap:8px; }
        .msg-row.me { justify-content:flex-end; }
        .sys-row { display:flex; justify-content:center; margin: 14px 0; }
        .sys-badge {
            max-width: 92%;
            text-align:center;
            padding: 8px 12px;
            border-radius: 999px;
            background: rgba(148,163,184,.10);
            border: 1px solid rgba(148,163,184,.18);
            color:#cbd5e1;
            font-size: 12px;
            line-height: 1.35;
            white-space: pre-wrap;
            word-break: break-word;
        }
        .bubble {
            max-width: 76%;
            padding: 10px 12px;
            border-radius: 14px;
            background: rgba(148,163,184,.10);
            border: 1px solid rgba(148,163,184,.18);
            line-height: 1.35;
            white-space: pre-wrap;
            word-break: break-word;
            font-size: 13px;
        }
        .me .bubble {
            background: rgba(37,99,235,.18);
            border-color: rgba(37,99,235,.30);
        }
        .meta { font-size: 11px; color:#94a3b8; margin-top: 4px; }
        .composer {
            margin-top: 10px;
            display:flex; gap:10px;
            padding: 12px;
            border-radius: 16px;
            border: 1px solid rgba(55,65,81,.9);
            background: rgba(2,6,23,.85);
        }
        textarea {
            flex:1; resize:none; height: 48px;
            border-radius: 14px; border: 1px solid rgba(148,163,184,.18);
            background: rgba(15,23,42,.75);
            color:#e5e7eb;
            padding: 10px 12px;
            outline:none;
            font-family: inherit;
        }
        .send {
            border:none; border-radius: 14px; padding: 0 16px;
            background:#2563eb; color:white; font-weight: 800; cursor:pointer;
        }
        .send:hover { filter: brightness(1.05); }
        .status-form select {
            border-radius: 999px; padding: 8px 10px;
            background: rgba(15,23,42,.75);
            border:1px solid rgba(148,163,184,.18);
            color:#e5e7eb;
        }
        .status-form button {
            margin-left: 6px;
            border:none; border-radius: 999px; padding: 8px 10px;
            background: rgba(148,163,184,.12); color:#e5e7eb; cursor:pointer;
        }
        .status-form button:hover { filter: brightness(1.08); }

        .order-card {
            margin-top: 10px;
            padding: 12px;
            border-radius: 16px;
            border: 1px solid rgba(55,65,81,.9);
            background: rgba(2,6,23,.85);
        }
        .order-head { display:flex; justify-content:space-between; align-items:flex-end; gap:10px; flex-wrap:wrap; }
        .order-title { font-weight:900; font-size: 14px; }
        .order-sub { color:#94a3b8; font-size: 12px; margin-top:4px; }
        .order-grid { display:grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-top: 10px; }
        @media (max-width: 640px) { .order-grid { grid-template-columns: 1fr; } }
        .kv { padding: 10px 12px; border-radius: 14px; border: 1px solid rgba(148,163,184,.18); background: rgba(15,23,42,.55); }
        .k { color:#94a3b8; font-size: 11px; }
        .v { color:#e5e7eb; font-size: 12px; margin-top: 4px; white-space: pre-wrap; word-break: break-word; }
        .order-actions { display:flex; gap:8px; margin-top: 10px; flex-wrap:wrap; justify-content:flex-end; }
        .order-actions input, .order-actions select {
            border-radius: 999px; padding: 8px 10px;
            background: rgba(15,23,42,.75);
            border:1px solid rgba(148,163,184,.18);
            color:#e5e7eb;
        }
        .order-actions .small { border-radius: 999px; padding: 8px 10px; border:none; cursor:pointer; background:#2563eb; color:white; font-weight: 800; }
        .order-actions .small:hover { filter: brightness(1.05); }
    </style>
</head>
<body>
<jsp:include page="../common/gnb.jsp"/>

<div class="wrap">
    <div class="header-card">
        <div class="left">
            <div class="thumb">
                <% if (room.getItemThumbnailUrl() != null && !room.getItemThumbnailUrl().trim().isEmpty()) { %>
                    <% String src = thumbSrc(ctx, room.getItemThumbnailUrl()); %>
                    <% if (src != null) { %><img src="<%=src%>" alt="thumb"/><% } %>
                <% } else { %>🛍️<% } %>
            </div>
            <div style="min-width:0;">
                <div class="title"><%= esc(room.getItemTitle()) %></div>
                <div class="sub">
                    상대: <strong><%= esc(room.getOtherUserName(memberNo)) %></strong>
                    · <a href="<%=ctx%>/market/marketView.jsp?id=<%=room.getItemId()%>" style="color:#93c5fd; text-decoration:none;">상품 보기</a>
                </div>
            </div>
        </div>

        <div style="display:flex; align-items:center; gap:8px;">
            <span class="chip" style="<%=statusStyle%>"><%=statusLabel%></span>
            <button class="btn" onclick="location.href='<%=ctx%>/market/chatList.jsp'">목록</button>
        </div>
    </div>

    <% if (isSeller) { %>
        <div style="margin-top:10px;">
            <form class="status-form" method="post" action="<%=ctx%>/market/marketStatusProc.jsp">
                <input type="hidden" name="itemId" value="<%=room.getItemId()%>"/>
                <input type="hidden" name="roomId" value="<%=room.getRoomId()%>"/>
                <select name="status">
                    <option value="ON_SALE"  <%= "ON_SALE".equalsIgnoreCase(status) ? "selected" : "" %>>판매중</option>
                    <option value="RESERVED" <%= "RESERVED".equalsIgnoreCase(status) ? "selected" : "" %>>예약중</option>
                    <option value="SOLD_OUT" <%= "SOLD_OUT".equalsIgnoreCase(status) ? "selected" : "" %>>거래완료</option>
                </select>
                <button type="submit">거래상태 변경</button>
            </form>
        </div>
    <% } %>

    <% if (hasOrder) { %>
        <div class="order-card">
            <div class="order-head">
                <div>
                    <div class="order-title">즉시구매 주문 진행상황</div>
                    <div class="order-sub">
                        상태: <strong><%= shipped ? "배송중" : "결제완료 · 송장입력대기" %></strong>
                        · 주문번호: <strong>#<%= order.getOrderId() %></strong>
                    </div>
                </div>
                <div style="font-weight:900; color:#fbbf24;">
                    <%= String.format("%,d원", order.getPrice()) %>
                </div>
            </div>

            <div class="order-grid">
                <div class="kv">
                    <div class="k">배송지</div>
                    <div class="v"><%= esc(order.getRecipientName()) %> · <%= esc(order.getPhone()) %>
<%= esc(order.getPostcode()) %> <%= esc(order.getAddress1()) %> <%= esc(order.getAddress2()) %>
<% if (order.getMemo() != null && !order.getMemo().trim().isEmpty()) { %>메모: <%= esc(order.getMemo()) %><% } %></div>
                </div>
                <div class="kv">
                    <div class="k">송장/배송조회</div>
                    <div class="v">
                        <% if (shipped) { %>
                            <%= esc(order.getCarrier() != null ? order.getCarrier() : "택배") %> · <strong><%= esc(order.getTrackingNumber()) %></strong>
                        <% } else { %>
                            판매자가 송장번호를 입력하면 배송조회가 가능해요.
                        <% } %>
                    </div>
                </div>
            </div>

            <% if (isSeller && !shipped) { %>
                <form class="order-actions" method="post" action="<%=ctx%>/market/orderTrackingProc.jsp">
                    <input type="hidden" name="roomId" value="<%=room.getRoomId()%>"/>
                    <input type="hidden" name="orderId" value="<%=order.getOrderId()%>"/>
                    <select name="carrier" required>
                        <option value="CJ대한통운">CJ대한통운</option>
                        <option value="우체국택배">우체국택배</option>
                        <option value="한진택배">한진택배</option>
                        <option value="로젠택배">로젠택배</option>
                        <option value="롯데택배">롯데택배</option>
                        <option value="기타">기타</option>
                    </select>
                    <input type="text" name="trackingNumber" placeholder="송장번호" required maxlength="100"/>
                    <button type="submit" class="small">송장 등록</button>
                </form>
            <% } else if (!isSeller && shipped && trackingUrl != null) { %>
                <div class="order-actions">
                    <button type="button" class="small" onclick="window.open('<%=trackingUrl%>','_blank')">배송조회</button>
                </div>
            <% } %>
        </div>
    <% } %>

    <div class="chatbox" id="chatbox">
        <% if (messages != null) {
               for (ChatMessage m : messages) {
                   boolean system = "SYSTEM".equalsIgnoreCase(m.getMessageType());
                   boolean me = (!system && m.getSenderId() != null && m.getSenderId().intValue() == memberNo.intValue());
        %>
            <% if (system) { %>
                <div class="sys-row" data-msgid="<%=m.getMsgId()%>">
                    <div class="sys-badge"><%= esc(m.getMessage()) %></div>
                </div>
            <% } else { %>
                <div class="msg-row <%= me ? "me" : "" %>" data-msgid="<%=m.getMsgId()%>">
                    <div>
                        <div class="bubble"><%= esc(m.getMessage()) %></div>
                        <div class="meta"><%= timeFmt.format(m.getCreatedAt()) %></div>
                    </div>
                </div>
            <% } %>
        <%     }
           } %>
    </div>

    <form class="composer" method="post" action="<%=ctx%>/market/chatSendProc.jsp">
        <input type="hidden" name="roomId" value="<%=room.getRoomId()%>"/>
        <textarea name="message" placeholder="메시지를 입력하세요" maxlength="2000"></textarea>
        <button class="send" type="submit">전송</button>
    </form>
</div>

<script>
	const me = <%= memberNo %>;
	let lastMsgId = <%= lastMsgId %>;
	
	const chatbox = document.getElementById('chatbox');
	
	function isNearBottom() {
	    return (chatbox.scrollHeight - chatbox.scrollTop - chatbox.clientHeight) < 80;
	}
	function scrollToBottom() {
	    chatbox.scrollTop = chatbox.scrollHeight;
	}
	scrollToBottom();
	
	let stopped = false;
	
	function appendMessages(data) {
	    if (!Array.isArray(data) || data.length === 0) return;
	
	    const autoScroll = isNearBottom();
	
	    for (const m of data) {
	        const isSystem = (m.messageType || 'USER') === 'SYSTEM';
	        if (isSystem) {
	            const row = document.createElement('div');
	            row.className = 'sys-row';
	            row.dataset.msgid = m.msgId;
	            const badge = document.createElement('div');
	            badge.className = 'sys-badge';
	            badge.textContent = m.message || '';
	            row.appendChild(badge);
	            chatbox.appendChild(row);
	        } else {
	            const row = document.createElement('div');
	            row.className = 'msg-row ' + (m.senderId === me ? 'me' : '');
	            row.dataset.msgid = m.msgId;
	
	            const inner = document.createElement('div');
	
	            const bubble = document.createElement('div');
	            bubble.className = 'bubble';
	            bubble.textContent = m.message || '';
	
	            const meta = document.createElement('div');
	            meta.className = 'meta';
	            meta.textContent = m.time || '';
	
	            inner.appendChild(bubble);
	            inner.appendChild(meta);
	            row.appendChild(inner);
	            chatbox.appendChild(row);
	        }

	        lastMsgId = Math.max(lastMsgId, m.msgId);
	    }
	
	    if (autoScroll) scrollToBottom();
	}
	
	async function longPoll() {
	    while (!stopped) {
	        try {
	            // wait=1 : 서버가 새 메시지 생길 때까지(최대 25초) 기다렸다가 응답
	            const url = "<%=ctx%>/market/chatMessages.jsp"
	                      + "?roomId=<%=room.getRoomId()%>"
	                      + "&after=" + lastMsgId
	                      + "&wait=1"
	                      + "&t=" + Date.now(); // 캐시 방지
	
	            const res = await fetch(url, { cache: "no-store" });
	            if (!res.ok) continue;
	
	            const data = await res.json();
	            appendMessages(data);
	        } catch (e) {
	            // 네트워크 순간 끊김 대비: 잠깐 쉬고 재연결
	            await new Promise(r => setTimeout(r, 800));
	        }
	    }
	}
	
	window.addEventListener("beforeunload", () => { stopped = true; });
	longPoll();

</script>
</body>
</html>
