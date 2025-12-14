<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page import="util.PasswordUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String userId = (String)session.getAttribute("userId");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../login.jsp';</script>");
        return;
    }

    String curPw  = request.getParameter("curPw");
    String newPw  = request.getParameter("newPw");
    String newPw2 = request.getParameter("newPw2");

    if (curPw == null || newPw == null || newPw2 == null ||
        curPw.trim().isEmpty() || newPw.trim().isEmpty() || newPw2.trim().isEmpty()) {
        out.println("<script>alert('비밀번호 입력값이 올바르지 않습니다.'); history.back();</script>");
        return;
    }
    if (!newPw.equals(newPw2)) {
        out.println("<script>alert('새 비밀번호가 서로 일치하지 않습니다.'); history.back();</script>");
        return;
    }
    if (newPw.length() < 6) {
        out.println("<script>alert('새 비밀번호는 6자 이상으로 설정해주세요.'); history.back();</script>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();

        
        String selectSql = "SELECT USER_PW FROM MEMBER WHERE USER_ID = ?";
        pstmt = conn.prepareStatement(selectSql);
        pstmt.setString(1, userId);
        rs = pstmt.executeQuery();

        String storedHash = null;
        if (rs.next()) {
            storedHash = rs.getString("USER_PW");
        }
        rs.close();
        pstmt.close();

        if (storedHash == null) {
            out.println("<script>alert('계정 정보를 찾을 수 없습니다.'); history.back();</script>");
            return;
        }

        
        boolean ok = PasswordUtil.matches(curPw, storedHash);
        if (!ok) {
            out.println("<script>alert('현재 비밀번호가 올바르지 않습니다.'); history.back();</script>");
            return;
        }

        
        String newHash = PasswordUtil.hashPassword(newPw);

        String updateSql = "UPDATE MEMBER SET USER_PW = ? WHERE USER_ID = ?";
        pstmt = conn.prepareStatement(updateSql);
        pstmt.setString(1, newHash);
        pstmt.setString(2, userId);

        int cnt = pstmt.executeUpdate();
        if (cnt == 1) {
            out.println("<script>alert('비밀번호가 변경되었습니다.'); location.href='mypage.jsp';</script>");
        } else {
            out.println("<script>alert('비밀번호 변경에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('비밀번호 변경 중 오류가 발생했습니다.'); history.back();</script>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>
