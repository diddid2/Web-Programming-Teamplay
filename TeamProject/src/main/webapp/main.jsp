<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userId = (String) session.getAttribute("userId");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>강남 타임 - 메인</title>

    <!-- 기본 리셋 & 폰트 -->
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans KR", sans-serif;
            background: #0f172a;
            color: #e5e7eb;
        }

        a {
            text-decoration: none;
            color: inherit;
        }

        /* 상단 네비게이션 */
        header {
            position: sticky;
            top: 0;
            z-index: 10;
            background: rgba(15, 23, 42, 0.9);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid rgba(148, 163, 184, 0.4);
        }
        .nav-inner {
            max-width: 1100px;
            margin: 0 auto;
            padding: 12px 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }
        .logo {
            display: flex;
            align-items: center;
            gap: 8px;
            font-weight: 700;
            font-size: 20px;
        }
        .logo-mark {
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
        .nav-links {
            display: flex;
            align-items: center;
            gap: 18px;
            font-size: 14px;
            color: #cbd5f5;
        }
        .nav-links a {
            padding: 6px 10px;
            border-radius: 999px;
            transition: background 0.2s ease, color 0.2s ease;
        }
        .nav-links a:hover {
            background: rgba(148, 163, 184, 0.15);
            color: #f9fafb;
        }
        .nav-auth {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 13px;
        }
        .btn-outline {
            padding: 6px 12px;
            border-radius: 999px;
            border: 1px solid rgba(148, 163, 184, 0.7);
            background: transparent;
            color: #e5e7eb;
            cursor: pointer;
        }
        .btn-primary {
            padding: 6px 14px;
            border-radius: 999px;
            border: none;
            background: linear-gradient(135deg, #38bdf8, #6366f1);
            color: #0b1120;
            font-weight: 600;
            cursor: pointer;
        }
        .btn-outline:hover {
            background: rgba(148, 163, 184, 0.15);
        }
        .btn-primary:hover {
            opacity: 0.9;
        }

        /* 메인 컨테이너 */
        main {
            max-width: 1100px;
            margin: 0 auto;
            padding: 32px 20px 60px;
            display: grid;
            grid-template-columns: 2fr 3fr;
            gap: 32px;
        }

        /* 왼쪽 영역: 인사 + 공지 + 빠른 메뉴 */
        .left-panel {
            display: flex;
            flex-direction: column;
            gap: 20px;
        }
        .welcome-card {
            border-radius: 18px;
            padding: 20px 18px;
            background: radial-gradient(circle at top left, #1d283a, #020617);
            border: 1px solid rgba(148, 163, 184, 0.5);
        }
        .welcome-title {
            font-size: 22px;
            font-weight: 700;
            margin-bottom: 6px;
        }
        .welcome-sub {
            font-size: 13px;
            color: #9ca3af;
        }
        .welcome-highlight {
            color: #38bdf8;
            font-weight: 600;
        }
        .notice-card {
            border-radius: 16px;
            padding: 14px 16px;
            background: #020617;
            border: 1px solid rgba(148, 163, 184, 0.4);
        }
        .notice-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 13px;
            margin-bottom: 8px;
            color: #e5e7eb;
        }
        .notice-header span:last-child {
            font-size: 12px;
            color: #9ca3af;
        }
        .notice-list {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 4px;
            font-size: 13px;
        }
        .notice-list li {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 4px 0;
            border-bottom: 1px dashed rgba(31, 41, 55, 0.8);
        }
        .notice-list li:last-child {
            border-bottom: none;
        }
        .notice-title {
            max-width: 250px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .notice-date {
            font-size: 11px;
            color: #9ca3af;
            margin-left: 10px;
        }

        /* 오른쪽: 메인 메뉴 카드 그리드 */
        .menu-grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 16px;
        }
        .menu-card {
            padding: 16px 16px 18px;
            border-radius: 18px;
            border: 1px solid rgba(148, 163, 184, 0.4);
            background: radial-gradient(circle at top left, #1f2937, #020617);
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            cursor: pointer;
            transition: transform 0.13s ease, box-shadow 0.13s ease, border-color 0.13s ease;
        }
        .menu-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 14px 30px rgba(15, 23, 42, 0.8);
            border-color: #38bdf8;
        }
        .menu-tag {
            font-size: 11px;
            color: #9ca3af;
            margin-bottom: 4px;
        }
        .menu-title {
            font-size: 16px;
            font-weight: 600;
            margin-bottom: 6px;
        }
        .menu-desc {
            font-size: 12px;
            color: #9ca3af;
            line-height: 1.4;
            margin-bottom: 8px;
        }
        .menu-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            font-size: 11px;
            color: #a5b4fc;
        }
        .pill {
            display: inline-flex;
            align-items: center;
            padding: 3px 9px;
            border-radius: 999px;
            border: 1px solid rgba(129, 140, 248, 0.8);
            font-size: 11px;
        }

        /* 하단 푸터 */
        footer {
            border-top: 1px solid rgba(31, 41, 55, 0.9);
            padding: 16px 20px 30px;
            font-size: 11px;
            color: #6b7280;
            text-align: center;
        }

        @media (max-width: 900px) {
            main {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>

<header>
    <div class="nav-inner">
        <div class="logo">
            <div class="logo-mark">KT</div>
            <span>KangnamTime</span>
        </div>
        <nav class="nav-links">
            <a href="main.jsp">홈</a>
            <a href="timetable.jsp">시간표</a>
            <a href="board_list.jsp">게시판</a>
            <a href="review_list.jsp">강의평가</a>
            <a href="campus_info.jsp">캠퍼스 정보</a>
        </nav>
        <div class="nav-auth">
            <%
                if (userId == null) {
            %>
                <button class="btn-outline" onclick="location.href='login.jsp'">로그인</button>
                <button class="btn-primary" onclick="location.href='signup.jsp'">회원가입</button>
            <%
                } else {
            %>
                <span><strong><%= userId %></strong> 님</span>
                <button class="btn-outline" onclick="location.href='mypage.jsp'">마이페이지</button>
                <button class="btn-primary" onclick="location.href='logout.jsp'">로그아웃</button>
            <%
                }
            %>
        </div>
    </div>
</header>

<main>
    <!-- 왼쪽 -->
    <section class="left-panel">
        <div class="welcome-card">
            <div class="welcome-title">
                오늘도 <span class="welcome-highlight">강남 타임</span>에서
            </div>
            <div class="welcome-sub">
                시간표 관리부터 강의평, 자유게시판까지  
                한 곳에서 정리하는 우리 학교 전용 커뮤니티.
            </div>
        </div>

        <div class="notice-card">
            <div class="notice-header">
                <span>📢 공지사항</span>
                <span><a href="notice_list.jsp">더보기 ›</a></span>
            </div>
            <ul class="notice-list">
                <li>
                    <span class="notice-title"><a href="notice_view.jsp?id=1">[점검] 새벽 3시~4시 서비스 점검 안내</a></span>
                    <span class="notice-date">2025-11-13</span>
                </li>
                <li>
                    <span class="notice-title"><a href="notice_view.jsp?id=2">2학기 중간고사 시험후기 게시판 오픈</a></span>
                    <span class="notice-date">2025-10-21</span>
                </li>
                <li>
                    <span class="notice-title"><a href="notice_view.jsp?id=3">프로젝트 팀원 모집 탭이 추가되었어요</a></span>
                    <span class="notice-date">2025-09-30</span>
                </li>
            </ul>
        </div>
    </section>

    <!-- 오른쪽: 메인 메뉴 -->
    <section>
        <div class="menu-grid">

            <a href="timetable.jsp" class="menu-card">
                <div>
                    <div class="menu-tag">TIME TABLE</div>
                    <div class="menu-title">시간표 관리</div>
                    <div class="menu-desc">
                        학기별 시간표를 등록하고  
                        요일·교시별로 한눈에 확인해보세요.
                    </div>
                </div>
                <div class="menu-footer">
                    <span class="pill">+ 새 강의 추가</span>
                    <span>최근 수정: 오늘</span>
                </div>
            </a>

            <a href="board_list.jsp" class="menu-card">
                <div>
                    <div class="menu-tag">COMMUNITY</div>
                    <div class="menu-title">자유·정보 게시판</div>
                    <div class="menu-desc">
                        과제, 진로, 잡담까지  
                        같은 학교 학생들과 이야기를 나눠보세요.
                    </div>
                </div>
                <div class="menu-footer">
                    <span class="pill">실시간 인기글</span>
                    <span>새 글 12개</span>
                </div>
            </a>

            <a href="review_list.jsp" class="menu-card">
                <div>
                    <div class="menu-tag">COURSE REVIEW</div>
                    <div class="menu-title">강의평가</div>
                    <div class="menu-desc">
                        수강 전 선배들의 강의평을 보고  
                        꿀강·지옥강을 미리 체크하세요.
                    </div>
                </div>
                <div class="menu-footer">
                    <span class="pill">평점별 정렬</span>
                    <span>리뷰 247개</span>
                </div>
            </a>

            <a href="campus_info.jsp" class="menu-card">
                <div>
                    <div class="menu-tag">CAMPUS LIFE</div>
                    <div class="menu-title">캠퍼스 생활 정보</div>
                    <div class="menu-desc">
                        학식·셔틀·도서관·동아리 등  
                        자주 쓰는 정보만 모아서 보여줍니다.
                    </div>
                </div>
                <div class="menu-footer">
                    <span class="pill">즐겨찾기 추가</span>
                    <span>업데이트 예정</span>
                </div>
            </a>

        </div>
    </section>
</main>

<footer>
    © 2025 KangnamTime. JSP Web Programming Team Project.
</footer>

</body>
</html>
