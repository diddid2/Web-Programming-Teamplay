<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String everytimeId = request.getParameter("everytimeId");
    String everytimePw = request.getParameter("everytimePw");
    String kangnamId   = request.getParameter("kangnamId");
    String kangnamPw   = request.getParameter("kangnamPw");
    String ecampusId   = request.getParameter("ecampusId");
    String ecampusPw   = request.getParameter("ecampusPw");

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBUtil.getConnection();

        
        String updateSql =
            "UPDATE USER_INTEGRATION " +
            "SET EVERYTIME_ID = ?, EVERYTIME_PW = ?, " +
            "    KANGNAM_ID = ?, KANGNAM_PW = ?, " +
            "    ECAMPUS_ID = ?, ECAMPUS_PW = ?, " +
            "    UPDATED_AT = SYSDATE() " +
            "WHERE USER_ID = ?";

        pstmt = conn.prepareStatement(updateSql);
        pstmt.setString(1, everytimeId);
        pstmt.setString(2, everytimePw);
        pstmt.setString(3, kangnamId);
        pstmt.setString(4, kangnamPw);
        pstmt.setString(5, ecampusId);
        pstmt.setString(6, ecampusPw);
        pstmt.setString(7, userId);

        int updated = pstmt.executeUpdate();
        pstmt.close();

        
        if (updated == 0) {
            String insertSql =
                "INSERT INTO USER_INTEGRATION " +
                "(USER_ID, EVERYTIME_ID, EVERYTIME_PW, KANGNAM_ID, KANGNAM_PW, ECAMPUS_ID, ECAMPUS_PW, UPDATED_AT) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, SYSDATE())";

            pstmt = conn.prepareStatement(insertSql);
            pstmt.setString(1, userId);
            pstmt.setString(2, everytimeId);
            pstmt.setString(3, everytimePw);
            pstmt.setString(4, kangnamId);
            pstmt.setString(5, kangnamPw);
            pstmt.setString(6, ecampusId);
            pstmt.setString(7, ecampusPw);

            pstmt.executeUpdate();
        }

        out.println("<script>alert('계정 연동 정보가 저장되었습니다.');");
        out.println("location.href='settings.jsp';</script>");

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('저장 중 오류가 발생했습니다.');");
        out.println("history.back();</script>");
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>
