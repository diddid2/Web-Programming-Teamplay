<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    request.setAttribute("currentMenu", "board");

    String loginUser = (String) session.getAttribute("userId");
    String ctx       = request.getContextPath();

    String postNoStr = request.getParameter("postNo");
    if (postNoStr == null) {
        out.println("<script>alert('잘못된 접근입니다.'); location.href='mainBoard.jsp';</script>");
        return;
    }

    int postNo = Integer.parseInt(postNoStr);

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String title = null;
    String content = null;
    String writer = null;
    String createdAt = null;
    int likeCount = 0;
    int scrapCount = 0;
    int commentCount = 0;
    int hit = 0;

    try {
        conn = DBUtil.getConnection();

        // 1) 조회수 증가
        String hitSql = "UPDATE BOARD_POST SET HIT = HIT + 1 WHERE POST_NO = ?";
        pstmt = conn.prepareStatement(hitSql);
        pstmt.setInt(1, postNo);
        pstmt.executeUpdate();
        pstmt.close();

        // 2) 게시글 정보 조회
        String sql =
            "SELECT TITLE, CONTENT, USER_ID, LIKE_COUNT, SCRAP_COUNT, COMMENT_COUNT, HIT, " +
            "       TO_CHAR(CREATED_AT, 'YYYY-MM-DD HH24:MI') AS CREATED_AT " +
            "FROM BOARD_POST WHERE POST_NO = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, postNo);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            title        = rs.getString("TITLE");
            content      = rs.getString("CONTENT");
            writer       = rs.getString("USER_ID");
            likeCount    = rs.getInt("LIKE_COUNT");
            scrapCount   = rs.getInt("SCRAP_COUNT");
            commentCount = rs.getInt("COMMENT_COUNT");
            hit          = rs.getInt("HIT");
            createdAt    = rs.getString("CREATED_AT");
        } else {
            out.println("<script>alert('게시글을 찾을 수 없습니다.'); location.href='mainBoard.jsp';</script>");
            return;
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<script>alert('게시글을 불러오는 중 오류가 발생했습니다.'); location.href='mainBoard.jsp';</script>");
        return;
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }

    // 내용 줄바꿈 처리
    if (content != null) {
        content = content.replace("\r\n", "<br>").replace("\n", "<br>");
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title><%= title %> - 게시판 - 강남타임</title>
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
        .view-header {
            margin-bottom:16px;
        }
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
        .view-actions-left button,
        .view-actions-right button {
            border-radius:999px;
            padding:5px 12px;
            border:none;
            cursor:pointer;
            font-size:12px;
            background:#111827;
            color:#e5e7eb;
        }
        .view-actions-left button:hover,
        .view-actions-right button:hover {
            background:#1f2937;
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

        /* 댓글 영역 */
        .comment-section {
            margin-top:24px;
        }
        .comment-title {
            font-size:14px;
            font-weight:600;
            margin-bottom:8px;
        }
        .comment-list {
            border-radius:14px;
            border:1px solid #111827;
            background:#020617;
        }
        .comment-item {
            padding:8px 10px;
            border-bottom:1px solid #111827;
            font-size:13px;
        }
        .comment-item:last-child {
            border-bottom:none;
        }
        .comment-meta {
            font-size:11px;
            color:#9ca3af;
            margin-bottom:3px;
        }

        .comment-form {
            margin-top:10px;
        }
        .comment-form textarea {
            width:100%;
            resize:vertical;
            min-height:70px;
            border-radius:10px;
            padding:8px;
            border:1px solid #4b5563;
            background:#020617;
            color:#e5e7eb;
            font-size:13px;
        }
        .comment-form textarea:focus {
            outline:none;
            border-color:#38bdf8;
        }
        .comment-form .btn-row {
            margin-top:6px;
            text-align:right;
        }
        .comment-form button {
            border-radius:999px;
            padding:6px 12px;
            border:none;
            cursor:pointer;
            font-size:12px;
            background:linear-gradient(135deg,#38bdf8,#6366f1);
            color:#0b1120;
            font-weight:600;
        }
    </style>
</head>
<body>

<jsp:include page="/common/gnb.jsp" />

<main>
    <div class="view-header">
        <div class="view-title"><%= title %></div>
        <div class="view-meta">
            <div class="meta-left">
                <span>작성자 <strong><%= writer %></strong></span>
                <span><%= createdAt %></span>
            </div>
            <div class="meta-right">
                <span>조회 <%= hit %></span>
                <span>공감 <%= likeCount %></span>
                <span>스크랩 <%= scrapCount %></span>
                <span>댓글 <%= commentCount %></span>
            </div>
        </div>
    </div>

    <div class="view-body">
        <%= content %>
    </div>

    <div class="view-actions">
        <div class="view-actions-left">
            <form action="boardLikeToggle.jsp" method="post" style="display:inline;">
                <input type="hidden" name="postNo" value="<%= postNo %>">
                <button type="submit">👍 공감 (<%= likeCount %>)</button>
            </form>

            <form action="boardScrapToggle.jsp" method="post" style="display:inline; margin-left:6px;">
                <input type="hidden" name="postNo" value="<%= postNo %>">
                <button type="submit">📌 스크랩 (<%= scrapCount %>)</button>
            </form>
        </div>

        <div class="view-actions-right">
            <button class="btn-list" onclick="location.href='mainBoard.jsp'">목록</button>
        </div>
    </div>

    <!-- 댓글 영역 -->
    <div class="comment-section">
        <div class="comment-title">댓글 (<%= commentCount %>)</div>

        <div class="comment-list">
        <%
            Connection connC = null;
            PreparedStatement pstmtC = null;
            ResultSet rsC = null;

            try {
                connC = DBUtil.getConnection();
                String cSql =
                    "SELECT COMMENT_NO, USER_ID, CONTENT, " +
                    "       TO_CHAR(CREATED_AT, 'YYYY-MM-DD HH24:MI') AS CREATED_AT " +
                    "FROM BOARD_COMMENT " +
                    "WHERE POST_NO = ? " +
                    "ORDER BY COMMENT_NO ASC";
                pstmtC = connC.prepareStatement(cSql);
                pstmtC.setInt(1, postNo);
                rsC = pstmtC.executeQuery();

                boolean hasComment = false;
                while (rsC.next()) {
                    hasComment = true;
        %>
            <div class="comment-item">
                <div class="comment-meta">
                    <strong><%= rsC.getString("USER_ID") %></strong>
                    &nbsp; <%= rsC.getString("CREATED_AT") %>
                </div>
                <div><%= rsC.getString("CONTENT") %></div>
            </div>
        <%
                }
                if (!hasComment) {
        %>
            <div class="comment-item" style="text-align:center; color:#9ca3af;">
                아직 등록된 댓글이 없습니다.
            </div>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
        %>
            <div class="comment-item" style="text-align:center; color:#fca5a5;">
                댓글을 불러오는 중 오류가 발생했습니다.
            </div>
        <%
            } finally {
                try { if (rsC != null) rsC.close(); } catch (Exception ex) {}
                try { if (pstmtC != null) pstmtC.close(); } catch (Exception ex) {}
                try { if (connC != null) connC.close(); } catch (Exception ex) {}
            }
        %>
        </div>

        <!-- 댓글 작성 폼 -->
        <div class="comment-form">
        <%
            if (loginUser != null) {
        %>
            <form action="commentWriteProc.jsp" method="post">
                <input type="hidden" name="postNo" value="<%= postNo %>">
                <textarea name="content" placeholder="댓글을 입력하세요."></textarea>
                <div class="btn-row">
                    <button type="submit">댓글 작성</button>
                </div>
            </form>
        <%
            } else {
        %>
            <div style="font-size:12px; color:#9ca3af; margin-top:6px;">
                댓글을 작성하려면 <a href="<%= ctx %>/login.jsp" style="color:#38bdf8;">로그인</a>이 필요합니다.
            </div>
        <%
            }
        %>
        </div>
    </div>
</main>

</body>
</html>
