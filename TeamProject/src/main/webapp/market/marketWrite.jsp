<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, dao.MarketItemDao, dto.MarketItem" %>
<%!
    public String escAttr(String s) {
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

    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='" + ctx + "/login.jsp';</script>");
        return;
    }

    
    if (memberNo == null) {
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

    if (memberNo == null) {
        out.println("<script>alert('회원 정보를 확인할 수 없습니다.'); location.href='" + ctx + "/main.jsp';</script>");
        return;
    }

    
    boolean editMode = false;
    long editItemId = 0;
    MarketItem editItem = null;

    String editIdStr = request.getParameter("itemId");
    if (editIdStr != null && !editIdStr.trim().isEmpty()) {
        try { editItemId = Long.parseLong(editIdStr.trim()); } catch(Exception ignore) {}
        if (editItemId > 0) {
            MarketItemDao dao = new MarketItemDao();
            editItem = dao.findById(editItemId);
            if (editItem == null) {
                out.println("<script>alert('상품을 찾을 수 없습니다.'); location.href='" + ctx + "/market/marketMain.jsp';</script>");
                return;
            }
            if (editItem.getWriterId() == null || editItem.getWriterId().intValue() != memberNo.intValue()) {
                out.println("<script>alert('수정 권한이 없습니다.'); location.href='" + ctx + "/market/marketView.jsp?id=" + editItemId + "';</script>");
                return;
            }
            editMode = true;
        }
    }

    String pageTitle = editMode ? "상품 수정" : "상품 등록";
    String actionUrl = editMode ? (ctx + "/market/update") : (ctx + "/market/write?id=" + memberNo);

    String vTitle = editMode ? escAttr(editItem.getTitle()) : "";
    String vCategory = editMode ? escAttr(editItem.getCategory()) : "교재 · 전공책";
    String vPrice = editMode ? String.valueOf(editItem.getPrice()) : "";
    String vCampus = editMode ? escAttr(editItem.getCampus()) : "강남대 정문";
    String vMeetingPlace = editMode ? escAttr(editItem.getMeetingPlace()) : "";
    String vMeetingTime = editMode ? escAttr(editItem.getMeetingTime()) : "";
    String vTradeType = editMode ? escAttr(editItem.getTradeType()) : "DIRECT";
    String vDesc = editMode ? escAttr(editItem.getDescription()) : "";
    String vStatus = editMode ? ((editItem.getStatus()==null || editItem.getStatus().trim().isEmpty()) ? "ON_SALE" : escAttr(editItem.getStatus())) : "ON_SALE";
    boolean vInstantBuy = editMode && editItem != null && editItem.isInstantBuy();
    String thumb = editMode ? editItem.getThumbnailUrl() : null;
    String thumbUrl = editMode ? thumbSrc(ctx, thumb) : null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8"/>
    <title><%=pageTitle%> - 강남마켓</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <style>
        * { box-sizing: border-box; }
        body { margin:0; background:#050816; color:#e5e7eb; font-family: "Noto Sans KR", system-ui, -apple-system, BlinkMacSystemFont, sans-serif; }
        main { max-width: 980px; margin: 0 auto; padding: 18px 16px 44px; }
        .top {
            margin-top: 10px;
            display:flex;
            align-items:flex-end;
            justify-content:space-between;
            gap: 10px;
        }
        h1 { margin:0; font-size: 20px; }
        .sub { color:#94a3b8; font-size: 12px; margin-top: 6px; }
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
            font-weight: 800;
        }
        .btn-danger {
            background: rgba(239,68,68,.15);
            border-color: rgba(239,68,68,.35);
        }
        .card {
            margin-top: 14px;
            background: radial-gradient(circle at top left, rgba(56, 189, 248, 0.10), rgba(15, 23, 42, 0.98));
            border-radius: 24px;
            border: 1px solid rgba(148, 163, 184, 0.16);
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.85);
            padding: 18px;
        }
        .grid { display:grid; grid-template-columns: 1fr 300px; gap: 14px; }
        label { display:block; font-size: 12px; color:#cbd5e1; margin: 12px 0 6px; }
        input, select, textarea {
            width: 100%;
            padding: 12px 12px;
            border-radius: 14px;
            border: 1px solid rgba(148,163,184,.18);
            background: rgba(2,6,23,.55);
            color:#e5e7eb;
            outline: none;
            font-family: inherit;
            font-size: 13px;
        }
        textarea { min-height: 140px; resize: vertical; }
        .row2 { display:grid; grid-template-columns: 1fr 1fr; gap: 10px; }
        .help { margin-top: 6px; color:#94a3b8; font-size: 11px; }
        .toggle-row{ margin-top:12px; padding:12px 12px; border-radius: 16px; border: 1px solid rgba(148,163,184,.16); background: rgba(2,6,23,.38); display:flex; align-items:center; justify-content:space-between; gap:12px; }
        .toggle-row .t-title{ font-size:13px; font-weight:800; }
        .toggle-row .t-desc{ font-size:11px; color:#94a3b8; margin-top:4px; }
        .switch{ position:relative; width:48px; height:28px; }
        .switch input{ display:none; }
        .slider{ position:absolute; cursor:pointer; top:0; left:0; right:0; bottom:0; background: rgba(148,163,184,.22); border:1px solid rgba(148,163,184,.25); border-radius:999px; transition: .2s; }
        .slider:before{ position:absolute; content:""; height:22px; width:22px; left:3px; top:50%; transform: translateY(-50%); background:white; border-radius:50%; transition:.2s; }
        .switch input:checked + .slider{ background: rgba(34,197,94,.25); border-color: rgba(34,197,94,.45); }
        .switch input:checked + .slider:before{ transform: translate(20px,-50%); }
        .thumbbox {
            border-radius: 18px;
            border: 1px dashed rgba(148,163,184,.22);
            background: rgba(2,6,23,.35);
            padding: 12px;
            height: 100%;
        }
        .thumb {
            border-radius: 16px;
            overflow:hidden;
            background: rgba(148,163,184,.10);
            height: 220px;
            display:flex; align-items:center; justify-content:center;
            margin-bottom: 10px;
        }
        .thumb img { width: 100%; height: 100%; object-fit: cover; display:block; }
        .thumb .no { color:#94a3b8; font-size: 12px; }
        .actions { margin-top: 14px; display:flex; gap: 8px; flex-wrap:wrap; justify-content:flex-end; }
        @media (max-width: 880px) {
            .grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<jsp:include page="../common/gnb.jsp"/>

<main>
    <div class="top">
        <div>
            <h1><%=pageTitle%></h1>
            <div class="sub">필수 항목만 빠르게 채우고, 나머지는 나중에 수정해도 돼요.</div>
        </div>
        <div style="display:flex; gap:8px; flex-wrap:wrap; justify-content:flex-end;">
            <button class="btn" onclick="location.href='<%=ctx%>/market/marketMain.jsp'">목록</button>
            <% if (editMode) { %>
                <button class="btn" onclick="location.href='<%=ctx%>/market/marketView.jsp?id=<%=editItemId%>'">상세</button>
            <% } %>
        </div>
    </div>

    <section class="card">
        <form method="post" action="<%=actionUrl%>" enctype="multipart/form-data">
            <% if (editMode) { %>
                <input type="hidden" name="itemId" value="<%=editItemId%>"/>
            <% } %>

            <div class="grid">
                
                <div>
                    <label>제목 <span style="color:#fca5a5;">*</span></label>
                    <input type="text" name="title" maxlength="100" required value="<%=vTitle%>" placeholder="예) 운영체제 전공책(상태좋음)"/>

                    <div class="row2">
                        <div>
                            <label>카테고리 <span style="color:#fca5a5;">*</span></label>
                            <select name="category" required>
                                <option value="교재 · 전공책" <%= "교재 · 전공책".equals(vCategory) ? "selected" : "" %>>교재 · 전공책</option>
                                <option value="전자기기" <%= "전자기기".equals(vCategory) ? "selected" : "" %>>전자기기</option>
                                <option value="자취템" <%= "자취템".equals(vCategory) ? "selected" : "" %>>가구 · 자취템</option>
                                <option value="패션 · 잡화" <%= "패션 · 잡화".equals(vCategory) ? "selected" : "" %>>패션 · 잡화</option>
                                <option value="기타" <%= "기타".equals(vCategory) ? "selected" : "" %>>기타</option>
                            </select>
                        </div>
                        <div>
                            <label>가격(원) <span style="color:#fca5a5;">*</span></label>
                            <input type="number" name="price" required min="0" value="<%=vPrice%>" placeholder="0"/>
                            <div class="help">콤마 없이 숫자만 입력해주세요.</div>
                        </div>
                    </div>

                    <div class="row2">
                        <div>
                            <label>캠퍼스/장소 <span style="color:#fca5a5;">*</span></label>
                            <select name="campus" required>
                                <option value="강남대 정문" <%= "강남대 정문".equals(vCampus) ? "selected" : "" %>>강남대 정문</option>
                                <option value="기숙사" <%= "기숙사".equals(vCampus) ? "selected" : "" %>>기숙사</option>
                                <option value="역 인근" <%= "역 인근".equals(vCampus) ? "selected" : "" %>>역 인근</option>
                            </select>
                        </div>
                        <div>
                            <label>거래 방식 <span style="color:#fca5a5;">*</span></label>
                            <select name="tradeType" required>
                                <option value="DIRECT" <%= "DIRECT".equalsIgnoreCase(vTradeType) ? "selected" : "" %>>직거래</option>
                                <option value="DELIVERY" <%= "DELIVERY".equalsIgnoreCase(vTradeType) ? "selected" : "" %>>택배</option>
                                <option value="BOTH" <%= "BOTH".equalsIgnoreCase(vTradeType) ? "selected" : "" %>>직거래+택배</option>
                            </select>
                        </div>
                    </div>

                    <div class="toggle-row">
                        <div>
                            <div class="t-title">바로구매(즉시구매) 가능</div>
                            <div class="t-desc">바로구매 상품만 장바구니/구매가 가능해요. 구매 시 자동으로 거래완료 처리되고, 판매자는 송장번호를 입력해 배송현황을 공유할 수 있어요.</div>
                        </div>
                        <label class="switch" title="바로구매 가능">
                            <input type="checkbox" name="instantBuy" value="1" <%= vInstantBuy ? "checked" : "" %>>
                            <span class="slider"></span>
                        </label>
                    </div>

                    <div class="row2">
                        <div>
                            <label>거래 장소(상세)</label>
                            <input type="text" name="meetingPlace" value="<%=vMeetingPlace%>" placeholder="예) 도서관 앞, 공학관 로비"/>
                        </div>
                        <div>
                            <label>선호 시간</label>
                            <input type="text" name="meetingTime" value="<%=vMeetingTime%>" placeholder="예) 평일 18~21시"/>
                        </div>
                    </div>

                    <% if (editMode) { %>
                        <label>거래 상태</label>
                        <select name="status">
                            <option value="ON_SALE"  <%= "ON_SALE".equalsIgnoreCase(vStatus) ? "selected" : "" %>>판매중</option>
                            <option value="RESERVED" <%= "RESERVED".equalsIgnoreCase(vStatus) ? "selected" : "" %>>예약중</option>
                            <option value="SOLD_OUT" <%= "SOLD_OUT".equalsIgnoreCase(vStatus) ? "selected" : "" %>>거래완료</option>
                        </select>
                    <% } %>

                    <label>상세 설명</label>
                    <textarea name="description" placeholder="상태, 구성품, 하자 여부, 거래 희망사항 등을 적어주세요."><%=vDesc%></textarea>
                </div>

                
                <div class="thumbbox">
                    <div class="thumb" id="thumbBox">
                        <% if (thumbUrl != null) { %>
                            <img src="<%=thumbUrl%>" alt="현재 썸네일"/>
                        <% } else { %>
                            <div class="no">썸네일 미리보기</div>
                        <% } %>
                    </div>
                    <label>썸네일 이미지</label>
                    <input type="file" id="thumbInput" name="thumbnail" accept="image/*"/>
                    <div class="help">
                        업로드된 파일은 <code>webapp/resources/MarketThumbnail</code> 경로로 저장됩니다.<br/>
                        <% if (editMode) { %>새 이미지를 업로드하면 기존 썸네일이 교체됩니다.<% } else { %>이미지는 선택사항입니다.<% } %>
                    </div>
                </div>
            </div>

            <div class="actions">
                <% if (editMode) { %>
                    <button type="submit"
                            class="btn btn-danger"
                            formaction="<%=ctx%>/market/delete"
                            formmethod="post"
                            onclick="return confirm('정말 삭제할까요? (복구 불가)');">삭제</button>
                <% } %>
                <button type="button" class="btn" onclick="history.back();">취소</button>
                <button type="submit" class="btn btn-primary"><%= editMode ? "수정 저장" : "등록하기" %></button>
            </div>
        </form>
    </section>
</main>

<script>
  
  (function () {
    var input = document.getElementById('thumbInput');
    var box = document.getElementById('thumbBox');
    if (!input || !box) return;

    
    var originalHTML = box.innerHTML;

    input.addEventListener('change', function () {
      var file = input.files && input.files[0];
      if (!file) {
        box.innerHTML = originalHTML;
        return;
      }

      if (!file.type || file.type.indexOf('image/') !== 0) {
        alert('이미지 파일만 업로드할 수 있어요.');
        input.value = '';
        box.innerHTML = originalHTML;
        return;
      }

      var img = document.createElement('img');
      img.alt = '썸네일 미리보기';
      var url = URL.createObjectURL(file);
      img.onload = function () {
        try { URL.revokeObjectURL(url); } catch (e) {}
      };
      img.src = url;

      box.innerHTML = '';
      box.appendChild(img);
    });
  })();
</script>

</body>
</html>
