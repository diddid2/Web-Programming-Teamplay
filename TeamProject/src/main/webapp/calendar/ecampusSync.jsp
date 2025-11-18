<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="util.DBUtil" %>
<%@ page import="crawler.EcampusCrawler" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String userId = (String)session.getAttribute("userId");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../login.jsp';</script>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String ecId = null;
    String ecPw = null;  // 여기서는 USER_INTEGRATION에 평문 또는 이미 복호화된 값이 들어있다고 가정

    try {
        conn = DBUtil.getConnection();

        // 1) USER_INTEGRATION에서 이러닝캠퍼스 계정 정보 가져오기
        String sql =
            "SELECT ECAMPUS_ID, ECAMPUS_PW " +
            "FROM USER_INTEGRATION " +
            "WHERE USER_ID = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            ecId = rs.getString("ECAMPUS_ID");
            ecPw = rs.getString("ECAMPUS_PW");
        }

        rs.close();
        pstmt.close();

        if (ecId == null || ecId.trim().isEmpty() ||
            ecPw == null || ecPw.trim().isEmpty()) {
            out.println("<script>alert('설정에서 이러닝캠퍼스 계정을 먼저 등록해주세요.'); history.back();</script>");
            return;
        }

        // 2) 크롤러 로그인 + 과제 목록 가져오기
        EcampusCrawler crawler = new EcampusCrawler();
        boolean ok = crawler.login(ecId, ecPw);

        if (!ok) {
            out.println("<script>alert('이러닝캠퍼스 로그인에 실패했습니다. 계정을 확인해주세요.'); history.back();</script>");
            return;
        }

        List<EcampusCrawler.EcampusAssignment> list = crawler.fetchUpcomingAssignments();
        int insertCount = 0;

        // 3) ASSIGNMENT 테이블과 중복 체크 후 신규 과제만 INSERT
        for (EcampusCrawler.EcampusAssignment a : list) {
            if (a.title == null || a.title.trim().isEmpty() || a.dueDate == null) continue;

            // 중복 기준: USER_ID + TITLE + DUE_DATE
            String chkSql =
                "SELECT COUNT(*) " +
                "FROM ASSIGNMENT " +
                "WHERE USER_ID = ? " +
                "  AND TITLE   = ? " +
                "  AND DUE_DATE = ?";
            pstmt = conn.prepareStatement(chkSql);
            pstmt.setString(1, userId);
            pstmt.setString(2, a.title.trim());
            pstmt.setDate(3, new java.sql.Date(a.dueDate.getTime()));
            rs = pstmt.executeQuery();

            boolean exists = false;
            if (rs.next() && rs.getInt(1) > 0) exists = true;

            rs.close();
            pstmt.close();

            if (exists) continue;

            String insSql =
                "INSERT INTO ASSIGNMENT " +
                "(ASSIGN_NO, USER_ID, TITLE, COURSE_NAME, START_DATE, DUE_DATE, PRIORITY, STATUS, CREATED_AT) " +
                "VALUES (ASSIGNMENT_SEQ.NEXTVAL, ?, ?, ?, NULL, ?, 1, 'TODO', SYSDATE)";
            pstmt = conn.prepareStatement(insSql);
            pstmt.setString(1, userId);
            pstmt.setString(2, a.title.trim());
            pstmt.setString(3, a.course);  // 크롤러에서 과목명 파싱해오면 세팅, 아니면 null
            pstmt.setDate(4, new java.sql.Date(a.dueDate.getTime()));

            insertCount += pstmt.executeUpdate();
            pstmt.close();
        }

        out.println("<script>alert('e캠퍼스에서 과제 " + insertCount + "건을 동기화했습니다.');"
                  + "location.href='calendarMain.jsp';</script>");

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('동기화 중 오류가 발생했습니다. 콘솔 로그를 확인해주세요.'); history.back();</script>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>
