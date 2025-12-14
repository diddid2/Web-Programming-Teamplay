<%@ page import="java.sql.*, java.util.*" %>
<%@ page import="util.DBUtil" %>
<%@ page import="crawler.TimetableCrawler" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%
    request.setCharacterEncoding("UTF-8");

    
    String userId = (String)session.getAttribute("userId");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../login.jsp';</script>");
        return; 
    } 

    
    String ecId = null;
    String ecPw = null;

    try (Connection conn = DBUtil.getConnection();
         PreparedStatement pstmt = conn.prepareStatement(
             "SELECT ECAMPUS_ID, ECAMPUS_PW FROM USER_INTEGRATION WHERE USER_ID = ?")) {

        pstmt.setString(1, userId);

        try (ResultSet rs = pstmt.executeQuery()) {
            if (rs.next()) {
                ecId = rs.getString("ECAMPUS_ID");
                ecPw = rs.getString("ECAMPUS_PW");
            }
        }
    }
 
    if (ecId == null || ecPw == null || ecId.trim().isEmpty() || ecPw.trim().isEmpty()) {
        out.println("<script>alert('설정에서 e캠퍼스 계정을 먼저 등록해주세요.'); history.back();</script>");
        return;
    }

    
    TimetableCrawler crawler = new TimetableCrawler();
    boolean ok = crawler.login(ecId, ecPw);

    if (!ok) {
        out.println("<script>alert('e캠퍼스 로그인 실패.'); history.back();</script>");
        return;
    }

    List<TimetableCrawler.Lecture> list = crawler.fetchTimetable();


    
    int insertCount = 0;

    try (Connection conn = DBUtil.getConnection()) { 

        
        try (PreparedStatement del = conn.prepareStatement(
            "DELETE FROM USER_TIMETABLE WHERE USER_ID = ?")) {
            del.setString(1, userId);
            del.executeUpdate();
        }

        
        String sql =
            "INSERT INTO USER_TIMETABLE " +
            "(USER_ID, TITLE, PROFESSOR, DAY, START_MIN, END_MIN, UPDATED_AT) " +
            "VALUES (?, ?, ?, ?, ?, ?, SYSDATE())";

        try (PreparedStatement ins = conn.prepareStatement(sql)) {
            for (TimetableCrawler.Lecture L : list) {
                ins.setString(1, userId);
                ins.setString(2, L.title);
                ins.setString(3, L.professor);
                ins.setInt(4, L.day);
                ins.setInt(5, L.start);
                ins.setInt(6, L.end);
                insertCount += ins.executeUpdate();
            }
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('시간표 저장 중 오류 발생.'); history.back();</script>");
        return;
    } 

    
    out.println("<script>alert('시간표 동기화 완료! (" + insertCount + "개)'); location.href='../timetable/timetableMain.jsp';</script>");
%>
