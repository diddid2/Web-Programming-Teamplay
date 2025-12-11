<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); history.back();</script>");
        return;
    }

    int postNo = Integer.parseInt(request.getParameter("postNo"));
    String content = request.getParameter("content");
    String referer = request.getHeader("Referer");

    if (content == null || content.trim().isEmpty()) {
        out.println("<script>alert('댓글 내용을 입력하세요.'); history.back();</script>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBUtil.getConnection();

        String sql = "INSERT INTO BOARD_COMMENT (POST_NO, USER_ID, CONTENT) " +
                     "VALUES (?, ?, ?)";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, postNo);
        pstmt.setString(2, userId);
        pstmt.setString(3, content);
        pstmt.executeUpdate();
        pstmt.close();

        String updateSql = "UPDATE BOARD_POST SET COMMENT_COUNT = COMMENT_COUNT + 1 WHERE POST_NO = ?";
        pstmt = conn.prepareStatement(updateSql);
        pstmt.setInt(1, postNo);
        pstmt.executeUpdate();

        if (referer == null) referer = "view.jsp?postNo=" + postNo;
        response.sendRedirect(referer);

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('댓글 작성 중 오류가 발생했습니다.'); history.back();</script>");
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>
