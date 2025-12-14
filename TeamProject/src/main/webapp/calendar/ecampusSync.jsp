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
    String ecPw = null;  

    try {
        conn = DBUtil.getConnection();

        
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

        
        EcampusCrawler crawler = new EcampusCrawler();
        boolean ok = crawler.login(ecId, ecPw);

        if (!ok) {
            out.println("<script>alert('이러닝캠퍼스 로그인에 실패했습니다. 계정을 확인해주세요.'); history.back();</script>");
            return;
        }

        List<EcampusCrawler.EcampusAssignment> list = crawler.fetchUpcomingAssignments();
        int insertCount = 0;
		int updateCount = 0;
        for (EcampusCrawler.EcampusAssignment a : list) {
            if (a.title == null || a.title.trim().isEmpty() || a.dueDate == null) continue;
            boolean passed = a.isPassed;

            
            String chkSql =
                "SELECT COUNT(*), IS_PASSED " +
                "FROM ASSIGNMENT " +
                "WHERE USER_ID = ? " +
                "  AND TITLE   = ? " +
                "  AND DUE_DATE = ?" +
                "  GROUP BY IS_PASSED";
            pstmt = conn.prepareStatement(chkSql);
            pstmt.setString(1, userId);
            pstmt.setString(2, a.title.trim());
            pstmt.setDate(3, new java.sql.Date(a.dueDate.getTime()));
            rs = pstmt.executeQuery();

            boolean exists = false;
            if (rs.next() && rs.getInt(1) > 0) exists = true;
            
            if (exists) {
            	if (rs.next() && rs.getInt(1) != (passed ? 1 : 0)) {
	                
	                updateCount++;
	                String updSql =
	                    "UPDATE ASSIGNMENT " +
	                    "SET IS_PASSED = ? " +
	                    "WHERE USER_ID = ? " +
	                    "  AND TITLE   = ? " +
	                    "  AND DUE_DATE = ?";
	                pstmt = conn.prepareStatement(updSql);
	                pstmt.setInt(1, passed ? 1 : 0);
	                pstmt.setString(2, userId);
	                pstmt.setString(3, a.title.trim());
	                pstmt.setDate(4, new java.sql.Date(a.dueDate.getTime()));
	                pstmt.executeUpdate();
	                pstmt.close();
            	}
            	continue;   
            }
            rs.close();
            pstmt.close();

            
            String insSql =
                "INSERT INTO ASSIGNMENT " +
                "(USER_ID, TITLE, COURSE_NAME, START_DATE, DUE_DATE, PRIORITY, STATUS, CREATED_AT, IS_PASSED, LINK) " +
                "VALUES (?, ?, ?, NULL, ?, 1, 'TODO', SYSDATE(), ?, ?)";
            pstmt = conn.prepareStatement(insSql);
            pstmt.setString(1, userId);
            pstmt.setString(2, a.title.trim());
            pstmt.setString(3, a.course);  
            pstmt.setDate(4, new java.sql.Date(a.dueDate.getTime()));
            pstmt.setInt(5, passed ? 1 : 0);   
            pstmt.setString(6, a.link);

            insertCount += pstmt.executeUpdate();
            pstmt.close();
        }

        out.println("<script>alert('e캠퍼스에서 과제 " + insertCount + "건을 동기화했습니다.\\ne캠퍼스에서 과제 완료여부 " + updateCount + "건을 동기화했습니다');"
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
