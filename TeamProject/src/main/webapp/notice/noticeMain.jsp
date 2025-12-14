<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    
    request.setAttribute("currentMenu", "notice");

    String loginUser = (String) session.getAttribute("userId");

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지사항 - 강남타임</title>
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
            <div class="board-title">공지사항</div>
            <div class="board-sub">
                강남타임의 주요 안내와 공지 사항을 확인할 수 있는 공간입니다.
            </div>
        </div>
        <div>
            
            <button class="btn-write" onclick="location.href='noticeWrite.jsp'">공지 등록</button>
        </div>
    </div>

    <div class="board-table-wrap">
        <table class="board-table">
            <thead>
                <tr>
                    <th class="col-no">번호</th>
                    <th>제목</th>
                    <th class="col-info">작성자 / 날짜</th>
                    <th class="col-hit">조회</th>
                </tr>
            </thead>
            <tbody>
            <%
                try {
                    conn = DBUtil.getConnection();

                    
                    String sql =
                        "SELECT NOTICE_NO, TITLE, USER_ID, " +
                        "       HIT, DATE_FORMAT(CREATED_AT, '%Y-%m-%d') AS CREATED_AT " +
                        "FROM BOARD_NOTICE " +
                        "ORDER BY NOTICE_NO DESC";

                    pstmt = conn.prepareStatement(sql);
                    rs = pstmt.executeQuery();

                    boolean hasRow = false;

                    while (rs.next()) {
                        hasRow = true;
                        int noticeNo    = rs.getInt("NOTICE_NO");
                        String title    = rs.getString("TITLE");
                        String writer   = rs.getString("USER_ID");
                        int hit         = rs.getInt("HIT");
                        String createdAt= rs.getString("CREATED_AT");
            %>
                <tr onclick="location.href='noticeView.jsp?noticeNo=<%= noticeNo %>'" style="cursor:pointer;">
                    <td class="col-no"><%= noticeNo %></td>
                    <td>
                        <div class="title-link">
                            <span><%= title %></span>
                            


                        </div>
                    </td>
                    <td class="col-info">
                        <div><%= writer %></div>
                        <div class="meta-muted"><%= createdAt %></div>
                    </td>
                    <td class="col-hit"><%= hit %></td>
                </tr>
            <%
                    }

                    if (!hasRow) {
            %>
                <tr>
                    <td colspan="4" class="empty-row">등록된 공지사항이 없습니다.</td>
                </tr>
            <%
                    }

                } catch (Exception e) {
                    e.printStackTrace();
            %>
                <tr>
                    <td colspan="4" class="empty-row">공지사항을 불러오는 중 오류가 발생했습니다.</td>
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
