<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userId   = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    String ctx      = request.getContextPath();

    String currentMenu = (String) request.getAttribute("currentMenu");
    if (currentMenu == null) currentMenu = "";
%>

<style>
    header.gnb-header {
        position: sticky;
        top: 0;
        z-index: 10;
        background: rgba(15, 23, 42, .96);
        border-bottom: 1px solid rgba(31, 41, 55, .9);
        backdrop-filter: blur(10px);
    }

    .gnb-inner {
        max-width: 1180px;
        margin: 0 auto;
        padding: 12px 24px;
        display: flex;
        align-items: center;
        justify-content: space-between;
    }

    /* 왼쪽 로고 */
    .gnb-left {
        display: flex;
        align-items: center;
        gap: 10px;
        cursor: pointer;
    }
    .gnb-logo-mark {
        width: 28px;
        height: 28px;
        border-radius: 999px;
        border: 2px solid #38bdf8;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        color: #38bdf8;
    }
    .gnb-logo-text {
        font-weight: 700;
        font-size: 18px;
        color: #e5e7eb;
    }

    /* 가운데 탭 메뉴 */
    .gnb-center {
        display: flex;
        align-items: center;
        gap: 26px;
    }
    .gnb-center a {
        position: relative;
        padding: 6px 4px;
        text-decoration: none;
        color: #cbd5f5;
        font-size: 15px;
        transition: color .2s ease;
    }
    .gnb-center a:hover {
        color: #ffffff;
    }

    /* 밑줄 효과 */
    .gnb-center a::after {
        content: "";
        position: absolute;
        left: 50%;
        transform: translateX(-50%);
        bottom: -3px;
        width: 0;
        height: 2px;
        border-radius: 999px;
        background: linear-gradient(90deg, #38bdf8, #6366f1);
        transition: width .18s ease;
    }
    .gnb-center a:hover::after {
        width: 40%;
    }
    .gnb-center a.gnb-active {
        color: #ffffff;
        font-weight: 600;
    }
    .gnb-center a.gnb-active::after {
        width: 60%;
        height: 2px;
    }

    /* 오른쪽 계정 영역 */
    .gnb-right {
        display: flex;
        align-items: center;
        gap: 10px;
        font-size: 13px;
    }
    .gnb-btn-outline,
    .gnb-btn-primary {
        border-radius: 999px;
        padding: 6px 12px;
        font-size: 13px;
        cursor: pointer;
        border: none;
        transition: opacity .2s ease;
    }
    .gnb-btn-outline {
        background: transparent;
        border: 1px solid rgba(148, 163, 184, .7);
        color: #e5e7eb;
    }
    .gnb-btn-outline:hover {
        background: rgba(148,163,184,.18);
    }
    .gnb-btn-primary {
        background: linear-gradient(135deg, #38bdf8, #6366f1);
        color: #0b1120;
        font-weight: 600;
    }
    .gnb-btn-primary:hover {
        opacity: .93;
    }
</style>

<header class="gnb-header">
    <div class="gnb-inner">

        <!-- 왼쪽: 로고 -->
        <div class="gnb-left" onclick="location.href='<%= ctx %>/main.jsp'">
            <div class="gnb-logo-mark">KT</div>
            <div class="gnb-logo-text">강남타임</div>
        </div>

        <!-- 가운데: 탭 메뉴 -->
        <nav class="gnb-center">
            <a href="<%= ctx %>/main.jsp"
               class="<%= "home".equals(currentMenu) ? "gnb-active" : "" %>">홈</a>

            <a href="<%= ctx %>/board/mainBoard.jsp"
               class="<%= "board".equals(currentMenu) ? "gnb-active" : "" %>">게시판</a>

			<a href="<%= ctx %>/timetable/timetableMain.jsp"
               class="<%= "calendar".equals(currentMenu) ? "gnb-active" : "" %>">시간표</a>

            <a href="<%= ctx %>/calendar/calendarMain.jsp"
               class="<%= "timetable".equals(currentMenu) ? "gnb-active" : "" %>">캘린더</a>

            <a href="<%= ctx %>/dalguji/dalgujiMain.jsp"
               class="<%= "dalguji".equals(currentMenu) ? "gnb-active" : "" %>">달구지</a>

            <a href="<%= ctx %>/settings/settings.jsp"
               class="<%= "settings".equals(currentMenu) ? "gnb-active" : "" %>">설정</a>
        </nav>

        <!-- 오른쪽: 로그인/회원정보 -->
        <div class="gnb-right">
            <%
                if (userId == null) {
            %>
                <button class="gnb-btn-outline"
                        onclick="location.href='<%= ctx %>/login.jsp'">로그인</button>
                <button class="gnb-btn-primary"
                        onclick="location.href='<%= ctx %>/signup.jsp'">회원가입</button>
            <%
                } else {
            %>
                <span><strong><%= (userName != null ? userName : userId) %></strong> 님</span>
                <button class="gnb-btn-outline"
                        onclick="location.href='<%= ctx %>/mypage/mypage.jsp'">마이페이지</button>
                <button class="gnb-btn-primary"
                        onclick="location.href='<%= ctx %>/logout.jsp'">로그아웃</button>
            <%
                }
            %>
        </div>

    </div>
</header>
