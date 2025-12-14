<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String ctx = request.getContextPath();

    String userId = (String) session.getAttribute("userId");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='" + ctx + "/login.jsp';</script>");
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

    // 혹시 모를 공백 정리(선택)
    title = title.trim();

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBUtil.getConnection();

        // ✅ 공지사항 테이블로 INSERT
        // 목록에서 NOTICE_NO, HIT, CREATED_AT을 조회하고 있으니,
        // 보통 CREATED_AT은 NOW(), HIT은 0으로 시작하게 함.
        String sql =
            "INSERT INTO BOARD_NOTICE (USER_ID, TITLE, CONTENT, HIT, CREATED_AT) " +
            "VALUES (?, ?, ?, 0, NOW())";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        pstmt.setString(2, title);
        pstmt.setString(3, content);

        int cnt = pstmt.executeUpdate();

        if (cnt == 1) {
            out.println("<script>alert('공지사항이 등록되었습니다.'); location.href='" + ctx + "/notice/noticeMain.jsp';</script>");
        } else {
            out.println("<script>alert('공지사항 등록에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('공지사항 등록 중 오류가 발생했습니다.'); history.back();</script>");
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>
