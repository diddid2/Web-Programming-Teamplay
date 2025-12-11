<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<%
    String userId   = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String ctx      = request.getContextPath();
    String currentMenu = (String) request.getAttribute("market");
%>
<html lang="ko">
<head>

    <meta charset="UTF-8">
    <title>KangnamTime – 중고거래</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- 폰트 (원하면 프로젝트에서 쓰는 폰트로 교체) -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">

    <style>
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

        /* 상단 네비게이션바 */
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

        /* 메인 레이아웃 */
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

        /* 카드 공통 스타일 */
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

        /* 상단 검색/필터 영역 */
        .search-card {
            margin-bottom: 20px;
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

        /* 메인/사이드 2컬럼 레이아웃 */
        .content-grid {
            display: grid;
            grid-template-columns: minmax(0, 3.1fr) minmax(0, 1.7fr);
            gap: 18px;
        }

        /* 상품 리스트 카드 */
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
            justify-content: space-between;
            margin-top: 4px;
            font-size: 10px;
            color: #9ca3af;
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

        /* 오른쪽 사이드 카드 */
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

        /* 플로팅 글쓰기 버튼 */
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

        /* 푸터 */
        .footer {
            margin-top: 40px;
            padding: 18px 0 10px;
            font-size: 11px;
            text-align: center;
            color: #6b7280;
            border-top: 1px solid rgba(148, 163, 184, 0.12);
        }

        /* 반응형 */
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
                display: none; /* 필요하면 모바일 메뉴 따로 구현 */
            }
        }
    </style>
</head>
<body>

<!-- NAVBAR (초기 디자인 유지) -->
<header class="navbar">
    <div class="navbar-left">
        <div class="navbar-logo">KT</div>
        <div class="navbar-title">KangnamTime</div>
    </div>
    <nav class="navbar-menu">
        <a href="/">홈</a>
        <a href="/timetable">시간표</a>
        <a href="/board">게시판</a>
        <a href="/review">강의평가</a>
        <a href="/campus">캠퍼스 정보</a>
        <a href="/market" class="active">중고거래</a>
    </nav>
    <div class="navbar-right">
        <button class="btn-outline" onclick="location.href='/login'">로그인</button>
        <button class="btn-primary" onclick="location.href='/register'">회원가입</button>
    </div>
</header>

