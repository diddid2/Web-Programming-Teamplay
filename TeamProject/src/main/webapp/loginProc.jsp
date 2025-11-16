<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page import="util.PasswordUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String userId = request.getParameter("userId");
    String userPw = request.getParameter("userPw");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();

        // 입력된 비밀번호를 해시
        String hashedInputPw = PasswordUtil.hashPassword(userPw);

        String sql = "SELECT USER_ID, NAME, USER_PW " +
                     "FROM MEMBER " +
                     "WHERE USER_ID = ? AND USER_PW = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        pstmt.setString(2, hashedInputPw);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            session.setAttribute("userId", rs.getString("USER_ID"));
            session.setAttribute("userName", rs.getString("NAME"));

            out.println("<script>alert('로그인 되었습니다.');");
            out.println("location.href='main.jsp';</script>");
        } else {
            out.println("<script>alert('아이디 또는 비밀번호가 올바르지 않습니다.');");
            out.println("history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('시스템 오류가 발생했습니다.');");
        out.println("history.back();</script>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>
