<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, dao.MarketItemDao, dto.MarketItem" %>
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
    request.setAttribute("currentMenu", "market");

    String userId = (String) session.getAttribute("userId");
    Integer memberNo = (Integer) session.getAttribute("memberNo");

    // memberNo 보정(로그인한 경우)
    if (userId != null && memberNo == null) {
        try (Connection conn = util.DBUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement("SELECT MEMBER_NO FROM MEMBER WHERE USER_ID=?")) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    memberNo = rs.getInt("MEMBER_NO");
                    session.setAttribute("memberNo", memberNo);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }
    }

    long itemId = 0;
    try { itemId = Long.parseLong(request.getParameter("id")); } catch (Exception e) {}

    if (itemId <= 0) {
        out.println("<script>alert('잘못된 접근입니다.');location.href='" + ctx + "/market/marketMain.jsp';</script>");
        return;
    }

    MarketItemDao dao = new MarketItemDao();
    MarketItem item = dao.findById(itemId);

    if (item == null) {
        out.println("<script>alert('상품 정보를 찾을 수 없습니다.');location.href='" + ctx + "/market/marketMain.jsp';</script>");
        return;
    }

    boolean isOwner = (memberNo != null && item.getWriterId() != null && memberNo.intValue() == item.getWriterId().intValue());

    String status = (item.getStatus() == null) ? "ON_SALE" : item.getStatus();
    String statusLabel = "판매중";
    String statusStyle = "background: rgba(22, 163, 74, 0.15); border-color: rgba(22,163,74,.35); color:#bbf7d0;";
    if ("RESERVED".equalsIgnoreCase(status)) {
        statusLabel = "예약중";
        statusStyle = "background: rgba(234, 179, 8, 0.16); border-color: rgba(234,179,8,.35); color:#fde68a;";
    } else if ("SOLD_OUT".equalsIgnoreCase(status)) {
        statusLabel = "거래완료";
        statusStyle = "background: rgba(107,114,128,0.16); border-color: rgba(107,114,128,.35); color:#e5e7eb;";
    }

    String tradeType = (item.getTradeType() == null) ? "" : item.getTradeType().toUpperCase();
    boolean allowDelivery = "DELIVERY".equals(tradeType) || "BOTH".equals(tradeType);
    boolean canInstantBuy = item.isInstantBuy() && allowDelivery && "ON_SALE".equalsIgnoreCase(status);

    String imgSrc = thumbSrc(ctx, item.getThumbnailUrl());
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>상품 상세 - 강남마켓</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        * { box-sizing: border-box; }
        body { margin:0; background:#050816; color:#e5e7eb; font-family: "Noto Sans KR", system-ui, -apple-system, BlinkMacSystemFont, sans-serif; }
        a { color: inherit; text-decoration: none; }
        .wrap { max-width: 1080px; margin: 0 auto; padding: 18px 16px 44px; }
        .topbar { margin-top: 10px; display:flex; justify-content:space-between; align-items:center; gap: 10px; }
        .back {
            display:inline-flex; align-items:center; gap:8px;
            padding: 10px 12px;
            border-radius: 999px;
            border: 1px solid rgba(148,163,184,.25);
            background: rgba(15,23,42,.75);
            color:#e5e7eb;
            font-size: 13px;
        }
        .back:hover { border-color: rgba(96,165,250,.6); }
        .actions { display:flex; gap:8px; flex-wrap:wrap; justify-content:flex-end; }
        .btn {
            border:none;
            border-radius: 999px;
            padding: 10px 12px;
            cursor:pointer;
            font-size: 13px;
            color:#e5e7eb;
            background: rgba(148,163,184,.12);
            border: 1px solid rgba(148,163,184,.20);
            transition: transform .08s ease, filter .15s ease, border-color .15s ease;
        }
        .btn:hover { filter: brightness(1.08); border-color: rgba(96,165,250,.55); transform: translateY(-1px); }
        .btn-primary {
            background: linear-gradient(135deg, #2563eb, #38bdf8);
            border: none;
            color: #f9fafb;
            font-weight: 700;
        }
        .btn-danger {
            background: rgba(239,68,68,.15);
            border-color: rgba(239,68,68,.35);
        }
        .btn-warning {
            background: rgba(251,191,36,.18);
            border-color: rgba(251,191,36,.35);
            color: #fef3c7;
        }
        .card {
            margin-top: 14px;
            background: radial-gradient(circle at top left, rgba(56, 189, 248, 0.10), rgba(15, 23, 42, 0.98));
            border-radius: 24px;
            border: 1px solid rgba(148, 163, 184, 0.16);
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.85);
            overflow: hidden;
        }
        .grid {
            display:grid;
            grid-template-columns: 380px 1fr;
            gap: 0;
        }
        .thumb {
            background: linear-gradient(135deg, #1f2937, #020617);
            min-height: 340px;
            display:flex; align-items:center; justify-content:center;
        }
        .thumb img { width:100%; height:100%; object-fit:cover; display:block; }
        .thumb .noimg { color:#9ca3af; font-size: 13px; }
        .content { padding: 18px 18px 20px; }
        .chips { display:flex; gap:8px; flex-wrap:wrap; align-items:center; }
        .chip {
            font-size: 12px;
            padding: 6px 10px;
            border-radius: 999px;
            border: 1px solid rgba(148,163,184,.25);
            background: rgba(2,6,23,.45);
            color:#cbd5e1;
        }
        .chip-status { border-width: 1px; }
        h1 { margin: 10px 0 8px; font-size: 22px; line-height: 1.25; }
        .price { font-size: 22px; font-weight: 900; color:#fbbf24; }
        .meta {
            margin-top: 14px;
            display:grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 10px;
        }
        .meta .box {
            padding: 12px 12px;
            border-radius: 16px;
            border: 1px solid rgba(148,163,184,.16);
            background: rgba(2,6,23,.38);
        }
        .meta .k { font-size: 11px; color:#94a3b8; }
        .meta .v { margin-top: 4px; font-size: 13px; font-weight: 600; color:#e5e7eb; }
        .desc {
            margin-top: 14px;
            padding: 14px 14px;
            border-radius: 18px;
            border: 1px solid rgba(148,163,184,.14);
            background: rgba(2,6,23,.35);
            color:#e5e7eb;
            line-height: 1.6;
            white-space: pre-wrap;
            word-break: break-word;
            font-size: 13px;
        }
        .desc .empty { color:#94a3b8; }
        @media (max-width: 980px) {
            .grid { grid-template-columns: 1fr; }
            .thumb { min-height: 240px; }
        }
    </style>
</head>
<body>
<jsp:include page="../common/gnb.jsp"/>

<main class="wrap">
    <div class="topbar">
        <a class="back" href="<%=ctx%>/market/marketMain.jsp">← 목록으로</a>

        <div class="actions">
            <% if (isOwner) { %>
                <button class="btn" onclick="location.href='<%=ctx%>/market/marketWrite.jsp?itemId=<%=item.getId()%>'">수정</button>
                <form method="post" action="<%=ctx%>/market/delete" style="margin:0;">
                    <input type="hidden" name="itemId" value="<%=item.getId()%>"/>
                    <button type="submit" class="btn btn-danger" onclick="return confirm('정말 삭제할까요? (복구 불가)');">삭제</button>
                </form>
            <% } else { %>
                <button class="btn btn-primary" onclick="location.href='<%=ctx%>/market/chatStart.jsp?itemId=<%=item.getId()%>'">채팅으로 거래하기</button>

                <% if (canInstantBuy) { %>
                    <form method="post" action="<%=ctx%>/market/cartAddProc.jsp" style="margin:0;">
                        <input type="hidden" name="itemId" value="<%=item.getId()%>"/>
                        <input type="hidden" name="cartType" value="IMMEDIATE"/>
                        <button type="submit" class="btn btn-warning">바로구매 담기</button>
                    </form>
                <% } %>

                <button class="btn" onclick="location.href='<%=ctx%>/market/cart.jsp'">장바구니</button>
            <% } %>
        </div>
    </div>

    <section class="card">
        <div class="grid">
            <div class="thumb">
                <% if (imgSrc != null) { %>
                    <img src="<%=imgSrc%>" alt="상품 이미지"/>
                <% } else { %>
                    <div class="noimg">이미지 없음</div>
                <% } %>
            </div>

            <div class="content">
                <div class="chips">
                    <span class="chip"><%= esc(item.getCategory()) %></span>
                    <span class="chip chip-status" style="<%=statusStyle%>"><%=statusLabel%></span>
                <% if (item.isInstantBuy()) { %>
                    <span class="chip" style="border-color: rgba(34,197,94,.40); background: rgba(34,197,94,.12); color:#a7f3d0;">바로구매 가능</span>
                <% } %>
                    <span class="chip">찜 <%=item.getWishCount()%> · 채팅 <%=item.getChatCount()%></span>
                </div>

                <h1><%= esc(item.getTitle()) %></h1>
                <div class="price"><%= String.format("%,d원", item.getPrice()) %></div>

                <div class="meta">
                    <div class="box">
                        <div class="k">캠퍼스/위치</div>
                        <div class="v"><%= esc(item.getCampus()) %></div>
                    </div>
                    <div class="box">
                        <div class="k">거래 방식</div>
                        <div class="v">
                            <%
                                if ("DIRECT".equalsIgnoreCase(item.getTradeType())) out.print("직거래");
                                else if ("DELIVERY".equalsIgnoreCase(item.getTradeType())) out.print("택배");
                                else out.print("직거래+택배");
                            %>
                        </div>
                    </div>

                    <div class="box">
                        <div class="k">거래 장소</div>
                        <div class="v"><%= (item.getMeetingPlace() != null && !item.getMeetingPlace().trim().isEmpty()) ? esc(item.getMeetingPlace()) : "미정" %></div>
                    </div>
                    <div class="box">
                        <div class="k">선호 시간</div>
                        <div class="v"><%= (item.getMeetingTime() != null && !item.getMeetingTime().trim().isEmpty()) ? esc(item.getMeetingTime()) : "미정" %></div>
                    </div>
                </div>

                <div class="desc">
                    <% if (item.getDescription() != null && !item.getDescription().trim().isEmpty()) { %>
                        <%= esc(item.getDescription()) %>
                    <% } else { %>
                        <span class="empty">상세 설명이 없습니다.</span>
                    <% } %>
                </div>
            </div>
        </div>
    </section>
</main>

</body>
</html>