<!-- PAGE WRAPPER -->
<main class="page-wrapper">

    <!-- 상단 타이틀 -->
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
                오늘 등록된 글<span>+12</span>
            </div>
            <div class="pill">
                실시간 거래 중<span>5건</span>
            </div>
        </div>
    </section>

    <!-- 검색 / 필터 카드 (디자인만, 실제 검색은 나중에 서블릿에서 처리 가능) -->
    <section class="card search-card">
        <div class="card-header">
            <div>
                <div class="card-title">상품 검색</div>
                <div class="card-subtitle">키워드, 카테고리, 캠퍼스를 선택해서 원하는 상품을 찾아보세요.</div>
            </div>
            <div class="card-link">고급 필터 · 내 거래만 보기</div>
        </div>

        <div class="search-row">
            <div class="search-input">
                <span>🔍</span>
                <input type="text" placeholder="예) 운영체제 교재, 아이패드, 자취 냉장고">
            </div>

            <select class="filter-select">
                <option>전체 카테고리</option>
                <option>교재 · 전공책</option>
                <option>전자기기</option>
                <option>가구 · 자취템</option>
                <option>패션 · 잡화</option>
                <option>기타</option>
            </select>

            <select class="filter-select">
                <option>전체 캠퍼스</option>
                <option>강남대 정문</option>
                <option>기숙사</option>
                <option>역 인근</option>
            </select>

            <select class="filter-select">
                <option>거래 방식 전체</option>
                <option>직거래</option>
                <option>택배</option>
            </select>

            <button class="search-btn">검색하기</button>
        </div>
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
                <div class="card-link" onclick="location.href='/market'">전체 보기</div>
            </div>

            <div class="product-toolbar">
                <div class="product-tabs">
                    <button class="product-tab active">전체</button>
                    <button class="product-tab">교재</button>
                    <button class="product-tab">전자기기</button>
                    <button class="product-tab">자취템</button>
                    <button class="product-tab">패션</button>
                </div>
                <div class="product-sort">
                    <span>정렬</span>
                    <select>
                        <option>최신순</option>
                        <option>가격 낮은순</option>
                        <option>가격 높은순</option>
                        <option>찜 많은순</option>
                    </select>
                </div>
            </div>

            <div class="product-grid">

                <!-- DB 연동: productList를 기반으로 출력 -->
                <c:choose>
                    <c:when test="${empty productList}">
                        <p style="font-size:13px; color:#9ca3af; margin-top:8px;">
                            아직 등록된 상품이 없습니다. 첫 번째 중고상품의 주인이 되어보세요!
                        </p>
                    </c:when>
                    <c:otherwise>
                        <c:forEach var="item" items="${productList}">
                            <article class="product-card">
                                <div class="product-thumb">
                                    <div class="product-tag">${item.category}</div>

                                    <c:choose>
                                        <c:when test="${item.status == 'ON_SALE'}">
                                            <div class="product-status">판매중</div>
                                        </c:when>
                                        <c:when test="${item.status == 'RESERVED'}">
                                            <div class="product-status" style="background: rgba(234, 179, 8, 0.95); color:#111827;">
                                                예약중
                                            </div>
                                        </c:when>
                                        <c:when test="${item.status == 'SOLD_OUT'}">
                                            <div class="product-status" style="background: rgba(107, 114, 128, 0.95);">
                                                거래완료
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <div class="product-status">판매중</div>
                                        </c:otherwise>
                                    </c:choose>

                                    <c:choose>
                                        <c:when test="${not empty item.thumbnailUrl}">
                                            <img src="${item.thumbnailUrl}" alt="${item.title}">
                                        </c:when>
                                        <c:otherwise>
                                            이미지 영역
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="product-info-main">
                                    <div>
                                        <h3 class="product-title">${item.title}</h3>
                                        <p class="product-meta">
                                            ${item.campus}
                                            <c:if test="${not empty item.meetingTime}">
                                                · ${item.meetingTime}
                                            </c:if>
                                        </p>
                                    </div>
                                    <div class="product-price">
                                        <fmt:formatNumber value="${item.price}" type="number" />원
                                    </div>
                                </div>
                                <div class="product-extra">
                                    <span>찜 ${item.wishCount} · 채팅 ${item.chatCount}</span>
                                    <span class="chip">
                                        <c:choose>
                                            <c:when test="${not empty item.meetingPlace}">
                                                ${item.meetingPlace}
                                            </c:when>
                                            <c:otherwise>
                                                직거래 / 택배
                                            </c:otherwise>
                                        </c:choose>
                                    </span>
                                </div>
                                <div class="product-actions">
                                    <button class="btn-xs"
                                            onclick="location.href='/market/detail?id=${item.id}'">
                                        상세보기
                                    </button>
                                    <c:choose>
                                        <c:when test="${item.status == 'SOLD_OUT'}">
                                            <button class="btn-xs-primary"
                                                    onclick="location.href='/market/review/write?id=${item.id}'">
                                                후기 남기기
                                            </button>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn-xs-primary"
                                                    onclick="location.href='/chat/start?itemId=${item.id}'">
                                                채팅으로 거래하기
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </article>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>

            </div>
        </section>

        <!-- 오른쪽 사이드 영역 (초기 디자인 그대로) -->
        <aside>

            <!-- 나의 거래 현황 -->
            <section class="card side-card">
                <div class="card-header">
                    <div>
                        <div class="card-title">나의 거래 현황</div>
                        <div class="card-subtitle">로그인 시 판매/구매 진행 상태를 한 눈에 볼 수 있어요.</div>
                    </div>
                    <div class="badge">로그인 필요</div>
                </div>
                <div class="status-list">
                    <div class="status-row">
                        <div class="status-label">
                            <span>판매 중</span>
                            <span>현재 공개 중인 판매 글</span>
                        </div>
                        <div class="status-value">0건</div>
                    </div>
                    <div class="status-row">
                        <div class="status-label">
                            <span>예약 중</span>
                            <span>거래 시간만 조율하면 돼요</span>
                        </div>
                        <div class="status-value">0건</div>
                    </div>
                    <div class="status-row">
                        <div class="status-label">
                            <span>거래 완료</span>
                            <span>후기 남기고 신뢰도를 올려보세요</span>
                        </div>
                        <div class="status-value">0건</div>
                    </div>
                </div>
            </section>

            <!-- 인기 키워드 -->
            <section class="card side-card">
                <div class="card-header">
                    <div>
                        <div class="card-title">실시간 인기 키워드</div>
                        <div class="card-subtitle">최근 24시간 기준 검색량이 많은 키워드입니다.</div>
                    </div>
                    <div class="card-link">전체 랭킹</div>
                </div>
                <div class="keyword-list">
                    <button class="keyword hot">아이패드</button>
                    <button class="keyword hot">운영체제 교재</button>
                    <button class="keyword">기숙사 의자</button>
                    <button class="keyword">노트북 거치대</button>
                    <button class="keyword">공학용 계산기</button>
                    <button class="keyword">전자 면도기</button>
                </div>
            </section>

            <!-- 빠른 카테고리 -->
            <section class="card side-card">
                <div class="card-header">
                    <div>
                        <div class="card-title">빠른 카테고리</div>
                        <div class="card-subtitle">자주 거래되는 카테고리만 모아봤어요.</div>
                    </div>
                </div>
                <div class="quick-category">
                    <button>
                        교재 · 전공책
                        <span>교양부터 전공까지</span>
                    </button>
                    <button>
                        전자기기
                        <span>노트북, 태블릿, 주변기기</span>
                    </button>
                    <button>
                        자취템
                        <span>가구, 주방, 생활용품</span>
                    </button>
                    <button>
                        패션 · 잡화
                        <span>후드, 패딩, 가방</span>
                    </button>
                </div>
            </section>

        </aside>
    </section>

    <!-- 푸터 -->
    <footer class="footer">
        © 2025 KangnamTime. JSP Web Programming Team Project. All rights reserved.
    </footer>

</main>

<!-- 글쓰기 플로팅 버튼 -->
<button class="floating-write-btn" onclick="location.href='<%= ctx %>/market/write.jsp'">
    <span class="icon">✏️</span>
    중고상품 글쓰기
</button>

</body>
</html>
