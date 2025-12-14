<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>

<%!
    public String h(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    request.setCharacterEncoding("UTF-8");
    request.setAttribute("currentMenu", "home");

    String ctx = request.getContextPath();
    String userId = (String) session.getAttribute("userId");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>강남타임 - 메인</title>

    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans KR", sans-serif;
            background: #0f172a;
            color: #e5e7eb;
        }
        a { text-decoration: none; color: inherit; }

        main {
            max-width: 1100px;
            margin: 0 auto;
            padding: 32px 20px 60px;
            display: grid;
            grid-template-columns: 2fr 3fr;
            gap: 32px;
        }

        .left-panel { display: flex; flex-direction: column; gap: 20px; }

        .welcome-card {
            border-radius: 18px;
            padding: 20px 18px;
            background: radial-gradient(circle at top left, #1d283a, #020617);
            border: 1px solid rgba(148, 163, 184, 0.5);
        }
        .welcome-title { font-size: 22px; font-weight: 700; margin-bottom: 6px; }
        .welcome-sub { font-size: 13px; color: #9ca3af; line-height: 1.5; }
        .welcome-highlight { color: #38bdf8; font-weight: 600; }

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
        .notice-list li:last-child { border-bottom: none; }
        .notice-title {
            max-width: 250px;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }
        .notice-date { font-size: 11px; color: #9ca3af; margin-left: 10px; }

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
        .menu-tag { font-size: 11px; color: #9ca3af; margin-bottom: 4px; }
        .menu-title { font-size: 16px; font-weight: 600; margin-bottom: 6px; }
        .menu-desc { font-size: 12px; color: #9ca3af; line-height: 1.4; margin-bottom: 8px; }
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

        footer {
            border-top: 1px solid rgba(31, 41, 55, 0.9);
            padding: 16px 20px 30px;
            font-size: 11px;
            color: #6b7280;
            text-align: center;
        }

        @media (max-width: 900px) {
            main { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<jsp:include page="/common/gnb.jsp"/>

<main>
    <section class="left-panel">
        <div class="welcome-card">
            <div class="welcome-title">
                강남대 전용 시간·과제·통학 <span class="welcome-highlight">올인원</span>
            </div>
            <div class="welcome-sub">
                에브리타임 + e캠퍼스 + 달구지 정보를
                한 화면에서 관리하는 강남대 학생 전용 플랫폼입니다.
            </div>
        </div>

        
        <div class="notice-card">
            <div class="notice-header">
                <span>📢 공지사항</span>
                <span><a href="<%= ctx %>/notice/noticeMain.jsp">더보기 ›</a></span>
            </div>

            <ul class="notice-list">
                <%
                    String sql =
                        "SELECT NOTICE_NO, TITLE, " +
                        "       DATE_FORMAT(CREATED_AT, '%Y-%m-%d') AS CREATED_AT " +
                        "FROM BOARD_NOTICE " +
                        "ORDER BY NOTICE_NO DESC " +
                        "LIMIT 3";

                    boolean hasNotice = false;

                    try (Connection conn = DBUtil.getConnection();
                         PreparedStatement pstmt = conn.prepareStatement(sql);
                         ResultSet rs = pstmt.executeQuery()) {

                        while (rs.next()) {
                            hasNotice = true;
                            int noticeNo = rs.getInt("NOTICE_NO");
                            String title = rs.getString("TITLE");
                            String createdAt = rs.getString("CREATED_AT");

                            String viewUrl = ctx + "/notice/noticeView.jsp?noticeNo=" + noticeNo;
                %>
                    <li>
                        <span class="notice-title">
                            <a href="<%= viewUrl %>"><%= h(title) %></a>
                        </span>
                        <span class="notice-date"><%= createdAt %></span>
                    </li>
                <%
                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                %>
                    <li>
                        <span class="notice-title">공지사항을 불러오는 중 오류가 발생했습니다.</span>
                        <span class="notice-date"></span>
                    </li>
                <%
                    }

                    if (!hasNotice) {
                %>
                    <li>
                        <span class="notice-title">등록된 공지사항이 없습니다.</span>
                        <span class="notice-date"></span>
                    </li>
                <%
                    }
                %>
            </ul>
        </div>
    </section>

    <section>
        <div class="menu-grid">

            <a href="<%= ctx %>/board/mainBoard.jsp" class="menu-card">
                <div>
                    <div class="menu-tag">BOARD</div>
                    <div class="menu-title">게시판</div>
                    <div class="menu-desc">
                        메인 게시판에서 실시간 학교 이야기 확인하고<br>
                        소통해보세요
                    </div>
                </div>
                <div class="menu-footer">
                    <span class="pill">메인 · 핫게시판</span>
                    <span>실시간 인기글</span>
                </div>
            </a>

            <a href="<%= ctx %>/calendar/calendarMain.jsp" class="menu-card">
                <div>
                    <div class="menu-tag">TIMETABLE</div>
                    <div class="menu-title">시간표</div>
                    <div class="menu-desc">
                        기본 시간표 관리 +
                        이러닝캡퍼스에 연동된 계정을<br>통해 시간표를 불러옵니다.
                    </div>
                </div>
                <div class="menu-footer">
                    <span class="pill">AI 시간표 자동 생성</span>
                    <span>에타·강남타임 강의평 분석</span>
                </div>
            </a>

            <a href="<%= ctx %>/calendar/assignmentScheduler.jsp" class="menu-card">
                <div>
                    <div class="menu-tag">AI SCHEDULER</div>
                    <div class="menu-title">AI 과제 스케쥴러</div>
                    <div class="menu-desc">
                        e캠퍼스 과제를 자동으로 불러와
                        마감일까지 캘린더에 표시하고, 가장 급한 순으로 정렬해 보여줍니다.
                    </div>
                </div>
                <div class="menu-footer">
                    <span class="pill">마감 임박 순 정렬</span>
                    <span>e캠퍼스 파싱</span>
                </div>
            </a>

            <a href="<%= ctx %>/dalguji/dalgujiMain.jsp" class="menu-card">
                <div>
                    <div class="menu-tag">DALGUJI</div>
                    <div class="menu-title">달구지 시간표 & 현황</div>
                    <div class="menu-desc">
                        요일별 달구지 시간표 이미지를 확인하고,
                        유비칸 차량 관제를 통해 실시간 위치를 지도에서 확인합니다.
                    </div>
                </div>
                <div class="menu-footer">
                    <span class="pill">실시간 위치 표시</span>
                    <span>월·금 / 화·수·목 분리</span>
                </div>
            </a>

            <a href="<%= ctx %>/settings/settings.jsp" class="menu-card">
                <div>
                    <div class="menu-tag">SETTINGS</div>
                    <div class="menu-title">계정 & 연동 설정</div>
                    <div class="menu-desc">
                        에브리타임, 강남대 포털, e캠퍼스 계정을 저장해두고
                        위 모든 AI 기능들이 자동으로 연동되도록 설정합니다.
                    </div>
                </div>
                <div class="menu-footer">
                    <span class="pill">계정 연동 필수</span>
                    <span>보안 저장</span>
                </div>
            </a>

            <a href="<%= ctx %>/market/marketMain.jsp" class="menu-card">
                <div>
                    <div class="menu-tag">KANGNAM MARKET</div>
                    <div class="menu-title">강남 마켓</div>
                    <div class="menu-desc">
                        강남대 학생 전용 중고 거래 마켓입니다.
                        교재·전자기기·생활용품 등을 안전하게 사고팔아 보세요.
                    </div>
                </div>
                <div class="menu-footer">
                    <span class="pill">상품 보기</span>
                    <span>판매글</span>
                </div>
            </a>

        </div>
    </section>
</main>

<footer>
    © 2025 강남타임 (JSP Web Programming Project).
</footer>

</body>
</html>
