<%@ page import="java.sql.*, java.util.*, java.text.*" %>
<%@ page import="util.DBUtil" %>
<%@ page import="crawler.TimetableCrawler.Lecture" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
request.setAttribute("currentMenu", "timetable");
%>
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

    
    try (Connection conn = DBUtil.getConnection();
         PreparedStatement pstmt = conn.prepareStatement(
             "SELECT TITLE, PROFESSOR, DAY, START_MIN, END_MIN " +
             "FROM USER_TIMETABLE WHERE USER_ID = ? ORDER BY DAY, START_MIN")) {

        pstmt.setString(1, userId);

        try (ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Lecture L = new Lecture();
                L.title     = rs.getString("TITLE");
                L.professor = rs.getString("PROFESSOR");
                L.day       = rs.getInt("DAY");        
                L.start     = rs.getInt("START_MIN");  
                L.end       = rs.getInt("END_MIN");
                lectures.add(L);
            }
        }
    } catch (Exception e) {
        e.printStackTrace();
    }

    
    Map<String, Map<String,Object>> urgentMap = new HashMap<>();
    SimpleDateFormat urgentSdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");

    try (Connection conn2 = DBUtil.getConnection();
         PreparedStatement pstmt2 = conn2.prepareStatement(
             "SELECT COURSE_NAME, TITLE, DUE_DATE, PRIORITY, STATUS, IS_PASSED " +
             "FROM ASSIGNMENT " +
             "WHERE USER_ID = ? " +
             "  AND (STATUS IS NULL OR STATUS <> 'DONE') " +
             "  AND (IS_PASSED IS NULL OR IS_PASSED <> 1) " +
             "ORDER BY DUE_DATE ASC, PRIORITY DESC")) {

        pstmt2.setString(1, userId);

        try (ResultSet rs2 = pstmt2.executeQuery()) {
            while (rs2.next()) {
                String courseName = rs2.getString("COURSE_NAME");
                if (courseName == null || courseName.trim().isEmpty()) continue;

                
                if (urgentMap.containsKey(courseName)) continue;

                Timestamp dueTs = rs2.getTimestamp("DUE_DATE");
                String dueLabel = "";
                if (dueTs != null) {
                    dueLabel = urgentSdf.format(dueTs);
                }

                int prio = rs2.getInt("PRIORITY");
                String prioText = (prio == 2 ? "매우 중요" : (prio == 1 ? "중요" : "보통"));

                Map<String,Object> item = new HashMap<>();
                item.put("TITLE", rs2.getString("TITLE"));
                item.put("DUE_LABEL", dueLabel);
                item.put("PRIORITY_TEXT", prioText);

                urgentMap.put(courseName, item);
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
body {
    margin: 0;
    background: #0B1120;
    color: #E2E8F0;
    font-family: -apple-system, BlinkMacSystemFont, 'Noto Sans KR', sans-serif;
}

.timetable-panel {
    margin: 20px auto;
    max-width: 900px;
    padding: 24px;
    border-radius: 18px;
    background: #111827;
    border: 1px solid #273244;
}


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


.time-debug {
    margin-top: 10px;
    font-size: 11px;
    color: #9CA3AF;
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
}
.time-debug label {
    display: flex;
    align-items: center;
    gap: 4px;
}
.time-debug input[type="time"],
.time-debug select {
    background: #020617;
    border: 1px solid #1F2937;
    color: #E5E7EB;
    border-radius: 999px;
    padding: 2px 8px;
    font-size: 11px;
}
.time-debug small {
    opacity: 0.7;
}

.timetable-wrapper {
    position: relative;
    margin-top: 16px;
    z-index: 0;

    --hour-h: 80px;
    --min-px: 1.333333px;
}

#today-highlight {
    position: absolute;
    top: 0;
    bottom: 0;
    left: 0;
    width: 0;
    background: rgba(52,122,226,0.18);
    opacity: 0;
    pointer-events: none;
    z-index: 0;
    transition: left .2s ease, width .2s ease, opacity .2s ease;
}
#today-highlight.visible {
    opacity: 1;
}


.timetable-table {
    width: 100%;
    border-collapse: collapse;
    table-layout: fixed;
    z-index:1;
}
.timetable-table th:first-child,
.timetable-table td:first-child {
    width: 70px !important;
}
.timetable-table th:not(:first-child),
.timetable-table td:not(:first-child) {
    width: calc((100% - 70px) / 5) !important;
}
.timetable-table thead th.today-header {
    background: #12213c;
    color: #E5F2FF;
    border-color: #2f3f63;
}


.timetable-table tbody td.today-col {
    background: #12213c;           
    border-color: #2f3f63;
}

.timetable-table thead th {
    background: #111827;
    color: #9CA3AF;
    padding: 8px;
    border: 1px solid #273244;
    font-size: 12px;
}


.time-cell {
    background: #111827;
    color: #9CA3AF;
    font-size: 14px;
    border: 1px solid #1F2533;
}

.timetable-table tbody tr.hour-row .time-cell,
.timetable-table tbody tr.hour-row td {
    border-top: 1.5px solid #273244;
}

.timetable-table td {
    border: 1px solid #1F2533;
    height: 80px;
    padding: 0;
    position: relative;
    background: #111827;
    overflow: visible;
}


.subject-box {
    position: absolute;

    
    --row-start: 0;
    --start: 0;
    --end: 0;

    
    top: calc((var(--start) - var(--row-start)) * var(--min-px));
    height: calc((var(--end) - var(--start)) * var(--min-px));

    left: 6%;
    width: 88%;

    padding: 10px 12px;

    background: #111827;  
    border: 1.5px solid rgba(255,255,255,0.18);
    border-radius: 14px;
    box-sizing: border-box;

    font-size: 12px;
    line-height: 1.4;
    color: #EDEDED;

    display: flex;
    flex-direction: column;
    justify-content: flex-start;

    z-index: 5;
    transition: background 0.2s ease, border-color 0.2s ease,
                box-shadow 0.2s ease, transform 0.2s ease;
}
.subject-box:hover {
    border-color: 1.5px solid rgba(255,255,255,0.18);
    background: #111827;
    box-shadow: 0 10px 30px rgba(0,0,0,0.7);
    transform: translateY(-1px);
}


.subject-box.is-current {
    border-color: #347AE2;
    box-shadow: 0 0 0 2px rgba(52,122,226,0.9),
                0 14px 35px rgba(0,0,0,0.9);
}


.lecture-title {
    font-size: 12px;
    font-weight: 500;
    margin-bottom: 4px;
    z-index: 3;
}
.lecture-time {
    font-size: 11px;
    color: #9DA9BC;
    margin-bottom: 3px;
}
.sub-prof {
    font-size: 9.5px;
    color: #9DA9BC;
}


.current-time-line {
    position: absolute;
    left: 0;
    right: 0;
    height: 0;
    pointer-events: none;
    z-index: 2;
}


.current-time-line::after {
    content: "";
    position: absolute;
    top: 0;
    left: var(--line-start, 0); 
    right: 0;
    border-top: 2px solid #347AE2;
}


.current-time-label {
    position: absolute;
    top: 0;
    transform: translate(-50%, -50%);

    padding: 2px 8px;
    font-size: 14px;
    font-weight: 600;

    
    background: #347AE2;   
    border: 2px solid #347AE2;
    color: #0B1120;        

    border-radius: 999px;
    box-shadow: 0 0 0 1px rgba(15,23,42,0.9);
}


#lecture-tooltip {
    position: fixed;
    display: none;
    background: #020617;
    color: #E5E7EB;
    padding: 10px 12px;
    border-radius: 12px;
    border: 1px solid #347AE2;
    font-size: 11px;
    max-width: 260px;
    z-index: 50;
    pointer-events: none;
}

