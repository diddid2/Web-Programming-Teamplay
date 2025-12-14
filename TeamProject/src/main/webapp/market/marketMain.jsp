<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.sql.*, java.net.URLEncoder, util.DBUtil, dao.MarketItemDao, dto.MarketItem" %>

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

    String enc(String s) {
        try {
            return URLEncoder.encode(s == null ? "" : s, "UTF-8");
        } catch (Exception e) {
            return "";
        }
    }
%>

<%
    String userId = (String) session.getAttribute("userId");
	request.setAttribute("currentMenu", "market");
%>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    String keyword   = request.getParameter("keyword");
    String category  = request.getParameter("category");
    String campus    = request.getParameter("campus");
    String tradeType = request.getParameter("tradeType");
    String sort      = request.getParameter("sort");
    String instantOnlyParam = request.getParameter("instantOnly");
    boolean instantOnly = "1".equals(instantOnlyParam);

    int pageSize = 30;
    int pageNo = 1;
    try {
        String pageParam = request.getParameter("page");
        if (pageParam != null && !pageParam.trim().isEmpty()) {
            pageNo = Integer.parseInt(pageParam);
        }
    } catch (Exception ignore) {
        pageNo = 1;
    }
    if (pageNo < 1) pageNo = 1;

    if (category == null)  category = "ALL";
    if (campus == null)    campus = "ALL";
    if (tradeType == null) tradeType = "ALL";
    if (sort == null)      sort = "latest";

    MarketItemDao marketDao = new MarketItemDao();

    int totalCount = marketDao.countByFilter(keyword, category, campus, tradeType, instantOnly);
    int totalPages = (int) Math.ceil(totalCount / (double) pageSize);
    if (totalPages < 1) totalPages = 1;
    if (pageNo > totalPages) pageNo = totalPages;
    int offset = (pageNo - 1) * pageSize;

    List<MarketItem> items = marketDao.findByFilterPaged(
            keyword,
            category,
            campus,
            tradeType,
            sort,
            offset,
            pageSize,
            instantOnly
    );

    int todayCount = totalCount; // 현재 조건에 해당하는 전체 개수
    int onSaleCount = 0;
    for (MarketItem mi : items) {
        if ("ON_SALE".equalsIgnoreCase(mi.getStatus())) onSaleCount++;
    }

    // ===== 내 거래현황(로그인 연동) =====
    String userName = (String) session.getAttribute("userName");
    Integer memberNo = (Integer) session.getAttribute("memberNo");

    int mySaleCount = 0;
    int myReservedCount = 0;
    int mySoldCount = 0;

    if (userId != null) {
        // memberNo가 세션에 없으면 MEMBER 테이블에서 조회
        if (memberNo == null) {
            String sqlMem = "SELECT MEMBER_NO FROM MEMBER WHERE USER_ID=?";
            try (Connection conn = DBUtil.getConnection();
                 PreparedStatement ps = conn.prepareStatement(sqlMem)) {
                ps.setString(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        memberNo = rs.getInt("MEMBER_NO");
                        session.setAttribute("memberNo", memberNo);
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        if (memberNo != null) {
            mySaleCount     = marketDao.countByWriterAndStatus(memberNo, "ON_SALE");
            myReservedCount = marketDao.countByWriterAndStatus(memberNo, "RESERVED");
            mySoldCount     = marketDao.countByWriterAndStatus(memberNo, "SOLD_OUT");
        }
    }

    // ===== 페이징 링크용 쿼리 =====
    String pageUrlPrefix = ctx + "/market/marketMain.jsp?"
            + "keyword=" + enc(keyword)
            + "&category=" + enc(category)
            + "&campus=" + enc(campus)
            + "&tradeType=" + enc(tradeType)
            + "&sort=" + enc(sort)
            + "&instantOnly=" + (instantOnly ? "1" : "0")
            + "&page=";

%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>KangnamTime – 중고거래</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- 폰트 -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">

    <style>
        /* 네가 준 CSS 그대로 (생략 없이 붙이기) */
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: "Noto Sans KR", system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
            background: #050816;
            color: #e5e7eb;
        }

        a {
            color: inherit;
            text-decoration: none;
        }

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

        .navbar-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }

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

        .navbar-title {
            font-size: 18px;
            font-weight: 700;
        }

        .navbar-menu {
            display: flex;
            gap: 24px;
            font-size: 14px;
        }

        .navbar-menu a {
            opacity: 0.7;
            transition: opacity 0.15s ease, color 0.15s ease;
        }

        .navbar-menu a:hover {
            opacity: 1;
            color: #60a5fa;
        }

        .navbar-menu .active {
            opacity: 1;
            color: #60a5fa;
            font-weight: 600;
        }

        .navbar-right {
            display: flex;
            gap: 10px;
        }

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

        .btn-outline:hover {
            border-color: #60a5fa;
        }

        .btn-primary:hover {
            filter: brightness(1.1);
        }

        .page-wrapper {
            max-width: 1180px;
            margin: 0 auto;
            padding: 24px 24px 80px;
        }

        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-end;
            margin-bottom: 24px;
        }

        .page-title {
            font-size: 24px;
            font-weight: 700;
        }

        .page-title span {
            color: #60a5fa;
        }

        .page-subtitle {
            margin-top: 6px;
            font-size: 13px;
            color: #9ca3af;
        }

        .page-header-right {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .pill {
            font-size: 11px;
            padding: 4px 10px;
            border-radius: 999px;
            background: rgba(15, 23, 42, 0.9);
            border: 1px solid rgba(148, 163, 184, 0.4);
            color: #9ca3af;
        }

        .pill span {
            color: #60a5fa;
            font-weight: 600;
            margin-left: 4px;
        }

        .card {
            background: radial-gradient(circle at top left, rgba(56, 189, 248, 0.09), rgba(15, 23, 42, 0.98));
            border-radius: 22px;
            padding: 18px 20px;
            border: 1px solid rgba(148, 163, 184, 0.16);
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.9);
        }

        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 10px;
        }

        .card-title {
            font-size: 15px;
            font-weight: 600;
        }

        .card-subtitle {
            font-size: 11px;
            color: #9ca3af;
        }

        .card-link {
            font-size: 11px;
            color: #60a5fa;
            cursor: pointer;
        }

        .search-card {
            margin-bottom: 20px;
        }

        .tabbar {
            margin-top: 10px;
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }
        .tab {
            padding: 8px 14px;
            border-radius: 999px;
            border: 1px solid rgba(148, 163, 184, 0.4);
            background: rgba(15, 23, 42, 0.98);
            color: #cbd5e1;
            font-size: 12px;
            cursor: pointer;
        }
        .tab:hover { border-color: rgba(96,165,250,.7); }
        .tab-active {
            background: linear-gradient(135deg, rgba(37,99,235,.95), rgba(56,189,248,.95));
            border: none;
            color: white;
            font-weight: 700;
        }

        .search-row {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
            margin-top: 12px;
        }

        .search-input {
            flex: 1 1 260px;
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 8px 12px;
            border-radius: 999px;
            background: rgba(15, 23, 42, 0.98);
            border: 1px solid rgba(148, 163, 184, 0.4);
            font-size: 13px;
        }

        .search-input input {
            background: transparent;
            border: none;
            outline: none;
            color: #e5e7eb;
            width: 100%;
            font-size: 13px;
        }

        .filter-select {
            min-width: 120px;
            padding: 7px 10px;
            border-radius: 999px;
            background: rgba(15, 23, 42, 0.98);
            border: 1px solid rgba(148, 163, 184, 0.4);
            color: #e5e7eb;
            font-size: 12px;
        }

        .search-btn {
            padding: 7px 18px;
            border-radius: 999px;
            border: none;
            font-size: 13px;
            background: linear-gradient(135deg, #2563eb, #38bdf8);
            color: white;
            cursor: pointer;
        }

        .search-btn:hover {
            filter: brightness(1.1);
        }

        .content-grid {
            display: grid;
            grid-template-columns: minmax(0, 3.1fr) minmax(0, 1.7fr);
            gap: 18px;
        }

        .product-list-card {
            min-height: 260px;
        }

        .product-toolbar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
            margin-bottom: 12px;
            font-size: 11px;
            color: #9ca3af;
        }

        .product-tabs {
            display: flex;
            gap: 6px;
        }

        .product-tab {
            padding: 4px 10px;
            border-radius: 999px;
            background: rgba(15, 23, 42, 0.95);
            border: 1px solid transparent;
            cursor: pointer;
            font-size: 11px;
            color: #9ca3af;
        }

        .product-tab.active {
            border-color: #60a5fa;
            color: #e5e7eb;
            background: rgba(15, 23, 42, 1);
        }

        .product-sort {
            display: flex;
            gap: 6px;
            align-items: center;
        }

        .product-sort select {
            border-radius: 999px;
            background: rgba(15, 23, 42, 0.98);
            border: 1px solid rgba(148, 163, 184, 0.4);
            color: #e5e7eb;
            font-size: 11px;
            padding: 4px 8px;
        }

        .product-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 10px;
        }

        .product-card {
            background: rgba(15, 23, 42, 0.96);
            border-radius: 18px;
            border: 1px solid rgba(148, 163, 184, 0.3);
            padding: 8px;
            display: flex;
            flex-direction: column;
            gap: 6px;
            cursor: pointer;
            transition: transform 0.12s ease, box-shadow 0.12s ease, border-color 0.12s ease;
        }

        .product-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 30px rgba(15, 23, 42, 0.8);
            border-color: #60a5fa;
        }

        .product-thumb {
            position: relative;
            border-radius: 12px;
            overflow: hidden;
            background: linear-gradient(135deg, #1f2937, #020617);
            height: 120px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 11px;
            color: #9ca3af;
        }

        .product-thumb img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .product-tag {
            position: absolute;
            top: 8px;
            left: 8px;
            padding: 3px 8px;
            border-radius: 999px;
            font-size: 10px;
            background: rgba(15, 23, 42, 0.86);
            border: 1px solid rgba(148, 163, 184, 0.7);
        }

        .product-status {
            position: absolute;
            bottom: 8px;
            right: 8px;
            padding: 2px 8px;
            border-radius: 999px;
            font-size: 10px;
            background: rgba(22, 163, 74, 0.9);
            color: #ecfdf5;
            font-weight: 500;
        }

        .product-info-main {
            display: flex;
            justify-content: space-between;
            gap: 8px;
            margin-top: 4px;
        }

        .product-title {
            font-size: 13px;
            font-weight: 500;
            line-height: 1.3;
        }

        .product-meta {
            font-size: 11px;
            color: #9ca3af;
            margin-top: 2px;
        }

        .product-price {
            font-size: 14px;
            font-weight: 700;
            color: #fbbf24;
            text-align: right;
        }

        .product-extra {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 4px;
            font-size: 10px;
            color: #9ca3af;
        }

        .product-tags {
            display: flex;
            align-items: center;
            justify-content: flex-end;
            gap: 2px;
        }

        .product-tags .chip {
            white-space: nowrap;
        }

        .product-tags .chip {
            white-space: nowrap;
        }

        .chip {
            padding: 2px 6px;
            border-radius: 999px;
            background: rgba(15, 23, 42, 0.9);
            border: 1px solid rgba(148, 163, 184, 0.4);
        }

        .product-actions {
            display: flex;
            justify-content: space-between;
            margin-top: 6px;
        }

        .pagination {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 6px;
            margin-top: 14px;
            flex-wrap: wrap;
        }

        .page-link {
            padding: 6px 10px;
            border-radius: 999px;
            border: 1px solid rgba(148, 163, 184, 0.35);
            background: rgba(15, 23, 42, 0.7);
            font-size: 12px;
            color: #e5e7eb;
            opacity: 0.85;
        }

        .page-link:hover {
            opacity: 1;
            border-color: rgba(96, 165, 250, 0.6);
            color: #60a5fa;
        }

        .page-link.active {
            opacity: 1;
            border-color: rgba(96, 165, 250, 0.9);
            background: rgba(37, 99, 235, 0.22);
            color: #93c5fd;
            font-weight: 700;
        }

        .page-link.disabled {
            opacity: 0.35;
            pointer-events: none;
        }

        .btn-xs {
            font-size: 10px;
            padding: 4px 8px;
            border-radius: 999px;
            border: 1px solid rgba(148, 163, 184, 0.7);
            background: transparent;
            color: #e5e7eb;
            cursor: pointer;
        }

        .btn-xs-primary {
            font-size: 10px;
            padding: 4px 10px;
            border-radius: 999px;
            border: none;
            background: linear-gradient(135deg, #2563eb, #38bdf8);
            color: #f9fafb;
            cursor: pointer;
        }

        .side-card + .side-card {
            margin-top: 12px;
        }

        .status-list {
            margin-top: 8px;
            display: grid;
            gap: 8px;
            font-size: 12px;
        }

        .status-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 10px;
            border-radius: 12px;
            background: rgba(15, 23, 42, 0.96);
            border: 1px solid rgba(148, 163, 184, 0.3);
        }

        .status-label {
            display: flex;
            flex-direction: column;
            gap: 2px;
        }

        .status-label span:first-child {
            font-size: 12px;
            font-weight: 500;
        }

        .status-label span:last-child {
            font-size: 11px;
            color: #9ca3af;
        }

        .status-value {
            font-weight: 600;
            color: #60a5fa;
        }

        .badge {
            font-size: 10px;
            padding: 2px 8px;
            border-radius: 999px;
            background: rgba(15, 23, 42, 0.9);
            border: 1px solid rgba(148, 163, 184, 0.5);
        }

        .keyword-list {
            display: flex;
            flex-wrap: wrap;
            gap: 6px;
            margin-top: 10px;
        }

        .keyword {
            font-size: 11px;
            padding: 4px 10px;
            border-radius: 999px;
            background: rgba(15, 23, 42, 0.96);
            border: 1px solid rgba(148, 163, 184, 0.4);
            cursor: pointer;
        }

        .keyword.hot {
            border-color: #fb923c;
            color: #fed7aa;
        }

        .quick-category {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 8px;
            margin-top: 10px;
        }

        .quick-category button {
            font-size: 11px;
            padding: 8px 6px;
            border-radius: 14px;
            border: 1px solid rgba(148, 163, 184, 0.4);
            background: rgba(15, 23, 42, 0.96);
            color: #e5e7eb;
            cursor: pointer;
            text-align: left;
        }

        .quick-category button span {
            display: block;
            font-size: 10px;
            color: #9ca3af;
            margin-top: 2px;
        }

        .floating-write-btn {
            position: fixed;
            right: 32px;
            bottom: 32px;
            padding: 12px 18px;
            border-radius: 999px;
            border: none;
            background: linear-gradient(135deg, #22c55e, #16a34a);
            color: #f9fafb;
            font-size: 13px;
            font-weight: 600;
            box-shadow: 0 12px 35px rgba(22, 163, 74, 0.7);
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 8px;
            z-index: 40;
        }

        .floating-write-btn span.icon {
            width: 22px;
            height: 22px;
            border-radius: 999px;
            background: rgba(15, 23, 42, 0.5);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
        }

        .footer {
            margin-top: 40px;
            padding: 18px 0 10px;
            font-size: 11px;
            text-align: center;
            color: #6b7280;
            border-top: 1px solid rgba(148, 163, 184, 0.12);
        }

        @media (max-width: 960px) {
            .navbar {
                padding: 12px 16px;
            }
            .page-wrapper {
                padding: 18px 16px 80px;
            }
            .content-grid {
                grid-template-columns: minmax(0, 1fr);
            }
            .page-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }
            .floating-write-btn {
                right: 18px;
                bottom: 18px;
            }
        }

        @media (max-width: 720px) {
            .navbar-menu {
                display: none;
            }
        }
    </style>
</head>
<body>

<jsp:include page="../common/gnb.jsp"/>

<main class="page-wrapper">

    <section class="page-header">
        <div>
            <div class="page-title">
                오늘도 <span>강남 마켓</span>에서
            </div>
            <p class="page-subtitle">
                교재, 노트북, 기기부터 자취템까지. 학교 사람들끼리 안전하게 중고거래 해보세요.
            </p>
        </div>
        <div class="page-header-right">
            <div class="pill">
                오늘 조회된 글<span>+<%=todayCount%></span>
            </div>
            <div class="pill">
                판매중 상품<span><%=onSaleCount%>건</span>
            </div>
        </div>
    </section>

    <!-- 검색 / 필터 카드 -->
    <section class="card search-card">
        <div class="card-header">
            <div>
                <div class="card-title">상품 검색</div>
                <div class="card-subtitle">키워드, 카테고리, 캠퍼스를 선택해서 원하는 상품을 찾아보세요.</div>
            </div>
        </div>

        <div class="tabbar">
            <button type="button" class="tab <%= (!instantOnly ? "tab-active" : "") %>"
                    onclick="document.getElementById('instantOnly').value='0'; document.getElementById('searchForm').submit();">
                전체
            </button>
            <button type="button" class="tab <%= (instantOnly ? "tab-active" : "") %>"
                    onclick="document.getElementById('instantOnly').value='1'; document.getElementById('searchForm').submit();">
                바로구매
            </button>
        </div>

        <form id="searchForm" class="search-row" method="get" action="<%=ctx%>/market/marketMain.jsp">
            <input type="hidden" id="instantOnly" name="instantOnly" value="<%= instantOnly ? "1" : "0" %>"/>
            <input type="hidden" name="sort" value="<%= sort %>"/>
            <input type="hidden" name="page" value="1"/>
            <div class="search-input">
                <span>🔍</span>
                <input type="text" name="keyword"
                       placeholder="예) 운영체제 교재, 아이패드, 자취 냉장고"
                       value="<%= keyword != null ? keyword : "" %>">
            </div>

            <select class="filter-select" name="category">
                <option value="ALL" <%= "ALL".equals(category) ? "selected" : "" %>>전체 카테고리</option>
                <option value="교재 · 전공책" <%= "교재 · 전공책".equals(category) ? "selected" : "" %>>교재 · 전공책</option>
                <option value="전자기기" <%= "전자기기".equals(category) ? "selected" : "" %>>전자기기</option>
                <option value="자취템" <%= "자취템".equals(category) ? "selected" : "" %>>가구 · 자취템</option>
                <option value="패션 · 잡화" <%= "패션 · 잡화".equals(category) ? "selected" : "" %>>패션 · 잡화</option>
                <option value="기타" <%= "기타".equals(category) ? "selected" : "" %>>기타</option>
            </select>

            <select class="filter-select" name="campus">
                <option value="ALL" <%= "ALL".equals(campus) ? "selected" : "" %>>전체 캠퍼스</option>
                <option value="강남대 정문" <%= "강남대 정문".equals(campus) ? "selected" : "" %>>강남대 정문</option>
                <option value="기숙사" <%= "기숙사".equals(campus) ? "selected" : "" %>>기숙사</option>
                <option value="역 인근" <%= "역 인근".equals(campus) ? "selected" : "" %>>역 인근</option>
            </select>

            <select class="filter-select" name="tradeType">
                <option value="ALL" <%= "ALL".equals(tradeType) ? "selected" : "" %>>거래 방식 전체</option>
                <option value="DIRECT" <%= "DIRECT".equals(tradeType) ? "selected" : "" %>>직거래</option>
                <option value="DELIVERY" <%= "DELIVERY".equals(tradeType) ? "selected" : "" %>>택배</option>
                <option value="BOTH" <%= "BOTH".equals(tradeType) ? "selected" : "" %>>직거래+택배</option>
            </select>

            <button class="search-btn" type="submit">검색하기</button>
        </form>
    </section>

    <!-- 메인 컨텐츠 그리드 -->
    <section class="content-grid">

        <!-- 상품 리스트 -->
        <section class="card product-list-card">
            <div class="card-header">
                <div>
                    <div class="card-title">실시간 중고 상품</div>
                    <div class="card-subtitle">최근 등록 순으로 최대 30개까지 보여줍니다.</div>
                </div>
                <div class="card-link" onclick="location.href='<%=ctx%>/market/marketMain.jsp'">전체 보기</div>
            </div>

            <div class="product-toolbar">
                <div class="product-tabs">
                    <button class="product-tab <%= "ALL".equals(category) ? "active" : "" %>"
                            onclick="location.href='<%=ctx%>/market/marketMain.jsp'">전체</button>
                    <button class="product-tab <%= "교재 · 전공책".equals(category) ? "active" : "" %>"
                            onclick="location.href='<%=ctx%>/market/marketMain.jsp?category=교재 · 전공책'">교재</button>
                    <button class="product-tab <%= "전자기기".equals(category) ? "active" : "" %>"
                            onclick="location.href='<%=ctx%>/market/marketMain.jsp?category=전자기기'">전자기기</button>
                    <button class="product-tab <%= "자취템".equals(category) ? "active" : "" %>"
                            onclick="location.href='<%=ctx%>/market/marketMain.jsp?category=자취템'">자취템</button>
                    <button class="product-tab <%= "패션 · 잡화".equals(category) ? "active" : "" %>"
                            onclick="location.href='<%=ctx%>/market/marketMain.jsp?category=패션 · 잡화'">패션</button>
                </div>
                <div class="product-sort">
                    <span>정렬</span>
                    <form method="get" action="<%=ctx%>/market/marketMain.jsp" id="sortForm">
                        <input type="hidden" name="keyword" value="<%= keyword != null ? keyword : "" %>">
                        <input type="hidden" name="category" value="<%= category %>">
                        <input type="hidden" name="campus" value="<%= campus %>">
                        <input type="hidden" name="tradeType" value="<%= tradeType %>">
                        <input type="hidden" name="instantOnly" value="<%= instantOnly ? "1" : "0" %>">
                        <input type="hidden" name="page" value="1">
                        <select name="sort" onchange="document.getElementById('sortForm').submit()">
                            <option value="latest" <%= "latest".equals(sort) ? "selected" : "" %>>최신순</option>
                            <option value="price_asc" <%= "price_asc".equals(sort) ? "selected" : "" %>>가격 낮은순</option>
                            <option value="price_desc" <%= "price_desc".equals(sort) ? "selected" : "" %>>가격 높은순</option>
                            <option value="wish_desc" <%= "wish_desc".equals(sort) ? "selected" : "" %>>찜 많은순</option>
                        </select>
                    </form>
                </div>
            </div>

            <div class="product-grid">
                <%
                    if (items == null || items.isEmpty()) {
                %>
                <p style="font-size:13px; color:#9ca3af;">조건에 맞는 상품이 없습니다. 검색어 또는 필터를 바꿔보세요.</p>
                <%
                    } else {
                        for (MarketItem item : items) {
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
                            String imgSrc = thumbSrc(ctx, thumb);
                            boolean hasImg = (imgSrc != null);
                %>
                <article class="product-card" onclick="location.href='<%=ctx%>/market/marketView.jsp?id=<%=item.getId()%>'">
                    <div class="product-thumb">
                        <div class="product-tag"><%=item.getCategory()%></div>
                        <div class="product-status" style="<%=statusStyle%>"><%=statusLabel%></div>
                        <% if (hasImg) {%>
                            <img src="<%=imgSrc%>" alt="상품 이미지">
                        <% } else { %>
                            이미지 없음
                        <% } %>
                    </div>
                    <div class="product-info-main">
                        <div>
                            <h3 class="product-title"><%=item.getTitle()%></h3>
                            <p class="product-meta">
                                <%=item.getCampus()%>
                                <% if (item.getMeetingTime() != null && !item.getMeetingTime().trim().isEmpty()) { %>
                                    · <%=item.getMeetingTime()%>
                                <% } %>
                            </p>
                        </div>
                        <div class="product-price"><%=priceStr%></div>
                    </div>
                    <div class="product-extra">
                        <span>찜 <%=item.getWishCount()%> · 채팅 <%=item.getChatCount()%></span>
                        <span class="product-tags">
                            <% if (item.isInstantBuy()) { %>
                                <span class="chip" style="border-color: rgba(34,197,94,.40); background: rgba(34,197,94,.12); color:#a7f3d0;">바로구매</span>
                            <% } %>
                            <% if (item.getMeetingPlace() != null && !item.getMeetingPlace().trim().isEmpty()) { %>
                                <span class="chip"><%=item.getMeetingPlace()%></span>
                            <% } else { %>
                                <span class="chip">
                                <%
                                    if ("DIRECT".equalsIgnoreCase(item.getTradeType())) out.print("직거래");
                                    else if ("DELIVERY".equalsIgnoreCase(item.getTradeType())) out.print("택배");
                                    else out.print("직거래+택배");
                                %>
                                </span>
                            <% } %>
                        </span>
                    </div>
                    <div class="product-actions">
                        <button class="btn-xs" type="button"
                                onclick="event.stopPropagation();location.href='<%=ctx%>/market/marketView.jsp?id=<%=item.getId()%>'">상세보기</button>
                        <button class="btn-xs-primary" type="button"
                                onclick="event.stopPropagation();location.href='<%=ctx%>/market/chatStart.jsp?itemId=<%=item.getId()%>'">채팅으로 거래하기</button>
                    </div>
                </article>
                <%
                        }
                    }
                %>
            </div>

            <%-- 페이지네이션 --%>
            <% if (totalPages > 1) {
                int startPage = Math.max(1, pageNo - 2);
                int endPage = Math.min(totalPages, startPage + 4);
                startPage = Math.max(1, endPage - 4);

                String prevHref = (pageNo > 1) ? (pageUrlPrefix + (pageNo - 1)) : "#";
                String nextHref = (pageNo < totalPages) ? (pageUrlPrefix + (pageNo + 1)) : "#";
            %>
            <div class="pagination">
                <a class="page-link <%= (pageNo <= 1 ? "disabled" : "") %>" href="<%=prevHref%>">이전</a>
                <% for (int p = startPage; p <= endPage; p++) { %>
                    <a class="page-link <%= (p == pageNo ? "active" : "") %>" href="<%=pageUrlPrefix + p%>"><%=p%></a>
                <% } %>
                <a class="page-link <%= (pageNo >= totalPages ? "disabled" : "") %>" href="<%=nextHref%>">다음</a>
            </div>
            <% } %>
        </section>

        <!-- 오른쪽 사이드 영역 -->
        <aside>
            <section class="card side-card">
                <div class="card-header">
                    <div>
                        <div class="card-title">나의 거래 현황</div>
                        <div class="card-subtitle">로그인 시 판매/구매 진행 상태를 한 눈에 볼 수 있어요.</div>
                    </div>
                    <% if (userId == null) { %>
                        <div class="badge">로그인 필요</div>
                    <% } else { %>
                        <div class="badge" style="border-color: rgba(34,197,94,.45); background: rgba(34,197,94,.12); color:#a7f3d0;">
                            <%= (userName != null ? userName : userId) %> 님
                        </div>
                    <% } %>
                </div>
                <div class="status-list">
                    <div class="status-row">
                        <div class="status-label">
                            <span>판매 중</span>
                            <span>현재 공개 중인 판매 글</span>
                        </div>
                        <div class="status-value"><%= (userId == null ? 0 : mySaleCount) %>건</div>
                    </div>
                    <div class="status-row">
                        <div class="status-label">
                            <span>예약 중</span>
                            <span>거래 시간만 조율하면 돼요</span>
                        </div>
                        <div class="status-value"><%= (userId == null ? 0 : myReservedCount) %>건</div>
                    </div>
                    <div class="status-row">
                        <div class="status-label">
                            <span>거래 완료</span>
                            <span>후기 남기고 신뢰도를 올려보세요</span>
                        </div>
                        <div class="status-value"><%= (userId == null ? 0 : mySoldCount) %>건</div>
                    </div>
                </div>

                <div style="margin-top: 12px; display:flex; gap:8px;">
                    <% if (userId == null) { %>
                        <button type="button" class="btn-outline" style="width:100%;"
                                onclick="location.href='<%=ctx%>/login.jsp'">로그인하고 보기</button>
                    <% } else { %>
                        <button type="button" class="btn-outline" style="width:100%;"
                                onclick="location.href='<%=ctx%>/market/myMarket.jsp'">내 거래현황 자세히</button>
                    <% } %>
                </div>
            </section>


    </section>

    <footer class="footer">
        © 2025 KangnamTime. JSP Web Programming Team Project. All rights reserved.
    </footer>

</main>


<button class="floating-write-btn" style="bottom: 92px; background: rgba(14,165,233,.95);"
        onclick="location.href='<%=ctx%>/market/myMarket.jsp'">
    <span class="icon">📦</span>
    내 거래현황
</button>

<button class="floating-write-btn" onclick="location.href='<%=ctx%>/market/marketWrite.jsp'">
    <span class="icon">✏️</span>
    중고상품 글쓰기
</button>


<button class="floating-write-btn" style="bottom: 152px; background: rgba(251,191,36,.95); color:#0b1120;"
        onclick="location.href='<%=ctx%>/market/cart.jsp'">
    <span class="icon">🛒</span>
    장바구니
</button>

</body>
</html>
