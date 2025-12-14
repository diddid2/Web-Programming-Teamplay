<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, dao.MarketCartDao, dao.MarketOrderDao, dto.CartItem, dto.BuyerAddress" %>
<%!
    String esc(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;")
                .replace("<","&lt;")
                .replace(">","&gt;")
                .replace("\"","&quot;")
                .replace("'","&#39;");
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

    if (instant.isEmpty()) {
        out.println("<script>alert('구매할 상품이 없습니다.'); location.href='" + ctx + "/market/cart.jsp';</script>");
        return;
    }

    MarketOrderDao orderDao = new MarketOrderDao();
    BuyerAddress def = orderDao.getBuyerDefaultAddress(memberNo);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title>배송지 입력 - 강남마켓</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <style>
        body { margin:0; background:#0b1220; color:#e5e7eb; font-family: system-ui, -apple-system, "Noto Sans KR", sans-serif; }
        main { max-width: 980px; margin: 0 auto; padding: 18px 14px 34px; }
        h1 { margin: 12px 0 6px; font-size: 20px; }
        .sub { color:#94a3b8; font-size: 12px; margin-bottom: 14px; }
        .grid { display:grid; grid-template-columns: 1.2fr .8fr; gap: 12px; }
        @media (max-width: 860px) { .grid { grid-template-columns: 1fr; } }
        .card { border-radius: 18px; border:1px solid rgba(55,65,81,.9); background: rgba(2,6,23,.85); padding: 14px; }
        .title { font-weight: 900; font-size: 14px; }
        .muted { color:#94a3b8; font-size: 12px; margin-top:4px; }
        .line { height:1px; background: rgba(148,163,184,.12); margin: 12px 0; }
        .row { display:flex; justify-content:space-between; gap:10px; padding: 8px 0; }
        .row span { color:#94a3b8; font-size: 12px; }
        .row strong { color:#e5e7eb; font-size: 12px; }
        label { display:block; font-size: 12px; color:#94a3b8; margin: 10px 0 6px; }
        input, textarea {
            width: 100%;
            border-radius: 14px;
            border: 1px solid rgba(148,163,184,.18);
            background: rgba(15,23,42,.75);
            color:#e5e7eb;
            padding: 10px 12px;
            outline:none;
            font-family: inherit;
            box-sizing:border-box;
        }
        textarea { min-height: 72px; resize: vertical; }
        .two { display:grid; grid-template-columns: 1fr 1fr; gap: 10px; }
        @media (max-width: 520px) { .two { grid-template-columns: 1fr; } }
        .btn { border:none; border-radius: 999px; padding: 10px 14px; cursor:pointer; background: rgba(148,163,184,.12); color:#e5e7eb; }
        .btn:hover { filter: brightness(1.08); }
        .btn-blue { background:#2563eb; }
        .actions { margin-top: 12px; display:flex; gap: 10px; justify-content:flex-end; flex-wrap:wrap; }
        .warn { color:#fbbf24; font-size: 12px; margin-top: 8px; }
    </style>
</head>
<body>
<jsp:include page="../common/gnb.jsp"/>

<main>
    <h1>배송지 입력</h1>
    <div class="sub">즉시구매는 택배거래만 가능해요. 입력한 배송지는 다음 구매 시 자동으로 기본값으로 불러옵니다.</div>

    <div class="grid">
        <section class="card">
            <div class="title">받는 사람 정보</div>
            <div class="muted">연락처/주소는 판매자에게 배송 목적으로만 공유됩니다.</div>

            <form method="post" action="<%=ctx%>/market/cartCheckoutProc.jsp" style="margin-top:10px;">
                <label>받는 분</label>
                <input type="text" name="recipientName" maxlength="50" required
                       value="<%= esc(def != null ? def.getRecipientName() : "") %>"/>

                <label>연락처</label>
                <input type="text" name="phone" maxlength="20" required placeholder="010-1234-5678"
                       value="<%= esc(def != null ? def.getPhone() : "") %>"/>

                <div class="two">
                    <div>
                        <label>우편번호</label>
                        <div style="display:flex; gap:8px; align-items:center;">
                            <input id="postcode" type="text" name="postcode" maxlength="10" required readonly
                                   value="<%= esc(def != null ? def.getPostcode() : "") %>"/>
                            <button type="button" class="btn" style="white-space:nowrap;" onclick="openPostcodePopup()">우편번호 검색</button>
                        </div>
                    </div>
                    <div>
                        <label>상세주소</label>
                        <input id="address2" type="text" name="address2" maxlength="255" placeholder="동/호수 등"
                               value="<%= esc(def != null ? def.getAddress2() : "") %>"/>
                    </div>
                </div>

                <label>기본주소</label>
                <input id="address1" type="text" name="address1" maxlength="255" required placeholder="도로명/지번 주소" readonly
                       value="<%= esc(def != null ? def.getAddress1() : "") %>"/>

                <label>배송 메모 (선택)</label>
                <textarea name="memo" maxlength="255" placeholder="부재 시 문 앞에 두세요 등"><%= esc(def != null ? def.getMemo() : "") %></textarea>

                <div class="warn">※ 결제 완료 후에는 해당 상품들이 즉시 거래완료로 전환됩니다.</div>

                <div class="actions">
                    <button type="button" class="btn" onclick="location.href='<%=ctx%>/market/cart.jsp'">뒤로</button>
                    <button type="submit" class="btn btn-blue">결제(구매) 완료하기</button>
                </div>
            </form>
        </section>

        <aside class="card">
            <div class="title">주문 요약</div>
            <div class="muted">장바구니에 담긴 즉시구매 상품 <%= instant.size() %>개</div>
            <div class="line"></div>
            <% for (CartItem ci : instant) { %>
                <div class="row">
                    <span><%= esc(ci.getTitle()) %></span>
                    <strong><%= String.format("%,d원", ci.getPrice()) %></strong>
                </div>
            <% } %>
            <div class="line"></div>
            <div class="row">
                <span>총 결제금액</span>
                <strong style="color:#fbbf24;"><%= String.format("%,d원", sum) %></strong>
            </div>
        </aside>
    </div>
</main>

<script>
    function openPostcodePopup() {
        window.open(
            "<%=ctx%>/market/postcodePopup.jsp",
            "postcodePop",
            "width=500,height=650,scrollbars=yes,resizable=yes"
        );
    }

    // postcodePopup.jsp에서 호출
    function setCheckoutAddress(data) {
        document.getElementById("postcode").value = data.postcode || "";
        document.getElementById("address1").value = data.address1 || "";
        var a2 = document.getElementById("address2");
        if (a2) a2.focus();
    }
</script>
</body>
</html>
