<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    // GNB에 현재 탭 표시
    request.setAttribute("currentMenu", "board");

    String loginUser = (String) session.getAttribute("userId");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>게시판 - 강남타임</title>
    <style>
        * { box-sizing: border-box; margin:0; padding:0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans KR", sans-serif;
            background:#0f172a;
            color:#e5e7eb;
        }
        a { text-decoration:none; color:inherit; }

        main {
            max-width: 1100px;
            margin: 24px auto 60px;
            padding: 0 20px;
        }
        .board-header {
            display:flex;
            align-items:flex-end;
            justify-content:space-between;
            margin-bottom:14px;
        }
        .board-title {
            font-size:22px;
            font-weight:700;
        }
        .board-sub {
            font-size:12px;
            color:#9ca3af;
            margin-top:4px;
        }
        .btn-write {
            border-radius:999px;
            padding:7px 14px;
            border:none;
            cursor:pointer;
            background:linear-gradient(135deg,#38bdf8,#6366f1);
            color:#0b1120;
            font-size:13px;
            font-weight:600;
        }
        .btn-write:hover { opacity:.93; }

        .board-table-wrap {
            margin-top:10px;
            border-radius:16px;
            overflow:hidden;
            border:1px solid rgba(55,65,81,.9);
            background:#020617;
        }
        table.board-table {
            width:100%;
            border-collapse:collapse;
            font-size:13px;
        }
        .board-table thead {
            background:#020617;
        }
        .board-table th, .board-table td {
            padding:9px 10px;
            border-bottom:1px solid #111827;
        }
        .board-table th {
            text-align:left;
            font-weight:600;
            color:#9ca3af;
            font-size:12px;
        }
        .board-table tbody tr:hover {
            background:#020617;
        }
        .col-no   { width:60px; text-align:center; }
        .col-info { width:190px; text-align:center; }
        .col-hit  { width:70px; text-align:center; }
        .col-like { width:120px; text-align:center; }

        .title-link {
            display:inline-flex;
            align-items:center;
            gap:4px;
        }
        .badge-hot {
            font-size:11px;
            padding:2px 6px;
            border-radius:999px;
            background:rgba(239,68,68,.15);
            color:#fb7185;
        }
        .meta-muted {
            font-size:11px;
            color:#9ca3af;
        }

        .empty-row {
            text-align:center;
            padding:16px 0 !important;
            color:#9ca3af;
        }
    </style>
</head>
<body>

<jsp:include page="/common/gnb.jsp" />

<main>
    <div class="board-header">
        <div>
            <div class="board-title">자유 게시판</div>
            <div class="board-sub">
                강남대 학생들이 자유롭게 소통하는 공간입니다. 공감·스크랩·댓글 기능을 지원합니다.
            </div>
        </div>
        <div>
            <button class="btn-write" onclick="location.href='write.jsp'">글쓰기</button>
        </div>
    </div>

    <div class="board-table-wrap">
        <table class="board-table">
            <thead>
                <tr>
                    <th class="col-no">번호</th>
                    <th>제목</th>
                    <th class="col-info">작성자 / 날짜</th>
                    <th class="col-like">공감 / 댓글</th>
                    <th class="col-hit">조회</th>
                </tr>
            </thead>
            <tbody>
            <%
                try {
                    conn = DBUtil.getConnection();

                    String sql =
                        "SELECT POST_NO, TITLE, USER_ID, " +
                        "       LIKE_COUNT, SCRAP_COUNT, COMMENT_COUNT, HIT, " +
                        "       DATE_FORMAT(CREATED_AT, '%Y-%m-%d') AS CREATED_AT " +
                        "FROM BOARD_POST " +
                        "ORDER BY POST_NO DESC";

                    pstmt = conn.prepareStatement(sql);
                    rs = pstmt.executeQuery();

                    boolean hasRow = false;

                    while (rs.next()) {
                        hasRow = true;
                        int postNo       = rs.getInt("POST_NO");
                        String title     = rs.getString("TITLE");
                        String writer    = rs.getString("USER_ID");
                        int likeCount    = rs.getInt("LIKE_COUNT");
                        int commentCount = rs.getInt("COMMENT_COUNT");
                        int hit          = rs.getInt("HIT");
                        String createdAt = rs.getString("CREATED_AT");
            %>
                <tr onclick="location.href='view.jsp?postNo=<%= postNo %>'" style="cursor:pointer;">
                    <td class="col-no"><%= postNo %></td>
                    <td>
                        <div class="title-link">
                            <span><%= title %></span>
                            <% if (likeCount >= 10 || commentCount >= 10) { %>
                                <span class="badge-hot">HOT</span>
                            <% } %>
                        </div>
                        <div class="meta-muted">
                            공감 <%= likeCount %> · 댓글 <%= commentCount %>
                        </div>
                    </td>
                    <td class="col-info">
                        <div><%= writer %></div>
                        <div class="meta-muted"><%= createdAt %></div>
                    </td>
                    <td class="col-like">
                        <%= likeCount %> 공감<br>
                        <%= commentCount %> 댓글
                    </td>
                    <td class="col-hit"><%= hit %></td>
                </tr>
            <%
                    }

                    if (!hasRow) {
            %>
                <tr>
                    <td colspan="5" class="empty-row">등록된 게시글이 없습니다. 가장 먼저 글을 작성해보세요.</td>
                </tr>
            <%
                    }

                } catch (Exception e) {
                    e.printStackTrace();
            %>
                <tr>
                    <td colspan="5" class="empty-row">게시글을 불러오는 중 오류가 발생했습니다.</td>
                </tr>
            <%
                } finally {
                    try { if (rs != null) rs.close(); } catch (Exception ex) {}
                    try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
                    try { if (conn != null) conn.close(); } catch (Exception ex) {}
                }
            %>
            </tbody>
        </table>
    </div>
</main>

</body>
</html>
