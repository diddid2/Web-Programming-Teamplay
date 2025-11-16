<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>핫 게시판 - 강남타임</title>
    <style>
        * { box-sizing:border-box; margin:0; padding:0; }
        body {
            font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Noto Sans KR",sans-serif;
            background:#0f172a; color:#e5e7eb;
        }
        a { text-decoration:none; color:inherit; }
        header {
            position:sticky; top:0; z-index:10;
            background:rgba(15,23,42,.9);
            border-bottom:1px solid rgba(148,163,184,.4);
        }
        .nav-inner {
            max-width:1100px; margin:0 auto;
            padding:12px 20px;
            display:flex; align-items:center; justify-content:space-between;
        }
        .logo { display:flex; gap:8px; align-items:center; font-weight:700; }
        .logo-mark {
            width:26px; height:26px; border-radius:999px;
            border:2px solid #38bdf8; display:flex; align-items:center; justify-content:center;
            font-size:13px; color:#38bdf8;
        }
        .nav-links { display:flex; gap:14px; font-size:14px; color:#cbd5f5; }
        .nav-links a { padding:6px 10px; border-radius:999px; }
        .nav-links a:hover { background:rgba(148,163,184,.15); color:#f9fafb; }
        .nav-auth { display:flex; gap:10px; font-size:13px; align-items:center; }
        .btn-outline {
            padding:6px 12px; border-radius:999px;
            border:1px solid rgba(148,163,184,.7);
            background:transparent; color:#e5e7eb; cursor:pointer;
        }
        .btn-primary {
            padding:6px 14px; border-radius:999px;
            border:none; background:linear-gradient(135deg,#38bdf8,#6366f1);
            color:#0b1120; font-weight:600; cursor:pointer;
        }
        main {
            max-width:900px; margin:24px auto 60px;
            padding:0 20px;
        }
        .board-header {
            display:flex; justify-content:space-between; align-items:flex-end;
            margin-bottom:14px;
        }
        .board-title { font-size:22px; font-weight:700; }
        .board-desc { font-size:12px; color:#9ca3af; }
        .board-table {
            width:100%; border-collapse:collapse;
            background:#020617; border-radius:14px;
            overflow:hidden; border:1px solid rgba(148,163,184,.5);
        }
        .board-table th, .board-table td {
            padding:9px 10px; font-size:13px;
            border-bottom:1px solid rgba(31,41,55,.9);
        }
        .board-table th { text-align:left; color:#9ca3af; }
        .col-no { width:60px; text-align:center; }
        .col-title { }
        .col-writer { width:140px; text-align:center; }
        .col-hit { width:70px; text-align:center; }
        .col-like { width:70px; text-align:center; }
        .col-date { width:120px; text-align:center; }
        .title-link:hover { text-decoration:underline; }
        .no-data { text-align:center; padding:20px 0; font-size:13px; color:#9ca3af; }
    </style>
</head>
<body>
<header>
    <div class="nav-inner">
        <div class="logo">
            <div class="logo-mark">KT</div>
            <span>강남타임</span>
        </div>
        <nav class="nav-links">
            <a href="../main.jsp">홈</a>
            <a href="mainBoard.jsp">게시판</a>
            <a href="hotBoard.jsp" style="background:rgba(248,113,113,.18);">핫게시판</a>
            <a href="../calendar/calendarMain.jsp">캘린더</a>
            <a href="../dalgugi/dalgugiMain.jsp">달구지</a>
        </nav>
        <div class="nav-auth">
            <%
                if (userId == null) {
            %>
            <button class="btn-outline" onclick="location.href='../login.jsp'">로그인</button>
            <button class="btn-primary" onclick="location.href='../signup.jsp'">회원가입</button>
            <%
                } else {
            %>
            <span><strong><%= userName != null ? userName : userId %></strong> 님</span>
            <button class="btn-primary" onclick="location.href='../logout.jsp'">로그아웃</button>
            <%
                }
            %>
        </div>
    </div>
</header>

<main>
    <div class="board-header">
        <div>
            <div class="board-title">핫 게시판</div>
            <div class="board-desc">조회수와 좋아요가 많은 글만 모아 보여줍니다.</div>
        </div>
    </div>

    <table class="board-table">
        <thead>
        <tr>
            <th class="col-no">번호</th>
            <th class="col-title">제목</th>
            <th class="col-writer">작성자</th>
            <th class="col-hit">조회</th>
            <th class="col-like">좋아요</th>
            <th class="col-date">작성일</th>
        </tr>
        </thead>
        <tbody>
        <%
            Connection conn = null;
            PreparedStatement pstmt = null;
            ResultSet rs = null;

            try {
                conn = DBUtil.getConnection();
                String sql =
                    "SELECT POST_NO, TITLE, WRITER_NAME, HIT, LIKE_COUNT, CREATED_AT " +
                    "FROM BOARD_POST " +
                    "WHERE HIT >= 20 OR LIKE_COUNT >= 5 " +
                    "ORDER BY HIT DESC, LIKE_COUNT DESC";
                pstmt = conn.prepareStatement(sql);
                rs = pstmt.executeQuery();

                boolean hasData = false;
                while (rs.next()) {
                    hasData = true;
                    int postNo = rs.getInt("POST_NO");
                    String title = rs.getString("TITLE");
                    String writer = rs.getString("WRITER_NAME");
                    if (writer == null) writer = "(알수없음)";
                    int hit = rs.getInt("HIT");
                    int likeCount = rs.getInt("LIKE_COUNT");
                    String date = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm")
                            .format(rs.getTimestamp("CREATED_AT"));
        %>
        <tr>
            <td class="col-no"><%= postNo %></td>
            <td class="col-title">
                <a class="title-link" href="view.jsp?postNo=<%= postNo %>"><%= title %></a>
            </td>
            <td class="col-writer"><%= writer %></td>
            <td class="col-hit"><%= hit %></td>
            <td class="col-like"><%= likeCount %></td>
            <td class="col-date"><%= date %></td>
        </tr>
        <%
                }
                if (!hasData) {
        %>
        <tr>
            <td colspan="6" class="no-data">아직 HOT 게시글이 없습니다.</td>
        </tr>
        <%
                }
            } catch (Exception e) {
                e.printStackTrace();
        %>
        <tr>
            <td colspan="6" class="no-data">게시글을 불러오는 중 오류가 발생했습니다.</td>
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
</main>
</body>
</html>
