<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>

<%
    /* ===============================
       1) 시간표 기본 설정
       =============================== */
    int[] times = {540,600,660,720,780,840,900,960,1020}; 
    boolean[][] drawn = new boolean[times.length][5];  // 월~금

    /* ===============================
       2) 강의 데이터 받기
       (List<Map<String,Object>> 구조)
       예: title, day(0~4), start, end, location
       =============================== */
    List<Map<String,Object>> lectures =
        (List<Map<String,Object>>)request.getAttribute("lectures");

    if (lectures == null) {
        lectures = new ArrayList<>();
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
    margin: 30px auto;
    max-width: 1050px;
    padding: 28px;
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
    font-size: 23px;
    color: #E2E8F0;
}

.btn {
    padding: 8px 18px;
    border-radius: 999px;
    background: #1E293B;
    border: 1px solid #2B3547;
    color: #E9EEF7;
    cursor: pointer;
    font-size: 14px;
}
.btn:hover { background: #273445; }

.back-btn {
    background: #1E293B;
    border: 1px solid #2B3547;
    color: #E9EEF7;
    margin-bottom: 15px;
    padding: 6px 14px;
    border-radius: 999px;
    cursor: pointer;
}
.back-btn:hover { background: #273445; }

.info-text {
    color: #7A8AAA;
    margin-top: 5px;
    font-size: 12px;
}

.timetable-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 20px;
}

.timetable-table th {
    background: #111827;
    color: #9CA3AF;
    padding: 10px;
    border: 1px solid #273244;
    font-size: 13px;
}

.timetable-table td {
    border: 1px solid #1F2533;
    height: 68px;
    position: relative;
    background: transparent;
}

.subject-box {
    display: inline-block;
    padding: 4px 7px;
    border-radius: 10px;
    font-size: 12px;
    color: #EDEDED;
    background: rgba(0,0,0,0.0);
    border: 1px solid #D9D16F;
    white-space: nowrap;
}
.sub-loc {
    font-size: 10px;
    opacity: 0.85;
}
</style>
</head>

<body>

<jsp:include page="/common/gnb.jsp" />

<div class="timetable-panel">

    <button class="back-btn" onclick="location.href='calendarMain.jsp'">← 캘린더로 돌아가기</button>

    <div class="title-row">
        <h2>시간표</h2>
        <button class="btn" onclick="location.href='ecampusSync.jsp'">
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
                        Map<String,Object> target = null;

                        for (Map<String,Object> L : lectures) {
                            int d = (int)L.get("day");
                            int st = (int)L.get("start");
                            int en = (int)L.get("end");
                            if (d == day && st <= times[i] && en > times[i])
                                target = L;
                        }

                        if (target == null) {
                    %>
                        <td></td>

                    <% } else {
                        int duration = (int)target.get("end") - (int)target.get("start");
                        int rowspan = (int)Math.ceil(duration / 60.0);

                        for (int k=0; k<rowspan && i+k<times.length; k++)
                            drawn[i+k][day] = true;
                    %>

                        <td rowspan="<%= rowspan %>">
                            <div class="subject-box">
                                <%= target.get("title") %><br>
                                <span style="font-size:11px;">
                                    <%= String.format("%02d:%02d ~ %02d:%02d",
                                        ((int)target.get("start"))/60, ((int)target.get("start"))%60,
                                        ((int)target.get("end"))/60, ((int)target.get("end"))%60 ) %>
                                </span><br>
                                <span class="sub-loc"><%= target.get("location") %></span>
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
