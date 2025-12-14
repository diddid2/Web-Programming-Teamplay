<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); history.back();</script>");
        return;
    }

    int postNo = Integer.parseInt(request.getParameter("postNo"));
    String referer = request.getHeader("Referer"); 

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();

        
        String checkSql = "SELECT 1 FROM BOARD_LIKE WHERE POST_NO = ? AND USER_ID = ?";
        pstmt = conn.prepareStatement(checkSql);
        pstmt.setInt(1, postNo);
        pstmt.setString(2, userId);
        rs = pstmt.executeQuery();

        boolean alreadyLiked = rs.next();
        rs.close();
        pstmt.close();

        if (alreadyLiked) {
            
            String delSql = "DELETE FROM BOARD_LIKE WHERE POST_NO = ? AND USER_ID = ?";
            pstmt = conn.prepareStatement(delSql);
            pstmt.setInt(1, postNo);
            pstmt.setString(2, userId);
            pstmt.executeUpdate();
            pstmt.close();

            String updateSql = "UPDATE BOARD_POST SET LIKE_COUNT = LIKE_COUNT - 1 WHERE POST_NO = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setInt(1, postNo);
            pstmt.executeUpdate();
        } else {
            
            String insSql = "INSERT INTO BOARD_LIKE (POST_NO, USER_ID) VALUES (?, ?)";
            pstmt = conn.prepareStatement(insSql);
            pstmt.setInt(1, postNo);
            pstmt.setString(2, userId);
            pstmt.executeUpdate();
            pstmt.close();

            String updateSql = "UPDATE BOARD_POST SET LIKE_COUNT = LIKE_COUNT + 1 WHERE POST_NO = ?";
            pstmt = conn.prepareStatement(updateSql);
            pstmt.setInt(1, postNo);
            pstmt.executeUpdate();
        }

        if (referer == null) referer = "mainBoard.jsp";
        response.sendRedirect(referer);

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('공감 처리 중 오류가 발생했습니다.'); history.back();</script>");
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>
