<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page import="util.PasswordUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String userId = request.getParameter("userId");
    String userPw = request.getParameter("userPw");
    String name   = request.getParameter("name");
    String major  = request.getParameter("major");

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBUtil.getConnection();

        // 비밀번호 해시
        String hashedPw = PasswordUtil.hashPassword(userPw);

        String sql = "INSERT INTO MEMBER (MEMBER_NO, USER_ID, USER_PW, NAME, MAJOR) " +
                     "VALUES (MEMBER_SEQ.NEXTVAL, ?, ?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        pstmt.setString(2, hashedPw);
        pstmt.setString(3, name);
        pstmt.setString(4, major);

        int cnt = pstmt.executeUpdate();

        if (cnt == 1) {
            out.println("<script>alert('회원가입이 완료되었습니다. 로그인해주세요.');");
            out.println("location.href='login.jsp';</script>");
        } else {
            out.println("<script>alert('회원가입에 실패했습니다. 다시 시도해주세요.');");
            out.println("history.back();</script>");
        }

    } catch (SQLIntegrityConstraintViolationException e) {
        out.println("<script>alert('이미 사용 중인 아이디입니다. 다른 아이디를 사용해주세요.');");
        out.println("history.back();</script>");
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('시스템 오류가 발생했습니다.');");
        out.println("history.back();</script>");
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>
