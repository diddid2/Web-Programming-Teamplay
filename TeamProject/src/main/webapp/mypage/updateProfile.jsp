<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String userId = (String)session.getAttribute("userId");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../login.jsp';</script>");
        return;
    }

    String name  = request.getParameter("name");
    String major = request.getParameter("major");

    if (name == null || name.trim().isEmpty()) {
        out.println("<script>alert('이름을 입력해주세요.'); history.back();</script>");
        return;
    }
    if (major == null) major = "";

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBUtil.getConnection();
        String sql = "UPDATE MEMBER SET NAME = ?, MAJOR = ? WHERE USER_ID = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, name.trim());
        pstmt.setString(2, major.trim());
        pstmt.setString(3, userId);

        int cnt = pstmt.executeUpdate();
        if (cnt == 1) {
            
            session.setAttribute("userName", name.trim());
            out.println("<script>alert('프로필이 수정되었습니다.'); location.href='mypage.jsp';</script>");
        } else {
            out.println("<script>alert('프로필 수정에 실패했습니다.'); history.back();</script>");
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('프로필 수정 중 오류가 발생했습니다.'); history.back();</script>");
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>