#lecture-tooltip .tt-title {
    font-size: 12px;
    font-weight: 600;
    margin-bottom: 3px;
}
#lecture-tooltip .tt-time {
    font-size: 11px;
    color: #9CA3AF;
    margin-bottom: 3px;
}
#lecture-tooltip .tt-prof {
    font-size: 11px;
    color: #9CA3AF;
    margin-bottom: 4px;
}

#lecture-tooltip .tt-urgent-title {
    display: inline-block;
    margin-top: 2px;
    margin-bottom: 4px;
    padding: 3px 8px;

    border-radius: 999px;
    border: 1px solid #22c55e;          
    background: rgba(34,197,94,0.10);
    font-size: 10.5px;
}
#lecture-tooltip .tt-urgent-title.urgent-normal {
    border-color: #22c55e;
    background: rgba(34,197,94,0.10);
}
#lecture-tooltip .tt-urgent-title.urgent-high {
    border-color: #facc15;
    background: rgba(250,204,21,0.10);
}
#lecture-tooltip .tt-urgent-title.urgent-critical {
    border-color: #f97373;
    background: rgba(249,115,115,0.10);
}

#lecture-tooltip .tt-urgent-meta {
    font-size: 11px;
    color: #9CA3AF;
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

    
    <div class="time-debug">
        <label>
            <input type="checkbox" id="useTestTime">
            테스트 시간 사용
        </label>

        <label>
            요일
            <select id="testDay">
                <option value="0">월</option>
                <option value="1">화</option>
                <option value="2">수</option>
                <option value="3">목</option>
                <option value="4">금</option>
            </select>
        </label>

        <label>
            시간
            <input type="time" id="testTime" value="09:30">
        </label>

        <small>(체크하면 위 요일·시간 기준으로 현재 시간 선 / 진행 중 강의 강조를 테스트할 수 있어요)</small>
    </div>

    <div class="timetable-wrapper"
         data-start="<%= times[0] %>"
         data-end="<%= times[times.length-1] + 60 %>">

        
        <div id="today-highlight"></div>

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
    <tr class="hour-row">
        <th class="time-cell">
            <%= String.format("%02d:00", times[i]/60) %>
        </th>

        <% for (int day=0; day<5; day++) {

            if (drawn[i][day]) continue;

            Lecture target = null;

            for (Lecture L : lectures) {
                if (L.day == day && L.start <= times[i] && L.end > times[i]) {
                    target = L;
                    break;
                }
            }

            if (target == null) { %>
                
                <td data-day="<%= day %>"></td>

            <% } else {
                int duration = target.end - target.start;
                int rowspan = (int)Math.ceil(duration / 60.0);

                for (int k=0; k<rowspan && i+k<times.length; k++)
                    drawn[i+k][day] = true;

                String timeText = String.format("%02d:%02d ~ %02d:%02d",
                        target.start/60, target.start%60,
                        target.end/60,   target.end%60);

                Map<String,Object> urgent = urgentMap.get(target.title);
                String urgentTitle = "";
                String urgentDue   = "";
                String urgentPrio  = "";
                if (urgent != null) {
                    urgentTitle = (String)urgent.get("TITLE");
                    urgentDue   = (String)urgent.get("DUE_LABEL");
                    urgentPrio  = (String)urgent.get("PRIORITY_TEXT");
                }
            %>
                
                <td rowspan="<%= rowspan %>" data-day="<%= day %>">
    <div class="subject-box"
         style="--row-start:<%= times[i] %>; --start:<%= target.start %>; --end:<%= target.end %>;"
         data-day="<%= day %>"
         data-start="<%= target.start %>"
         data-end="<%= target.end %>"
         data-title="<%= target.title %>"
         data-prof="<%= target.professor %>"
         data-time="<%= timeText %>"
         data-urgent-title="<%= urgentTitle %>"
         data-urgent-due="<%= urgentDue %>"
         data-urgent-priority="<%= urgentPrio %>">
        <div class="lecture-title"><%= target.title %></div>
        <div class="lecture-time"><%= timeText %></div>
        <div class="lecture-prof sub-prof"><%= target.professor %></div>
    </div>
</td>

            <% } %>

        <% } %>
    </tr>
