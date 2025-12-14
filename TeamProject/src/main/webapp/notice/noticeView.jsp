<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%!
    public String h(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    request.setCharacterEncoding("UTF-8");
    request.setAttribute("currentMenu", "notice");

    String loginUser = (String) session.getAttribute("userId");
    String ctx       = request.getContextPath();

    // ✅ 공지 파라미터는 noticeNo로 통일
    String noticeNoStr = request.getParameter("noticeNo");
    if (noticeNoStr == null) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='" + ctx + "/notice/noticeMain.jsp';</script>");
        return;
    }

    int noticeNo = 0;
    try {
        noticeNo = Integer.parseInt(noticeNoStr);
    } catch (Exception ex) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='" + ctx + "/notice/noticeMain.jsp';</script>");
        return;
    }

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String title = null;
    String content = null;
    String writer = null;
    String createdAt = null;
    int hit = 0;

    try {
        conn = DBUtil.getConnection();

        // ✅ 1) 조회수 증가 (공지 테이블)
        String hitSql = "UPDATE BOARD_NOTICE SET HIT = HIT + 1 WHERE NOTICE_NO = ?";
        pstmt = conn.prepareStatement(hitSql);
        pstmt.setInt(1, noticeNo);
        pstmt.executeUpdate();
        pstmt.close();

        // ✅ 2) 공지 정보 조회
        String sql =
            "SELECT TITLE, CONTENT, USER_ID, HIT, " +
            "       DATE_FORMAT(CREATED_AT, '%Y-%m-%d') AS CREATED_AT " +
            "FROM BOARD_NOTICE WHERE NOTICE_NO = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, noticeNo);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            title     = rs.getString("TITLE");
            content   = rs.getString("CONTENT");
            writer    = rs.getString("USER_ID");
            hit       = rs.getInt("HIT");
            createdAt = rs.getString("CREATED_AT");
        } else {
            out.println("<script>alert('공지사항을 찾을 수 없습니다.'); location.href='" + ctx + "/notice/noticeMain.jsp';</script>");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('공지사항을 불러오는 중 오류가 발생했습니다.'); location.href='" + ctx + "/notice/noticeMain.jsp';</script>");
        return;
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }

    // ✅ 내용 줄바꿈 처리 (기존 유지)
    if (content != null) {
        content = content.replace("\r\n", "<br>").replace("\n", "<br>");
    }

   
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title><%= h(title) %> - 공지사항 - 강남타임</title>
    <style>
        * { box-sizing:border-box; margin:0; padding:0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans KR", sans-serif;
            background:#0f172a;
            color:#e5e7eb;
        }
        a { text-decoration:none; color:inherit; }

        main {
            max-width: 900px;
            margin: 24px auto 60px;
            padding: 0 20px;
        }
        .view-header { margin-bottom:16px; }
        .view-title {
            font-size:22px;
            font-weight:700;
            margin-bottom:6px;
        }
        .view-meta {
            font-size:12px;
            color:#9ca3af;
            display:flex;
            justify-content:space-between;
            gap:8px;
            flex-wrap:wrap;
        }
        .meta-left span + span::before,
        .meta-right span + span::before {
            content:"·";
            margin:0 4px;
        }

        .view-body {
            margin-top:14px;
            padding:18px 16px 22px;
            border-radius:16px;
            background:#020617;
            border:1px solid rgba(55,65,81,.9);
            font-size:14px;
            line-height:1.6;
            min-height:120px;
        }

        .view-actions {
            margin-top:10px;
            display:flex;
            justify-content:space-between;
            align-items:center;
        }
        .btn-list {
            border-radius:999px;
            padding:6px 12px;
            border:none;
            cursor:pointer;
            font-size:12px;
            background:#111827;
            color:#e5e7eb;
        }
        .btn-list:hover { background:#1f2937; }
    </style>
</head>
<body>

<jsp:include page="/common/gnb.jsp" />

<main>
    <div class="view-header">
        <div class="view-title"><%= h(title) %></div>
        <div class="view-meta">
            <div class="meta-left">
                <span>작성자 <strong><%= h(writer) %></strong></span>
                <span><%= createdAt %></span>
            </div>
            <div class="meta-right">
                <span>조회 <%= hit %></span>
            </div>
        </div>
    </div>

    <div class="view-body">
        <%= content %>
    </div>

    <div class="view-actions">
        <div></div>
        <div>
            <button class="btn-list" onclick="location.href='<%= ctx %>/notice/noticeMain.jsp'">목록</button>
        </div>
    </div>
</main>

</body>
</html>
