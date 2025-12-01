<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    request.setAttribute("currentMenu", "calendar");

    String loginUser = (String) session.getAttribute("userId");
    if (loginUser == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../login.jsp';</script>");
        return;
    }

    // ====== 오늘 기준 ======
    Calendar todayCal = Calendar.getInstance();
    int curYear  = todayCal.get(Calendar.YEAR);
    int curMonth = todayCal.get(Calendar.MONTH) + 1; // 1~12
    int curDay   = todayCal.get(Calendar.DAY_OF_MONTH);

    // ====== 보고 싶은 연/월 ======
    String yearParam  = request.getParameter("year");
    String monthParam = request.getParameter("month");

    int year, month;
    if (yearParam != null && monthParam != null) {
        year  = Integer.parseInt(yearParam);
        month = Integer.parseInt(monthParam);
    } else {
        year  = curYear;
        month = curMonth;
    }

    // month 범위 조정
    if (month <= 0) {
        month = 12;
        year -= 1;
    } else if (month >= 13) {
        month = 1;
        year += 1;
    }

    // ====== 이 달 정보 세팅 ======
    Calendar cal = Calendar.getInstance();
    cal.set(year, month - 1, 1);

    int firstDayOfWeek = cal.get(Calendar.DAY_OF_WEEK); // 1=일요일
    int lastDay        = cal.getActualMaximum(Calendar.DAY_OF_MONTH);

    // 이 달의 1일 ~ 말일 (DB용)
    Calendar startCal = (Calendar) cal.clone();
    startCal.set(Calendar.DAY_OF_MONTH, 1);
    startCal.set(Calendar.HOUR_OF_DAY, 0);
    startCal.set(Calendar.MINUTE, 0);
    startCal.set(Calendar.SECOND, 0);
    startCal.set(Calendar.MILLISECOND, 0);

    Calendar endCal = (Calendar) cal.clone();
    endCal.set(Calendar.DAY_OF_MONTH, lastDay);
    endCal.set(Calendar.HOUR_OF_DAY, 23);
    endCal.set(Calendar.MINUTE, 59);
    endCal.set(Calendar.SECOND, 59);
    endCal.set(Calendar.MILLISECOND, 999);

    long monthStartMs = startCal.getTimeInMillis();
    long monthEndMs   = endCal.getTimeInMillis();

    java.sql.Date monthStartDate = new java.sql.Date(monthStartMs);
    java.sql.Date monthEndDate   = new java.sql.Date(monthEndMs);

    // ====== 이 달과 겹치는 과제들을 "기간 정보"로 로딩 ======
    // 각 과제: START_DAY(이 달 기준 시작일), END_DAY(이 달 기준 끝일)
    List<Map<String, Object>> monthAssignments = new ArrayList<>();

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();

        String sql =
            "SELECT ASSIGN_NO, TITLE, COURSE_NAME, START_DATE, DUE_DATE, PRIORITY, " +
            "       IS_PASSED, LINK " +
            "FROM ASSIGNMENT " +
            "WHERE USER_ID = ? " +
            "  AND ( " +
            "        (START_DATE IS NULL AND DUE_DATE BETWEEN ? AND ?) " + // 시작일 없으면 마감일이 이 달에 있는 경우
            "     OR (START_DATE IS NOT NULL AND DUE_DATE IS NOT NULL " +  // 기간이 이 달과 겹치는 경우
            "         AND START_DATE <= ? AND DUE_DATE >= ?) " +
            "      ) " +
            "ORDER BY DUE_DATE ASC, PRIORITY DESC";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, loginUser);
        pstmt.setDate(2, monthStartDate);
        pstmt.setDate(3, monthEndDate);
        pstmt.setDate(4, monthEndDate);   // START_DATE <= monthEnd
        pstmt.setDate(5, monthStartDate); // DUE_DATE   >= monthStart
        rs = pstmt.executeQuery();

        while (rs.next()) {
            // ===== 오전 1시 이전 마감은 전날로 취급 =====
            Timestamp dbStartTs = rs.getTimestamp("START_DATE");
            Timestamp dbDueTs   = rs.getTimestamp("DUE_DATE");
            if (dbDueTs == null) continue;

            Calendar dueCal = Calendar.getInstance();
            dueCal.setTimeInMillis(dbDueTs.getTime());
            if (dueCal.get(Calendar.HOUR_OF_DAY) < 1) {
                // 00:xx 이면 전날로
                dueCal.add(Calendar.DAY_OF_MONTH, -1);
            }
            long rangeEndMs = dueCal.getTimeInMillis();

            long rangeStartMs;
            if (dbStartTs != null) {
                rangeStartMs = dbStartTs.getTime();
            } else {
                rangeStartMs = rangeEndMs; // 시작일 없으면 마감 기준
            }
            // ================================

            long dispStartMs = Math.max(rangeStartMs, monthStartMs);
            long dispEndMs   = Math.min(rangeEndMs,   monthEndMs);

            if (dispStartMs > dispEndMs) continue; // 실제로는 이 달과 안 겹침

            Calendar sCal = Calendar.getInstance();
            sCal.setTimeInMillis(dispStartMs);
            Calendar eCal = Calendar.getInstance();
            eCal.setTimeInMillis(dispEndMs);

            int startDayInMonth = sCal.get(Calendar.DAY_OF_MONTH);
            int endDayInMonth   = eCal.get(Calendar.DAY_OF_MONTH);

            Map<String, Object> item = new HashMap<>();
            item.put("ASSIGN_NO",   rs.getInt("ASSIGN_NO"));
            item.put("TITLE",       rs.getString("TITLE"));
            item.put("COURSE_NAME", rs.getString("COURSE_NAME"));
            item.put("PRIORITY",    rs.getInt("PRIORITY"));
            item.put("START_DAY",   startDayInMonth);
            item.put("END_DAY",     endDayInMonth);
            item.put("IS_PASSED",   rs.getInt("IS_PASSED"));
            item.put("LINK",        rs.getString("LINK"));

            monthAssignments.add(item);
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }

    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>캘린더 & 과제 스케쥴러 - 강남타임</title>
    <style>
        * { box-sizing:border-box; margin:0; padding:0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans KR", sans-serif;
            background:#0f172a;
            color:#e5e7eb;
        }
        a { text-decoration:none; color:inherit; }

        main {
            max-width: 1100px;
            margin: 24px auto 60px;
            padding: 0 20px;
            display:grid;
            grid-template-columns: minmax(0,2fr) minmax(0,1.4fr);
            gap:20px;
        }
        @media (max-width: 900px) {
            main {
                grid-template-columns: 1fr;
            }
        }

        /* 캘린더 패널 */
        .calendar-panel {
            border-radius:18px;
            border:1px solid rgba(55,65,81,.9);
            background:#020617;
            padding:16px 16px 18px;
        }
        .cal-header {
            display:flex;
            justify-content:space-between;
            align-items:center;
            margin-bottom:10px;
        }
        .cal-title {
            font-size:18px;
            font-weight:600;
        }
        .cal-title span {
            font-size:13px;
            color:#9ca3af;
            margin-left:6px;
        }
        .cal-nav button {
            border-radius:999px;
            border:none;
            background:#111827;
            color:#e5e7eb;
            padding:4px 8px;
            cursor:pointer;
            font-size:12px;
        }
        .cal-nav button:hover { background:#1f2937; }

        table.calendar {
            width:100%;
            border-collapse:collapse;
            table-layout:fixed;
            font-size:12px;
        }
        .calendar th, .calendar td {
            border:1px solid #111827;
        }
        .calendar th {
            text-align:center;
            padding:6px 0;
            font-size:11px;
            color:#9ca3af;
        }
        .day-cell {
            height:40px;
            vertical-align:top;
            padding:4px;
        }
        .day-cell-empty {
            background:#020617;
        }
        .day-number {
            font-size:12px;
            font-weight:600;
        }
        .day-number.today {
            color:#38bdf8;
        }

        /* 과제막대 행 - 위쪽으로 최대한 붙이기 */
        .cal-bar-row td {
            height:18px;
            padding:0 2px 1px;   /* 위쪽 패딩 0으로 빈 공간 최소화 */
            border-top:none;
            vertical-align:top;
            background:#020617;
        }
        .cal-bar-row td.empty {
            background:#020617;
        }
        .assign-bar {
            width:100%;
            border-radius:999px;
            padding:2px 6px;
            font-size:11px;
            overflow:hidden;
            text-overflow:ellipsis;
            white-space:nowrap;
            background:rgba(15,23,42,0.9);
            border:1px solid #4b5563;
            cursor:default;
            display:block;
        }
        .assign-bar.priority-1 {
            border-color:#facc15;
        }
        .assign-bar.priority-2 {
            border-color:#f97373;
        }
        /* 패스된 과제용 테두리 (우선순위보다 우선) */
        .assign-bar.passed {
            border-color:#16a34a !important;
        }

        /* 오른쪽 패널 */
        .side-panel {
            display:flex;
            flex-direction:column;
            gap:16px;
        }

        .card {
            border-radius:18px;
            border:1px solid rgba(55,65,81,.9);
            background:#020617;
            padding:14px 14px 16px;
        }
        .card-title {
            font-size:15px;
            font-weight:600;
            margin-bottom:4px;
        }
        .card-sub {
            font-size:11px;
            color:#9ca3af;
            margin-bottom:10px;
        }

        /* 과제 추가 폼 */
        .assign-form label {
            display:block;
            font-size:12px;
            margin-bottom:3px;
        }
        .assign-form input[type="text"],
        .assign-form input[type="date"],
        .assign-form select,
        .assign-form textarea {
            width:100%;
            border-radius:9px;
            border:1px solid #4b5563;
            background:#020617;
            color:#e5e7eb;
            font-size:12px;
            padding:6px 8px;
            margin-bottom:8px;
        }
        .assign-form textarea {
            resize:vertical;
            min-height:60px;
        }
        .assign-form input:focus,
        .assign-form select:focus,
        .assign-form textarea:focus {
            outline:none;
            border-color:#38bdf8;
        }
        .assign-form .btn-row {
            text-align:right;
            margin-top:6px;
        }
        .assign-form button {
            border-radius:999px;
            border:none;
            padding:7px 14px;
            background:linear-gradient(135deg,#38bdf8,#6366f1);
            color:#0b1120;
            font-size:12px;
            font-weight:600;
            cursor:pointer;
        }
        .assign-form button:hover { opacity:.93; }

        /* 급한 과제 리스트 */
        .urgent-list {
            max-height:270px;
            overflow-y:auto;
        }
        .urgent-item {
            padding:6px 4px;
            border-radius:10px;
            border:1px solid #111827;
            background:#020617;
            font-size:12px;
            margin-bottom:6px;
        }
        .urgent-item-header {
            display:flex;
            justify-content:space-between;
            align-items:center;
            margin-bottom:2px;
        }
        .urgent-title {
            font-weight:600;
        }
        .urgent-meta {
            font-size:11px;
            color:#9ca3af;
        }

        /* PASS 라벨 */
        .pass-label {
            display:inline-block;
            margin-left:6px;
            padding:2px 6px;
            border-radius:999px;
            font-size:10px;
            background:#16a34a;
            color:#ecfdf5;
        }

        /* 링크가 있는 urgent-item 클릭 스타일 */
        .urgent-item.clickable {
            cursor:pointer;
        }
        .urgent-item.clickable a.urgent-link {
            display:block;
            color:inherit;
            text-decoration:none;
        }
        .urgent-item.clickable a.urgent-link:hover {
            text-decoration:none;
            opacity:0.96;
        }

        /* 툴팁 */
        .assign-tooltip {
            position:fixed;
            z-index:9999;
            background:#020617;
            border:1px solid #4b5563;
            border-radius:10px;
            padding:8px 10px;
            font-size:11px;
            box-shadow:0 10px 30px rgba(15,23,42,0.7);
            display:none;
            max-width:260px;
            pointer-events:none;
        }
        .assign-tooltip .tt-title {
            font-weight:600;
            margin-bottom:2px;
        }
        .assign-tooltip .tt-course {
            color:#9ca3af;
            margin-bottom:2px;
        }
        .assign-tooltip .tt-range {
            color:#e5e7eb;
            margin-bottom:2px;
        }
        .assign-tooltip .tt-priority {
            color:#facc15;
        }
    </style>
</head>
<body>

<jsp:include page="/common/gnb.jsp" />

<main>
    <!-- 왼쪽: 달력 -->
    <section class="calendar-panel">
        <div class="cal-header">
            <div class="cal-title">
                <%= year %>년 <%= month %>월
                <span>캘린더</span>
            </div>
            <div class="cal-nav">
                <button onclick="location.href='calendarMain.jsp?year=<%= year %>&month=<%= (month-1) %>'">&lt; 이전달</button>
                <button onclick="location.href='calendarMain.jsp?year=<%= curYear %>&month=<%= curMonth %>'">오늘</button>
                <button onclick="location.href='calendarMain.jsp?year=<%= year %>&month=<%= (month+1) %>'">다음달 &gt;</button>
            </div>
        </div>

        <table class="calendar">
            <thead>
                <tr>
                    <th style="color:#fca5a5;">일</th>
                    <th>월</th>
                    <th>화</th>
                    <th>수</th>
                    <th>목</th>
                    <th>금</th>
                    <th style="color:#93c5fd;">토</th>
                </tr>
            </thead>
            <tbody>
            <%
                // 주 단위로 렌더링
                for (int week = 0; week < 6; week++) {
                    int weekStartDay = 1 - (firstDayOfWeek - 1) + week * 7; // 이 주의 일요일 날짜 (0 이하 or lastDay 초과 가능)
                    int weekEndDay   = weekStartDay + 6;

                    // 이 주 전체가 실제 달 범위랑 하나도 안 겹치면 스킵
                    if (weekStartDay > lastDay || weekEndDay < 1) {
                        continue;
                    }
            %>
                <!-- 날짜 행 -->
                <tr>
                    <%
                        for (int col = 0; col < 7; col++) {
                            int dayNum = weekStartDay + col;
                            if (dayNum < 1 || dayNum > lastDay) {
                    %>
                        <td class="day-cell day-cell-empty"></td>
                    <%
                            } else {
                                boolean isToday = (year == curYear && month == curMonth && dayNum == curDay);
                    %>
                        <td class="day-cell">
                            <div class="day-number <%= isToday ? "today" : "" %>"><%= dayNum %></div>
                        </td>
                    <%
                            }
                        }
                    %>
                </tr>
            <%
                    // === 이 주에 속하는 과제들만 모으기 ===
                    List<Map<String, Object>> weekList = new ArrayList<Map<String,Object>>();
                    for (Map<String, Object> a : monthAssignments) {
                        int sDay = (Integer)a.get("START_DAY");
                        int eDay = (Integer)a.get("END_DAY");
                        if (eDay < weekStartDay || sDay > weekEndDay) {
                            continue;
                        }
                        weekList.add(a);
                    }

                    // === lane(줄)별로 과제 배치 (겹치지 않게) ===
                    List<List<Map<String,Object>>> lanes = new ArrayList<List<Map<String,Object>>>();
                    for (Map<String,Object> a : weekList) {
                        int sDay = (Integer)a.get("START_DAY");
                        int eDay = (Integer)a.get("END_DAY");

                        boolean placed = false;
                        for (int li = 0; li < lanes.size() && !placed; li++) {
                            List<Map<String,Object>> lane = lanes.get(li);
                            boolean conflict = false;
                            for (Map<String,Object> b : lane) {
                                int bs = (Integer)b.get("START_DAY");
                                int be = (Integer)b.get("END_DAY");
                                // 날짜 범위가 겹치면 같은 줄에 배치 불가
                                if (!(eDay < bs || sDay > be)) {
                                    conflict = true;
                                    break;
                                }
                            }
                            if (!conflict) {
                                lane.add(a);
                                placed = true;
                            }
                        }
                        if (!placed) {
                            List<Map<String,Object>> newLane = new ArrayList<Map<String,Object>>();
                            newLane.add(a);
                            lanes.add(newLane);
                        }
                    }

                    // === lane 수만큼 바 행을 위에서부터 그림 ===
                    for (int li = 0; li < lanes.size(); li++) {
                        List<Map<String,Object>> lane = lanes.get(li);
            %>
                <tr class="cal-bar-row">
            <%
                        int col = 1;
                        while (col <= 7) {
                            int dayNum = weekStartDay + col - 1;

                            // 달 범위 밖
                            if (dayNum < 1 || dayNum > lastDay) {
            %>
                    <td class="empty"></td>
            <%
                                col++;
                                continue;
                            }

                            Map<String,Object> cur = null;
                            int barStartDay = 0;
                            int barEndDay   = 0;

                            // 이 dayNum 에서 시작하는 과제 찾기
                            for (Map<String,Object> a : lane) {
                                int sDay = (Integer)a.get("START_DAY");
                                int eDay = (Integer)a.get("END_DAY");
                                int bs = Math.max(sDay, weekStartDay);
                                int be = Math.min(eDay, weekEndDay);
                                if (dayNum == bs) {
                                    cur = a;
                                    barStartDay = bs;
                                    barEndDay   = be;
                                    break;
                                }
                            }

                            if (cur == null) {
            %>
                    <td class="empty"></td>
            <%
                                col++;
                            } else {
                                int barEndCol = barEndDay - weekStartDay + 1;
                                int span = barEndCol - col + 1;

                                String atitle = (String)cur.get("TITLE");
                                String course = (String)cur.get("COURSE_NAME");
                                int prio      = (Integer)cur.get("PRIORITY");
                                String prioClass = (prio == 2 ? "priority-2" : (prio == 1 ? "priority-1" : ""));
                                String prioText  = (prio == 2 ? "매우 중요" : (prio == 1 ? "중요" : "보통"));

                                int isPassedVal = (Integer)cur.get("IS_PASSED");
                                boolean isPassed = (isPassedVal == 1);

                                String link = (String)cur.get("LINK");
                                boolean hasLink = (link != null && link.trim().length() > 0);

                                String startLabel = year + "-" +
                                    (month < 10 ? "0" + month : String.valueOf(month)) + "-" +
                                    (barStartDay < 10 ? "0" + barStartDay : String.valueOf(barStartDay));
                                String endLabel   = year + "-" +
                                    (month < 10 ? "0" + month : String.valueOf(month)) + "-" +
                                    (barEndDay < 10 ? "0" + barEndDay : String.valueOf(barEndDay));

                                String passClass = isPassed ? " passed" : "";
            %>
                    <td colspan="<%= span %>">
                        <% if (hasLink) { %>
                            <a href="<%= link %>" target="_blank" rel="noopener noreferrer"
                               class="assign-bar <%= prioClass %><%= passClass %>"
                               data-title="<%= atitle %>"
                               data-course="<%= (course != null ? course : "") %>"
                               data-range="<%= startLabel %> ~ <%= endLabel %>"
                               data-priority="<%= prioText %>">
                                <%= (course != null ? "[" + course + "] " : "") %><%= atitle %>
                            </a>
                        <% } else { %>
                            <div class="assign-bar <%= prioClass %><%= passClass %>"
                                 data-title="<%= atitle %>"
                                 data-course="<%= (course != null ? course : "") %>"
                                 data-range="<%= startLabel %> ~ <%= endLabel %>"
                                 data-priority="<%= prioText %>">
                                <%= (course != null ? "[" + course + "] " : "") %><%= atitle %>
                            </div>
                        <% } %>
                    </td>
            <%
                                col += span;
                            }
                        } // while col
            %>
                </tr>
            <%
                    } // for lane
                } // for week
            %>
            </tbody>
        </table>
    </section>

    <!-- 오른쪽: 과제 추가 + 급한 과제 -->
    <section class="side-panel">

        <!-- 과제 추가 폼 -->
        <div class="card">
            <div class="card-title">과제 추가</div>
            <div class="card-sub">
                e캠퍼스에서 자동으로 불러오기 전, 과제를 직접 등록 테스트.
            </div>
            
            <form action="ecampusSync.jsp" method="post" style="margin-top:8px; text-align:right;">
                <button type="submit" style="
                    border-radius:999px; border:none;
                    padding:5px 10px; font-size:11px;
                    background:#111827; color:#e5e7eb; cursor:pointer;">
                    e캠퍼스 과제 동기화
                </button>
            </form>
                        
            <form class="assign-form" action="assignmentProc.jsp" method="post">
                <input type="hidden" name="year" value="<%= year %>">
                <input type="hidden" name="month" value="<%= month %>">

                <label for="title">과제 제목</label>
                <input type="text" id="title" name="title" required maxlength="200">

                <label for="courseName">과목명</label>
                <input type="text" id="courseName" name="courseName" placeholder="예: 웹프로그래밍">

                <label for="startDate">시작일 (선택)</label>
                <input type="date" id="startDate" name="startDate">

                <label for="dueDate">마감일</label>
                <input type="date" id="dueDate" name="dueDate" required>

                <label for="priority">중요도</label>
                <select id="priority" name="priority">
                    <option value="0">보통</option>
                    <option value="1">중요</option>
                    <option value="2">매우 중요</option>
                </select>

                <label for="description">메모 (선택)</label>
                <textarea id="description" name="description"
                          placeholder="과제 내용 / 제출 방식 / 팀원 등 메모를 남겨두세요."></textarea>

                <div class="btn-row">
                    <button type="submit">과제 등록</button>
                </div>
            </form>
        </div>

        <!-- 가장 급한 과제 리스트 -->
        <div class="card">
            <div class="card-title">가장 급한 과제</div>
            <div class="card-sub">
                오늘 기준 마감이 임박한 과제를 순서대로 정렬했습니다. (완료되지 않은 과제만 표시)
            </div>

            <div class="urgent-list">
            <%
                Connection conn2 = null;
                PreparedStatement pstmt2 = null;
                ResultSet rs2 = null;
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd"); // 날짜 라벨 포맷

                try {
                    conn2 = DBUtil.getConnection();
                    String urgentSql =
                        "SELECT ASSIGN_NO, TITLE, COURSE_NAME, DUE_DATE, PRIORITY, STATUS, " +
                        "       IS_PASSED, LINK " +
                        "FROM ASSIGNMENT " +
                        "WHERE USER_ID = ? " +
                        "  AND (STATUS IS NULL OR STATUS <> 'DONE') " +
                        "ORDER BY DUE_DATE ASC, PRIORITY DESC";

                    pstmt2 = conn2.prepareStatement(urgentSql);
                    pstmt2.setString(1, loginUser);
                    rs2 = pstmt2.executeQuery();

                    boolean hasUrgent = false;
                    while (rs2.next()) {
                        hasUrgent = true;
                        String utitle = rs2.getString("TITLE");
                        String ucourse = rs2.getString("COURSE_NAME");

                        // 링크, 통과 여부
                        String link = rs2.getString("LINK");
                        boolean isPassed = (rs2.getInt("IS_PASSED") == 1);

                        // 오전 1시 이전이면 전날 날짜로 표시
                        Timestamp udueTs = rs2.getTimestamp("DUE_DATE");
                        String udueLabel = "";
                        if (udueTs != null) {
                            Calendar dueCal = Calendar.getInstance();
                            dueCal.setTimeInMillis(udueTs.getTime());
                            if (dueCal.get(Calendar.HOUR_OF_DAY) < 1) {
                                dueCal.add(Calendar.DAY_OF_MONTH, -1);
                            }
                            udueLabel = sdf.format(dueCal.getTime());
                        }

                        int uprio = rs2.getInt("PRIORITY");
                        String prioText = (uprio == 2 ? "매우 중요" : (uprio == 1 ? "중요" : "보통"));

                        boolean hasLink = (link != null && link.trim().length() > 0);
            %>
                <div class="urgent-item <%= hasLink ? "clickable" : "" %>">
                <% if (hasLink) { %>
                    <a class="urgent-link" href="<%= link %>" target="_blank" rel="noopener noreferrer">
                <% } %>
                        <div class="urgent-item-header">
                            <div class="urgent-title">
                                <%= utitle %>
                                <% if (isPassed) { %>
                                    <span class="pass-label">PASS</span>
                                <% } %>
                            </div>
                            <div class="urgent-meta"><%= udueLabel %></div>
                        </div>
                        <div class="urgent-meta">
                            <%= (ucourse != null ? ucourse + " · " : "") %>중요도: <%= prioText %>
                        </div>
                <% if (hasLink) { %>
                    </a>
                <% } %>
                </div>
            <%
                    }
                    if (!hasUrgent) {
            %>
                <div class="urgent-item" style="text-align:center; color:#9ca3af;">
                    등록된 과제가 없거나, 모두 완료되었습니다.
                </div>
            <%
                    }
                } catch (Exception e) {
                    e.printStackTrace();
            %>
                <div class="urgent-item" style="text-align:center; color:#fca5a5;">
                    과제 목록을 불러오는 중 오류가 발생했습니다.
                </div>
            <%
                } finally {
                    try { if (rs2 != null) rs2.close(); } catch (Exception ex) {}
                    try { if (pstmt2 != null) pstmt2.close(); } catch (Exception ex) {}
                    try { if (conn2 != null) conn2.close(); } catch (Exception ex) {}
                }
            %>
            </div>
        </div>
    </section>
</main>

<!-- 과제 툴팁 -->
<div id="assign-tooltip" class="assign-tooltip">
    <div class="tt-title"></div>
    <div class="tt-course"></div>
    <div class="tt-range"></div>
    <div class="tt-priority"></div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function () {
    var tooltip = document.getElementById('assign-tooltip');
    if (!tooltip) return;

    function hideTooltip() {
        tooltip.style.display = 'none';
    }

    function showTooltip(e, bar) {
        var title = bar.getAttribute('data-title') || '';
        var course = bar.getAttribute('data-course') || '';
        var range = bar.getAttribute('data-range') || '';
        var prio = bar.getAttribute('data-priority') || '';

        tooltip.querySelector('.tt-title').textContent = title;
        tooltip.querySelector('.tt-course').textContent = course ? course : '';
        tooltip.querySelector('.tt-range').textContent = range ? ('기간: ' + range) : '';
        tooltip.querySelector('.tt-priority').textContent = prio ? ('중요도: ' + prio) : '';

        tooltip.style.display = 'block';

        var x = e.clientX + 12;
        var y = e.clientY + 12;   // ← 여기 y좌표 수정
        tooltip.style.left = x + 'px';
        tooltip.style.top = y + 'px';
    }

    document.querySelectorAll('.assign-bar').forEach(function (bar) {
        bar.addEventListener('mousemove', function (e) {
            showTooltip(e, bar);
        });
        bar.addEventListener('mouseleave', function () {
            hideTooltip();
        });
    });
});
</script>

</body>
</html>
