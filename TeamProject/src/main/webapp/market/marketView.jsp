<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="dao.MarketItemDao, dto.MarketItem" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String idStr = request.getParameter("id");
    long id = 0;
    try {
        id = Long.parseLong(idStr);
    } catch (Exception e) {
        id = 0;
    }

    MarketItemDao dao = new MarketItemDao();
    MarketItem item = null;
    if (id > 0) {
        item = dao.findById(id);
    }

    if (item == null) {
%>
<script>
    alert('존재하지 않는 상품입니다.');
    location.href = '<%=ctx%>/market/marketMain.jsp';
</script>
<%
        return;
    }

    String priceStr = String.format("%,d원", item.getPrice());
    String statusLabel = "판매중";
    String statusStyle = "background: rgba(22, 163, 74, 0.9); color:#ecfdf5;";
    if ("RESERVED".equalsIgnoreCase(item.getStatus())) {
        statusLabel = "예약중";
        statusStyle = "background: rgba(234, 179, 8, 0.95); color:#111827;";
    } else if ("SOLD_OUT".equalsIgnoreCase(item.getStatus())) {
        statusLabel = "거래완료";
        statusStyle = "background: rgba(107, 114, 128, 0.95); color:#e5e7eb;";
    }

    String thumb = item.getThumbnailUrl();
    boolean hasImg = (thumb != null && !thumb.trim().isEmpty());
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>KangnamTime – 중고상품 상세보기</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">

    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: "Noto Sans KR", system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
            background: #050816;
            color: #e5e7eb;
        }
        a { color: inherit; text-decoration: none; }

        .navbar {
            position: sticky;
            top: 0;
            z-index: 50;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 60px;
            background: rgba(5, 10, 25, 0.96);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid rgba(148, 163, 184, 0.1);
        }
        .navbar-left { display: flex; align-items: center; gap: 12px; }
        .navbar-logo {
            width: 32px;
            height: 32px;
            border-radius: 999px;
            background: radial-gradient(circle at 30% 30%, #4f9cff, #1f2937);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: #f9fafb;
            font-size: 14px;
        }
        .navbar-title { font-size: 18px; font-weight: 700; }
        .navbar-menu { display: flex; gap: 24px; font-size: 14px; }
        .navbar-menu a { opacity: 0.7; transition: opacity 0.15s ease, color 0.15s ease; }
        .navbar-menu a:hover { opacity: 1; color: #60a5fa; }
        .navbar-menu .active { opacity: 1; color: #60a5fa; font-weight: 600; }
        .navbar-right { display: flex; gap: 10px; }
        .btn-outline {
            padding: 6px 16px;
            border-radius: 999px;
            border: 1px solid rgba(148, 163, 184, 0.6);
            font-size: 13px;
            background: transparent;
            color: #e5e7eb;
            cursor: pointer;
        }
        .btn-primary {
            padding: 6px 18px;
            border-radius: 999px;
            border: none;
            font-size: 13px;
            background: linear-gradient(135deg, #2563eb, #38bdf8);
            color: white;
            cursor: pointer;
        }

        .page-wrapper {
            max-width: 960px;
            margin: 24px auto 60px;
            padding: 0 20px;
        }

        .card {
            background: radial-gradient(circle at top left, rgba(56, 189, 248, 0.09), rgba(15, 23, 42, 0.98));
            border-radius: 22px;
            padding: 20px 22px 24px;
            border: 1px solid rgba(148, 163, 184, 0.16);
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.9);
        }

        .detail-grid {
            display: grid;
            grid-template-columns: minmax(0, 1.8fr) minmax(0, 2.2fr);
            gap: 18px;
        }

        .thumb-wrap {
            border-radius: 18px;
            background: #020617;
            overflow: hidden;
            position: relative;
            min-height: 260px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .thumb-wrap img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .badge-status {
            position: absolute;
            top: 12px;
            left: 12px;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 11px;
            <%=statusStyle%>
        }

        .badge-category {
            position: absolute;
            bottom: 12px;
            left: 12px;
            padding: 4px 10px;
            border-radius: 999px;
            font-size: 11px;
            background: rgba(15, 23, 42, 0.9);
            border: 1px solid rgba(148, 163, 184, 0.7);
        }

        .detail-title {
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 6px;
        }

        .detail-price {
            font-size: 22px;
            font-weight: 700;
            color: #fbbf24;
            margin-bottom: 6px;
        }

        .detail-meta {
            font-size: 12px;
            color: #9ca3af;
            margin-bottom: 10px;
        }

        .detail-meta span {
            margin-right: 10px;
        }

        .chip {
            padding: 2px 8px;
            border-radius: 999px;
            background: rgba(15, 23, 42, 0.9);
            border: 1px solid rgba(148, 163, 184, 0.4);
            font-size: 11px;
        }

        .stat-row {
            margin-top: 8px;
            font-size: 12px;
            color: #9ca3af;
        }

        .detail-desc {
            margin-top: 14px;
            padding-top: 12px;
            border-top: 1px solid rgba(148, 163, 184, 0.25);
            font-size: 13px;
            line-height: 1.6;
            white-space: pre-line;
        }

        .detail-actions {
            margin-top: 18px;
            display: flex;
            gap: 10px;
        }

        .btn-secondary {
            padding: 7px 16px;
            border-radius: 999px;
            border: 1px solid rgba(148, 163, 184, 0.7);
            background: transparent;
            color: #e5e7eb;
            font-size: 13px;
            cursor: pointer;
        }

        .btn-chat {
            padding: 7px 18px;
            border-radius: 999px;
            border: none;
            background: linear-gradient(135deg, #2563eb, #38bdf8);
            color: #f9fafb;
            font-size: 13px;
            cursor: pointer;
            font-weight: 600;
        }

        @media (max-width: 860px) {
            .navbar {
                padding: 12px 16px;
            }
            .page-wrapper {
                padding: 0 14px;
            }
            .detail-grid {
                grid-template-columns: minmax(0, 1fr);
            }
        }
    </style>
</head>
<body>

<header class="navbar">
    <div class="navbar-left">
        <div class="navbar-logo">KT</div>
        <div class="navbar-title">KangnamTime</div>
    </div>
    <nav class="navbar-menu">
        <a href="<%=ctx%>/main.jsp">홈</a>
        <a href="<%=ctx%>/timetable/timetableMain.jsp">시간표</a>
        <a href="<%=ctx%>/board/mainBoard.jsp">게시판</a>
        <a href="#">강의평가</a>
        <a href="#">캠퍼스 정보</a>
        <a href="<%=ctx%>/market/marketMain.jsp" class="active">중고거래</a>
    </nav>
    <div class="navbar-right">
        <button class="btn-outline" onclick="location.href='<%=ctx%>/login.jsp'">로그인</button>
        <button class="btn-primary" onclick="location.href='<%=ctx%>/signup.jsp'">회원가입</button>
    </div>
</header>

<main class="page-wrapper">
    <section class="card">
        <div class="detail-grid">
            <div class="thumb-wrap">
                <div class="badge-status"><%=statusLabel%></div>
                <div class="badge-category"><%=item.getCategory()%></div>
                <% if (hasImg) { %>
                    <img src="<%=item.getThumbnailUrl()%>" alt="상품 이미지">
                <% } else { %>
                    이미지 없음
                <% } %>
            </div>
            <div>
                <div class="detail-title"><%=item.getTitle()%></div>
                <div class="detail-price"><%=priceStr%></div>
                <div class="detail-meta">
                    <span><%=item.getCampus()%></span>
                    <% if (item.getMeetingPlace() != null && !item.getMeetingPlace().trim().isEmpty()) { %>
                        <span><%=item.getMeetingPlace()%></span>
                    <% } %>
                    <% if (item.getMeetingTime() != null && !item.getMeetingTime().trim().isEmpty()) { %>
                        <span><%=item.getMeetingTime()%></span>
                    <% } %>
                </div>
                <div class="stat-row">
                    <span class="chip">찜 <%=item.getWishCount()%> · 채팅 <%=item.getChatCount()%></span>
                    <span style="margin-left:8px; font-size:11px; color:#9ca3af;">등록 번호: #<%=item.getId()%></span>
                </div>

                <div class="detail-desc">
                    <% if (item.getDescription() != null && !item.getDescription().trim().isEmpty()) { %>
                        <%=item.getDescription()%>
                    <% } else { %>
                        판매자가 남긴 상세 설명이 없습니다.
                    <% } %>
                </div>

                <div class="detail-actions">
                    <button class="btn-secondary"
                            onclick="location.href='<%=ctx%>/market/marketMain.jsp'">목록으로</button>
                    <button class="btn-chat"
                            onclick="alert('채팅 기능은 추후 추가 예정입니다.');">채팅으로 거래하기</button>
                </div>
            </div>
        </div>
    </section>
</main>

</body>
</html>
