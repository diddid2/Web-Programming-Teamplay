<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String loginUser = (String) session.getAttribute("userId");
    if (loginUser == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../login.jsp';</script>");
        return;
    }

    String title      = request.getParameter("title");
    String courseName = request.getParameter("courseName");
    String startStr   = request.getParameter("startDate");
    String dueStr     = request.getParameter("dueDate");
    String prioStr    = request.getParameter("priority");
    String desc       = request.getParameter("description");

    String yearParam  = request.getParameter("year");
    String monthParam = request.getParameter("month");

    int year  = (yearParam  != null ? Integer.parseInt(yearParam)  : 0);
    int month = (monthParam != null ? Integer.parseInt(monthParam) : 0);

    if (title == null || title.trim().isEmpty()) {
        out.println("<script>alert('과제 제목을 입력하세요.'); history.back();</script>");
        return;
    }
    if (dueStr == null || dueStr.trim().isEmpty()) {
        out.println("<script>alert('마감일을 선택하세요.'); history.back();</script>");
        return;
    }

    java.sql.Date startDate = null;
    java.sql.Date dueDate   = null;

    try {
        if (startStr != null && !startStr.trim().isEmpty()) {
            startDate = java.sql.Date.valueOf(startStr); // yyyy-MM-dd
        }
        dueDate = java.sql.Date.valueOf(dueStr);
    } catch (IllegalArgumentException e) {
        out.println("<script>alert('날짜 형식이 올바르지 않습니다.'); history.back();</script>");
        return;
    }

    int priority = 0;
    try {
        priority = Integer.parseInt(prioStr);
    } catch (Exception e) {
        priority = 0;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;

    try {
        conn = DBUtil.getConnection();

        String sql =
            "INSERT INTO ASSIGNMENT " +
            "(ASSIGN_NO, USER_ID, TITLE, COURSE_NAME, DESCRIPTION, START_DATE, DUE_DATE, PRIORITY, STATUS, CREATED_AT) " +
            "VALUES (ASSIGNMENT_SEQ.NEXTVAL, ?, ?, ?, ?, ?, ?, ?, 'TODO', SYSDATE)";

        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, loginUser);
        pstmt.setString(2, title);
        pstmt.setString(3, courseName);
        pstmt.setString(4, desc);
        if (startDate != null)
            pstmt.setDate(5, startDate);
        else
            pstmt.setNull(5, java.sql.Types.DATE);
        pstmt.setDate(6, dueDate);
        pstmt.setInt(7, priority);

        int cnt = pstmt.executeUpdate();

        if (cnt == 1) {
            // 등록 성공 → 다시 해당 월 캘린더로
            if (year > 0 && month > 0) {
                out.println("<script>alert('과제가 등록되었습니다.'); location.href='calendarMain.jsp?year=" + year + "&month=" + month + "';</script>");
            } else {
                out.println("<script>alert('과제가 등록되었습니다.'); location.href='calendarMain.jsp';</script>");
            }
        } else {
            out.println("<script>alert('과제 등록에 실패했습니다.'); history.back();</script>");
        }

    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('과제 등록 중 오류가 발생했습니다.'); history.back();</script>");
    } finally {
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>