<% } %>

            </tbody>
        </table>

        
        <div id="current-time-line" class="current-time-line" style="display:none;">
            <span class="current-time-label"></span>
        </div>
    </div>
</div>


<div id="lecture-tooltip">
    <div class="tt-title"></div>
    <div class="tt-time"></div>
    <div class="tt-prof"></div>
    <div class="tt-urgent-title"></div>
    <div class="tt-urgent-meta"></div>
</div>

<script>
(function() {
    function pad(n) { return (n < 10 ? '0' + n : '' + n); }

    
    function getNowInfo() {
        const useTest = document.getElementById('useTestTime');
        const testDaySel = document.getElementById('testDay');
        const testTimeInput = document.getElementById('testTime');

        if (useTest && useTest.checked && testDaySel && testTimeInput) {
            const val = testTimeInput.value || '09:00';
            const parts = val.split(':');
            const h = parseInt(parts[0] || '0', 10);
            const m = parseInt(parts[1] || '0', 10);
            const minutes = h * 60 + m;
            const dayIndex = parseInt(testDaySel.value, 10);
            const label = pad(h) + ':' + pad(m);
            return { dayIndex, minutes, label };
        } else {
            const now = new Date();
            const jsDay = now.getDay(); 
            let dayIndex = -1;
            if (jsDay >= 1 && jsDay <= 5) {
                dayIndex = jsDay - 1;
            }
            const minutes = now.getHours() * 60 + now.getMinutes();
            const label = pad(now.getHours()) + ':' + pad(now.getMinutes());
            return { dayIndex, minutes, label };
        }
    }

    
    function highlightCurrent(nowInfo) {
        const dayIndex = nowInfo.dayIndex;
        const minutes  = nowInfo.minutes;

        document.querySelectorAll('.subject-box').forEach(function(box) {
            const d = parseInt(box.dataset.day, 10);
            const s = parseInt(box.dataset.start, 10);
            const e = parseInt(box.dataset.end, 10);

            if (dayIndex === d && minutes >= s && minutes < e) {
                box.classList.add('is-current');
            } else {
                box.classList.remove('is-current');
            }
        });
    }

    
   function highlightTodayColumn(dayIndex, wrapper, table) {
    const highlight = document.getElementById('today-highlight');
    if (!wrapper || !table || !highlight) return;

    
    table.querySelectorAll('thead th.today-header')
        .forEach(th => th.classList.remove('today-header'));
    table.querySelectorAll('tbody td.today-col')
        .forEach(td => td.classList.remove('today-col'));

    if (dayIndex < 0 || dayIndex > 4) {
        highlight.classList.remove('visible');
        return;
    }

    const headerRow = table.querySelector('thead tr');
    if (!headerRow) return;
    const th = headerRow.children[dayIndex + 1];
    if (!th) return;

    
    th.classList.add('today-header');
    
    table.querySelectorAll('tbody td[data-day="' + dayIndex + '"]')
         .forEach(td => td.classList.add('today-col'));

    const wrapperRect = wrapper.getBoundingClientRect();
    const thRect = th.getBoundingClientRect();
    highlight.style.left  = (thRect.left - wrapperRect.left) + 'px';
    highlight.style.width = thRect.width + 'px';
    highlight.classList.add('visible');
}


    function updateCurrentTimeLine() {
        const wrapper = document.querySelector('.timetable-wrapper');
        const table   = document.querySelector('.timetable-table');
        const line    = document.getElementById('current-time-line');
        if (!wrapper || !table || !line) return;

        const wrapperRect = wrapper.getBoundingClientRect();

        const firstTimeCell = table.querySelector('tbody tr .time-cell');
        if (!firstTimeCell) return;

        const cellRect  = firstTimeCell.getBoundingClientRect();
        const rowTop    = cellRect.top - wrapperRect.top;
        const rowHeight = cellRect.height;

        wrapper.style.setProperty('--hour-h', rowHeight + 'px');
        wrapper.style.setProperty('--min-px', (rowHeight / 60) + 'px');

        const startMinutes = parseInt(wrapper.dataset.start, 10);
        const endMinutes   = parseInt(wrapper.dataset.end, 10);

        const nowInfo = getNowInfo();
        const minutes = nowInfo.minutes;

        highlightTodayColumn(nowInfo.dayIndex, wrapper, table);

        highlightCurrent(nowInfo);

        if (minutes < startMinutes || minutes > endMinutes) {
            line.style.display = 'none';
            return;
        }

        line.style.display = 'block';

        const offset = minutes - startMinutes;
        const y = rowTop + (offset / 60) * rowHeight;
        line.style.top = y + 'px';

        const label = line.querySelector('.current-time-label');
        if (label) {
            label.textContent = nowInfo.label;

            const timeCellRect  = firstTimeCell.getBoundingClientRect();
            const labelLeft =
                (timeCellRect.left - wrapperRect.left) + (timeCellRect.width / 2);

            label.style.left = labelLeft + 'px';

            const labelRect  = label.getBoundingClientRect();
            const lineStart  = (labelRect.right - wrapperRect.left);
            line.style.setProperty('--line-start', lineStart + 'px');
        }
    }

    function initLectureTooltip() {
        const tooltip = document.getElementById('lecture-tooltip');
        if (!tooltip) return;

        const dayNames = ['월', '화', '수', '목', '금'];

        document.querySelectorAll('.subject-box').forEach(function(box) {
            box.addEventListener('mouseenter', function(e) {
                const title  = box.dataset.title || '';
                const prof   = box.dataset.prof  || '';
                const time   = box.dataset.time  || '';
                const d      = parseInt(box.dataset.day, 10);
                const dayText = (d >= 0 && d < 5) ? dayNames[d] : '';

                const uTitle = box.dataset.urgentTitle || '';
                const uDue   = box.dataset.urgentDue   || '';
                const uPrio  = box.dataset.urgentPriority || '';

                tooltip.querySelector('.tt-title').textContent = title;
                tooltip.querySelector('.tt-time').textContent  =
                    (dayText ? dayText + '요일 · ' : '') + time;
                tooltip.querySelector('.tt-prof').textContent  =
                    prof ? ('담당 교수: ' + prof) : '';

                const urgentTitleEl = tooltip.querySelector('.tt-urgent-title');
                const urgentMetaEl  = tooltip.querySelector('.tt-urgent-meta');

                urgentTitleEl.className = 'tt-urgent-title';

                if (uTitle && uDue) {
                    let badgeClass = ' urgent-normal';
                    if (uPrio === '매우 중요') {
                        badgeClass = ' urgent-critical';
                    } else if (uPrio === '중요') {
                        badgeClass = ' urgent-high';
                    }
                    urgentTitleEl.className = 'tt-urgent-title' + badgeClass;
                    urgentTitleEl.textContent = uTitle;
                    urgentMetaEl.textContent =
                        '마감: ' + uDue + ' · 중요도: ' + (uPrio || '정보 없음');
                } else {
                    urgentTitleEl.textContent = '등록된 미완료 과제가 없습니다.';
                    urgentMetaEl.textContent = '';
                }

                tooltip.style.display = 'block';
            });

            box.addEventListener('mousemove', function(e) {
                const offsetX = 16;
                const offsetY = 16;
                tooltip.style.left = (e.clientX + offsetX) + 'px';
                tooltip.style.top  = (e.clientY + offsetY) + 'px';
            });

            box.addEventListener('mouseleave', function() {
                tooltip.style.display = 'none';
            });
        });
    }

    window.addEventListener('DOMContentLoaded', function() {
        updateCurrentTimeLine();
        initLectureTooltip();

        ['useTestTime','testDay','testTime'].forEach(function(id) {
            const el = document.getElementById(id);
            if (!el) return;
            el.addEventListener('change', updateCurrentTimeLine);
            if (id === 'testTime') {
                el.addEventListener('input', updateCurrentTimeLine);
            }
        });
    });

    
    setInterval(updateCurrentTimeLine, 5 * 60 * 1000);
})();
</script>

</body>
</html>