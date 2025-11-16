<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../login.jsp';</script>");
        return;
    }

    String title   = request.getParameter("title");
    String content = request.getParameter("content");

    if (title == null || title.trim().isEmpty()) {
        out.println("<script>alert('제목을 입력하세요.'); history.back();</script>");
        return;
    }
    if (content == null || content.trim().isEmpty()) {
        out.println("<script>alert('내용을 입력하세요.'); history.back();</script>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBUtil.getConnection();

        String sql =
            "INSERT INTO BOARD_POST " +
            " (POST_NO, USER_ID, TITLE, CONTENT) " +
            "VALUES (BOARD_POST_SEQ.NEXTVAL, ?, ?, ?)";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        pstmt.setString(2, title);
        pstmt.setString(3, content);
        int cnt = pstmt.executeUpdate();
        pstmt.close();

        if (cnt == 1) {
            out.println("<script>alert('게시글이 등록되었습니다.'); location.href='mainBoard.jsp';</script>");
        } else {
            out.println("<script>alert('게시글 등록에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('게시글 등록 중 오류가 발생했습니다.'); history.back();</script>");
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>
