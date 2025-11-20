<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="util.DBUtil" %>
<%@ page import="crawler.EverytimeTimetableParser" %>
<%@ page import="crawler.EverytimeTimetableParser.LectureSlot" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String userId = (String)session.getAttribute("userId");
    if (userId == null || userId.trim().isEmpty()) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../login.jsp';</script>");
        return;
    }

    String timetableUrl = request.getParameter("timetableUrl");
    boolean submitted = (timetableUrl != null && !timetableUrl.trim().isEmpty());

    List<LectureSlot> slots = null;
    String errorMsg = null;
    int insertedCount = 0;

    if (submitted) {
        timetableUrl = timetableUrl.trim();
        try {
            // 1) 파싱
            EverytimeTimetableParser parser = new EverytimeTimetableParser();
            slots = parser.parse(timetableUrl);

            if (slots == null || slots.isEmpty()) {
                errorMsg = "시간표에서 과목 정보를 찾지 못했습니다. 링크 또는 셀렉터를 확인해주세요.";
            } else {
                // 2) DB 저장
                Connection conn = null;
                PreparedStatement pstmt = null;

                try {
                    conn = DBUtil.getConnection();

                    // 학기별로 기존 데이터 삭제 후 새로 삽입
                    // 먼저 이번 링크에 등장한 학기 목록 수집
                    Set<String> semesters = new HashSet<>();
                    for (LectureSlot s : slots) {
                        if (s.semester != null) semesters.add(s.semester);
                    }

                    // 해당 유저 + 학기들 기존 데이터 삭제
                    for (String sem : semesters) {
                        String delSql = "DELETE FROM TIMETABLE_ENTRY WHERE USER_ID = ? AND SEMESTER = ?";
                        pstmt = conn.prepareStatement(delSql);
                        pstmt.setString(1, userId);
                        pstmt.setString(2, sem);
                        pstmt.executeUpdate();
                        pstmt.close();
                    }

                    // 새 데이터 INSERT
                    String insSql =
                        "INSERT INTO TIMETABLE_ENTRY " +
                        "(ENTRY_ID, USER_ID, SEMESTER, COURSE_NAME, PROFESSOR, CLASSROOM, " +
                        " DAY_OF_WEEK, START_PERIOD, END_PERIOD, COLOR, RAW_TEXT, CREATED_AT, UPDATED_AT) " +
                        "VALUES (TIMETABLE_ENTRY_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, SYSDATE, SYSDATE)";
                    pstmt = conn.prepareStatement(insSql);

                    for (LectureSlot s : slots) {
                        pstmt.setString(1, userId);
                        pstmt.setString(2, s.semester);
                        pstmt.setString(3, s.courseName);
                        pstmt.setString(4, s.professor);
                        pstmt.setString(5, s.classroom);
                        pstmt.setString(6, s.dayOfWeek);
                        if (s.startPeriod != null) pstmt.setInt(7, s.startPeriod); else pstmt.setNull(7, java.sql.Types.NUMERIC);
                        if (s.endPeriod != null) pstmt.setInt(8, s.endPeriod); else pstmt.setNull(8, java.sql.Types.NUMERIC);
                        pstmt.setString(9, s.color);
                        pstmt.setString(10, s.rawText);

                        insertedCount += pstmt.executeUpdate();
                    }

                    pstmt.close();
                    conn.close();
                } catch (Exception e) {
                    e.printStackTrace();
                    errorMsg = "DB 저장 중 오류가 발생했습니다: " + e.getMessage();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            errorMsg = "시간표 파싱 중 오류가 발생했습니다: " + e.getMessage();
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>에타 시간표 가져오기 - 강남타임</title>
    <style>
        * { box-sizing:border-box; margin:0; padding:0; }
        body {
            font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Noto Sans KR",sans-serif;
            background:#020617;
            color:#e5e7eb;
        }
        a { color:#38bdf8; text-decoration:none; }
        a:hover { text-decoration:underline; }

        .wrap {
            max-width:960px;
            margin:24px auto 40px;
            padding:0 20px;
        }
        h1 {
            font-size:20px;
            margin-bottom:10px;
        }
        .sub {
            font-size:12px;
            color:#9ca3af;
            margin-bottom:16px;
            line-height:1.6;
        }

        form {
            margin-bottom:20px;
        }
        input[type=text] {
            width:100%;
            padding:8px 10px;
            border-radius:8px;
            border:1px solid #1e293b;
            background:#020617;
            color:#e5e7eb;
            font-size:13px;
        }
        button {
            margin-top:8px;
            border:none;
            border-radius:999px;
            padding:8px 16px;
            font-size:13px;
            background:#4f46e5;
            color:white;
            cursor:pointer;
        }
        button:hover {
            background:#4338ca;
        }

        .error {
            padding:10px 12px;
            border-radius:9px;
            background:#7f1d1d;
            color:#fee2e2;
            font-size:13px;
            margin-bottom:16px;
        }
        .info {
            padding:8px 10px;
            border-radius:9px;
            background:#0f172a;
            color:#e5e7eb;
            font-size:12px;
            margin-bottom:12px;
        }

        table {
            width:100%;
            border-collapse:collapse;
            margin-top:10px;
            font-size:13px;
        }
        th, td {
            border-bottom:1px solid #1f2933;
            padding:6px 5px;
            vertical-align:top;
        }
        th {
            text-align:left;
            color:#9ca3af;
            font-weight:500;
        }
        tr:hover td {
            background:#02091f;
        }

        .tag {
            display:inline-block;
            padding:2px 8px;
            border-radius:999px;
            background:#111827;
            font-size:11px;
            margin-right:4px;
        }
    </style>
</head>
<body>

<div class="wrap">
    <h1>에타 공유 시간표 가져오기</h1>
    <div class="sub">
        에브리타임에서 시간표를 공유한 링크(<code>https://everytime.kr/@...</code>)를 입력하면<br>
        학기별로 시간표 정보가 자동으로 파싱되어 <code>TIMETABLE_ENTRY</code> 테이블에 저장됩니다.
    </div>

    <form method="post">
        <input type="text" name="timetableUrl"
               placeholder="에브리타임 공유 시간표 링크를 붙여넣으세요 (예: https://everytime.kr/@G3mz5YIhHrj4Uhr3Gw3b)"
               value="<%= (timetableUrl != null ? timetableUrl : "") %>">
        <button type="submit">시간표 가져와서 저장</button>
    </form>

    <% if (submitted) { %>
        <% if (errorMsg != null) { %>
            <div class="error"><%= errorMsg %></div>
        <% } else { %>
            <div class="info">
                시간표를 파싱하여 총 <strong><%= slots != null ? slots.size() : 0 %></strong>개의 과목 블록을 읽어들였고,<br>
                DB에는 <strong><%= insertedCount %></strong>건이 저장(기존 학기 데이터 삭제 후 재삽입)되었습니다.
            </div>
        <% } %>
    <% } %>

    <% if (slots != null && !slots.isEmpty()) { %>
        <table>
            <thead>
            <tr>
                <th>학기</th>
                <th>과목명</th>
                <th>교수</th>
                <th>강의실</th>
                <th>원본 텍스트</th>
            </tr>
            </thead>
            <tbody>
            <% for (LectureSlot s : slots) { %>
                <tr>
                    <td><span class="tag"><%= s.semester %></span></td>
                    <td><%= s.courseName %></td>
                    <td><%= s.professor != null ? s.professor : "" %></td>
                    <td><%= s.classroom != null ? s.classroom : "" %></td>
                    <td><%= s.rawText %></td>
                </tr>
            <% } %>
            </tbody>
        </table>
    <% } %>

</div>

</body>
</html>
