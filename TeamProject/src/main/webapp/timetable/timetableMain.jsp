<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page import="java.util.*" %>
<%@ page import="crawler.TimetableCrawler.Lecture" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8");

    String userId = (String)session.getAttribute("userId");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../login.jsp';</script>");
        return;
    }
 
    int[] times = {540,600,660,720,780,840,900,960,1020};
    boolean[][] drawn = new boolean[times.length][5];

    List<Lecture> lectures = new ArrayList<>();

    // --- DB에서 시간표 불러오기 ---
    try (Connection conn = DBUtil.getConnection();
         PreparedStatement pstmt = conn.prepareStatement(
             "SELECT TITLE, PROFESSOR, DAY, START_MIN, END_MIN " +
             "FROM USER_TIMETABLE WHERE USER_ID = ? ORDER BY DAY, START_MIN")) {

        pstmt.setString(1, userId);

        try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Lecture L = new Lecture();
                L.title = rs.getString("TITLE");
                L.professor = rs.getString("PROFESSOR");
                L.day = rs.getInt("DAY");
                L.start = rs.getInt("START_MIN");
                L.end = rs.getInt("END_MIN");
                lectures.add(L);
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>시간표</title>

<style>
/* 전체 다크 테마 */

body {
    margin: 0;
    background: #0B1120;
    color: #E2E8F0;
    font-family: -apple-system, BlinkMacSystemFont, 'Noto Sans KR', sans-serif;
}

.timetable-panel {
    margin: 20px auto;
    max-width: 900px;          /* 전체 너비 더 컴팩트하게 줄임 */
    padding: 24px;
    border-radius: 18px;
    background: #111827;
    border: 1px solid #273244;
}

/* 제목줄 */
.title-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.title-row h2 {
    margin: 0;
    font-size: 21px;
    color: #E2E8F0;
}

.btn {
    padding: 7px 16px;
    border-radius: 999px;
    background: #1E293B;
    border: 1px solid #2B3547;
    color: #E9EEF7;
    cursor: pointer;
    font-size: 13px;
}
.btn:hover { background: #273445; }

.info-text {
    color: #7A8AAA;
    margin-top: 5px;
    font-size: 11px;
}

/* 테이블 전체 고정 레이아웃 – 열 너비가 안정됨 */
.timetable-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 20px;
    table-layout: fixed;   /* 💥 중요 */
}

/* 시간 칸(제일 왼쪽)은 70px 고정 */
.timetable-table th:first-child,
.timetable-table td:first-child {
    width: 70px !important;
}

/* 요일 칸 5개는 동일한 비율로 분배 */
.timetable-table th:not(:first-child),
.timetable-table td:not(:first-child) {
    width: calc((100% - 70px) / 5) !important;
}


.timetable-table th {
    background: #111827;
    color: #9CA3AF;
    padding: 8px;
    border: 1px solid #273244;
    font-size: 12px;
}

.timetable-table td {
    border: 1px solid #1F2533;
    height: 80px;               /* 칸 높이 줄임 */
    padding: 0;
    position: relative;
    background: transparent;
    overflow: visible;          /* 박스 잘림 방지 */
}

/* 강의 박스 — 테이블 구조를 망가뜨리지 않는 방식 */
.subject-box {
    position: absolute;
    top: 6%;               /* 박스를 위쪽으로 */
    left: 6%;              /* 박스를 왼쪽으로 */
    width: 88%;            /* 전체 셀보다 조금 작게 */
    height: 88%;           /* 세로도 여유 있게 축소 */

    padding: 10px 12px;

    background: rgba(255,255,255,0.06);
    border: 1.5px solid rgba(255,255,255,0.18);
    border-radius: 14px;
    box-sizing: border-box;

    font-size: 12px;
    line-height: 1.4;
    color: #EDEDED;

    display: flex;
    flex-direction: column;
    justify-content: flex-start;   /* 내용 위쪽 정렬 */
}


.subject-box:hover {
    border-color: rgba(58, 129, 255, 0.8);
    background: rgba(58, 129, 255, 0.15);
}


.sub-prof {
    font-size: 9.5px;
    color: #9DA9BC;
    margin-bottom: 2px;
}

</style>
</head>

<body>

<jsp:include page="/common/gnb.jsp" />

<div class="timetable-panel">

    <div class="title-row">
        <h2>시간표</h2>

        <button class="btn" onclick="location.href='../calendar/timetableSync.jsp'">
            🔄 강남대 시간표 연동
        </button>
    </div>

    <div class="info-text">* 강남대학교 수강신청 데이터를 기반으로 구성됩니다.</div>

    <table class="timetable-table">
        <thead>
        <tr>
            <th>시간</th>
            <th>월</th>
            <th>화</th>
            <th>수</th>
            <th>목</th>
            <th>금</th>
        </tr>
        </thead>

        <tbody>
        <% for (int i=0; i<times.length; i++) { %>
            <tr>
                <th><%= String.format("%02d:00", times[i]/60) %></th>

                <% for (int day=0; day<5; day++) { %>

                    <% if (drawn[i][day]) continue; %>

                    <%
                        Lecture target = null;

                        for (Lecture L : lectures) {
                            if (L.day == day && L.start <= times[i] && L.end > times[i]) {
                                target = L;
                                break;
                            }
                        }

                        if (target == null) {
                    %>
                        <td></td>

                    <% } else {
                        int duration = target.end - target.start;
                        int rowspan = (int)Math.ceil(duration / 60.0);

                        for (int k=0; k<rowspan && i+k<times.length; k++)
                            drawn[i+k][day] = true;
                    %>

                        <td rowspan="<%= rowspan %>">
                           
                                <div class="subject-box">
								    <div class="lecture-title"><%= target.title %></div>
								
								    <div class="lecture-time">
								        <%= String.format("%02d:%02d ~ %02d:%02d",
								            target.start/60, target.start%60,
								            target.end/60, target.end%60) %>
								    </div>
								
								    <div class="lecture-prof sub-prof"><%= target.professor %></div>
								</div>

                            </div>
                        </td>

                    <% } %>

                <% } %>
            </tr>
        <% } %>
        </tbody>
    </table>
</div>

</body>
</html>
