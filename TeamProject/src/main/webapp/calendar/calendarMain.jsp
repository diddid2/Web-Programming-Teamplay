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

    Calendar todayCal = Calendar.getInstance();
    int curYear  = todayCal.get(Calendar.YEAR);
    int curMonth = todayCal.get(Calendar.MONTH) + 1; // 1~12
    int curDay   = todayCal.get(Calendar.DAY_OF_MONTH);

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

    if (month <= 0) {
        month = 12;
        year -= 1;
    } else if (month >= 13) {
        month = 1;
        year += 1;
    }

    Calendar cal = Calendar.getInstance();
    cal.set(year, month - 1, 1);

    int firstDayOfWeek = cal.get(Calendar.DAY_OF_WEEK); // 1=일요일
    int lastDay        = cal.getActualMaximum(Calendar.DAY_OF_MONTH);

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
            "        (START_DATE IS NULL AND DUE_DATE BETWEEN ? AND ?) " +
            "     OR (START_DATE IS NOT NULL AND DUE_DATE IS NOT NULL " +
            "         AND START_DATE <= ? AND DUE_DATE >= ?) " +
            "      ) " +
            "ORDER BY DUE_DATE ASC, PRIORITY DESC";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, loginUser);
        pstmt.setDate(2, monthStartDate);
        pstmt.setDate(3, monthEndDate);
        pstmt.setDate(4, monthEndDate);
        pstmt.setDate(5, monthStartDate);
        rs = pstmt.executeQuery();

        while (rs.next()) {
            Timestamp dbStartTs = rs.getTimestamp("START_DATE");
            Timestamp dbDueTs   = rs.getTimestamp("DUE_DATE");
            if (dbDueTs == null) continue;

            Calendar dueCal = Calendar.getInstance();
            dueCal.setTimeInMillis(dbDueTs.getTime());
            if (dueCal.get(Calendar.HOUR_OF_DAY) < 1) {
                dueCal.add(Calendar.DAY_OF_MONTH, -1);
            }
            long rangeEndMs = dueCal.getTimeInMillis();

            long rangeStartMs;
            if (dbStartTs != null) rangeStartMs = dbStartTs.getTime();
            else rangeStartMs = rangeEndMs;

            long dispStartMs = Math.max(rangeStartMs, monthStartMs);
            long dispEndMs   = Math.min(rangeEndMs,   monthEndMs);
            if (dispStartMs > dispEndMs) continue;

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

    final int FIXED_LANES = 6;

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
            main { grid-template-columns: 1fr; }
        }

        :root{
            --grid: #111827;
            --calBg: #020617;
			-cellPad: 10px;
            --weekH: 150px;

            --numAreaH: 34px;

            --laneH: 18px;

            --fixedLanes: <%= FIXED_LANES %>;
        }

        .calendar-panel {
            border-radius:18px;
            border:1px solid rgba(55,65,81,.9);
            background: var(--calBg);
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

        .calendar-grid {
            position:relative;
            background: var(--calBg);
            border:1px solid var(--grid);
            border-radius:12px;
            overflow:hidden;
        }

        .calendar-grid::before{
            content:"";
            position:absolute;
            inset:0;
            pointer-events:none;
            z-index:1;
            background-image:
                repeating-linear-gradient(
                    to right,
                    transparent 0,
                    transparent calc(100%/7 - 1px),
                    var(--grid) calc(100%/7 - 1px),
                    var(--grid) calc(100%/7)
                );
            background-size: 100% 100%;
            background-repeat:no-repeat;
        }

        .dow-row{
            display:grid;
            grid-template-columns: repeat(7, 1fr);
            border-bottom:1px solid var(--grid);
            position:relative;
            z-index:2;
        }
        .dow{
            text-align:center;
            padding:8px 0;
            font-size:11px;
            color:#9ca3af;
        }
        .dow.sun{ color:#fca5a5; }
        .dow.sat{ color:#93c5fd; }

        .weeks{
            display:flex;
            flex-direction:column;
            position:relative;
            z-index:2;
        }
        .week{
            position:relative;
            display:grid;
            grid-template-columns: repeat(7, 1fr);
            height: var(--weekH);
            border-top:1px solid var(--grid);
        }
        .week:first-child{ border-top:0; }

        .day{
            position:relative;
            padding:8px 10px 8px;
            overflow:hidden;
        }
        .day.empty{
            opacity:0.45;
        }

        .day-number{
            width:26px;
            height:26px;
            display:inline-flex;
            align-items:center;
            justify-content:center;
            border-radius:999px;
            font-size:12px;
            font-weight:700;
            color:#e5e7eb;
            background:transparent;
            line-height:1;
        }
        .day-number.today{
            background:#347AE2;
            color:#fff;
        }

        .week-bars{
            position:absolute;
            left:0; right:0;
            top: var(--numAreaH);
            bottom: 8px;
            display:grid;
            grid-template-columns: repeat(7, 1fr);
            grid-template-rows: repeat(var(--fixedLanes), var(--laneH));
            gap: 4px 0;
            padding: 0;
            pointer-events:none;
            z-index:3;
        }
         .assign-bar{
            pointer-events:auto;
            align-self:center;
            justify-self:stretch;
			margin: 0 var(--cellpad);
            width:auto;
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
        .assign-bar.priority-1 { border-color:#facc15; }
        .assign-bar.priority-2 { border-color:#f97373; }
        .assign-bar.passed { border-color:#16a34a !important; }

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
        .urgent-title { font-weight:600; }
        .urgent-meta { font-size:11px; color:#9ca3af; }

        .pass-label {
            display:inline-block;
            margin-left:6px;
            padding:2px 6px;
            border-radius:999px;
            font-size:10px;
            background:#16a34a;
            color:#ecfdf5;
        }
        .urgent-item.clickable { cursor:pointer; }
        .urgent-item.clickable a.urgent-link {
            display:block;
            color:inherit;
            text-decoration:none;
        }
        .urgent-item.clickable a.urgent-link:hover {
            text-decoration:none;
            opacity:0.96;
        }

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
        .assign-tooltip .tt-title { font-weight:600; margin-bottom:2px; }
        .assign-tooltip .tt-course { color:#9ca3af; margin-bottom:2px; }
        .assign-tooltip .tt-range { color:#e5e7eb; margin-bottom:2px; }
        .assign-tooltip .tt-priority { color:#facc15; }
    </style>
</head>
<body>

<jsp:include page="/common/gnb.jsp" />

<main>
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

        <div class="calendar-grid">
            <div class="dow-row">
                <div class="dow sun">일</div>
                <div class="dow">월</div>
                <div class="dow">화</div>
                <div class="dow">수</div>
                <div class="dow">목</div>
                <div class="dow">금</div>
                <div class="dow sat">토</div>
            </div>

            <div class="weeks">
            <%
                for (int week = 0; week < 6; week++) {
                    int weekStartDay = 1 - (firstDayOfWeek - 1) + week * 7;
                    int weekEndDay   = weekStartDay + 6;

            %>
                <div class="week">
                    <%
                        for (int col = 0; col < 7; col++) {
                            int dayNum = weekStartDay + col;
                            if (dayNum < 1 || dayNum > lastDay) {
                    %>
                        <div class="day empty"></div>
                    <%
                            } else {
                                boolean isToday = (year == curYear && month == curMonth && dayNum == curDay);
                    %>
                        <div class="day">
                            <div class="day-number <%= isToday ? "today" : "" %>"><%= dayNum %></div>
                        </div>
                    <%
                            }
                        }
                    %>

                    <div class="week-bars">
                    <%
                        List<Map<String, Object>> weekList = new ArrayList<>();
                        for (Map<String, Object> a : monthAssignments) {
                            int sDay = (Integer)a.get("START_DAY");
                            int eDay = (Integer)a.get("END_DAY");
                            if (eDay < weekStartDay || sDay > weekEndDay) continue;
                            weekList.add(a);
                        }

                        Collections.sort(weekList, new Comparator<Map<String,Object>>() {
                            public int compare(Map<String,Object> x, Map<String,Object> y) {
                                int xs = (Integer)x.get("START_DAY");
                                int ys = (Integer)y.get("START_DAY");
                                if (xs != ys) return xs - ys;

                                int xe = (Integer)x.get("END_DAY");
                                int ye = (Integer)y.get("END_DAY");
                                int xlen = xe - xs;
                                int ylen = ye - ys;
                                if (xlen != ylen) return ylen - xlen;

                                int xp = (Integer)x.get("PRIORITY");
                                int yp = (Integer)y.get("PRIORITY");
                                return yp - xp;
                            }
                        });

                        List<List<Map<String,Object>>> lanes = new ArrayList<>();
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
                                    if (!(eDay < bs || sDay > be)) { conflict = true; break; }
                                }
                                if (!conflict) { lane.add(a); placed = true; }
                            }
                            if (!placed) {
                                List<Map<String,Object>> newLane = new ArrayList<>();
                                newLane.add(a);
                                lanes.add(newLane);
                            }
                        }

                        for (int li = 0; li < lanes.size() && li < FIXED_LANES; li++) {
                            List<Map<String,Object>> lane = lanes.get(li);

                            for (Map<String,Object> cur : lane) {
                                int sDay = (Integer)cur.get("START_DAY");
                                int eDay = (Integer)cur.get("END_DAY");
                                int bs = Math.max(sDay, weekStartDay);
                                int be = Math.min(eDay, weekEndDay);

                                int startCol = (bs - weekStartDay) + 1;
                                int endCol   = (be - weekStartDay) + 2;

                                String atitle = (String)cur.get("TITLE");
                                String course = (String)cur.get("COURSE_NAME");
                                int prio      = (Integer)cur.get("PRIORITY");
                                String prioClass = (prio == 2 ? "priority-2" : (prio == 1 ? "priority-1" : ""));
                                String prioText  = (prio == 2 ? "매우 중요" : (prio == 1 ? "중요" : "보통"));

                                boolean isPassed = (((Integer)cur.get("IS_PASSED")) == 1);
                                String passClass = isPassed ? " passed" : "";

                                String link = (String)cur.get("LINK");
                                boolean hasLink = (link != null && link.trim().length() > 0);

                                String startLabel = year + "-" +
                                    (month < 10 ? "0" + month : String.valueOf(month)) + "-" +
                                    (bs < 10 ? "0" + bs : String.valueOf(bs));
                                String endLabel   = year + "-" +
                                    (month < 10 ? "0" + month : String.valueOf(month)) + "-" +
                                    (be < 10 ? "0" + be : String.valueOf(be));

                                String label = (course != null ? "[" + course + "] " : "") + atitle;
                    %>
                        <% if (hasLink) { %>
                            <a href="<%= link %>" target="_blank" rel="noopener noreferrer"
                               class="assign-bar <%= prioClass %><%= passClass %>"
                               style="grid-column:<%= startCol %> / <%= endCol %>; grid-row:<%= (li+1) %>;"
                               data-title="<%= atitle %>"
                               data-course="<%= (course != null ? course : "") %>"
                               data-range="<%= startLabel %> ~ <%= endLabel %>"
                               data-priority="<%= prioText %>">
                                <%= label %>
                            </a>
                        <% } else { %>
                            <div class="assign-bar <%= prioClass %><%= passClass %>"
                                 style="grid-column:<%= startCol %> / <%= endCol %>; grid-row:<%= (li+1) %>;"
                                 data-title="<%= atitle %>"
                                 data-course="<%= (course != null ? course : "") %>"
                                 data-range="<%= startLabel %> ~ <%= endLabel %>"
                                 data-priority="<%= prioText %>">
                                <%= label %>
                            </div>
                        <% } %>
                    <%
                            }
                        }
                    %>
                    </div>
                </div>
            <%
                }
            %>
            </div>
        </div>
    </section>

    <section class="side-panel">

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
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

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

                        String link = rs2.getString("LINK");
                        boolean isPassed = (rs2.getInt("IS_PASSED") == 1);

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
        tooltip.style.left = (e.clientX + 12) + 'px';
        tooltip.style.top  = (e.clientY + 12) + 'px';
    }

    document.querySelectorAll('.assign-bar').forEach(function (bar) {
        bar.addEventListener('mousemove', function (e) { showTooltip(e, bar); });
        bar.addEventListener('mouseleave', hideTooltip);
    });
});
</script>

</body>
</html>
