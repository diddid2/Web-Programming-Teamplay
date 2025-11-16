<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    request.setAttribute("currentMenu", "board");

    String loginUser = (String) session.getAttribute("userId");
    String loginName = (String) session.getAttribute("userName");

    if (loginUser == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../login.jsp';</script>");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>글쓰기 - 게시판 - 강남타임</title>
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
        .write-header {
            display:flex;
            justify-content:space-between;
            align-items:flex-end;
            margin-bottom:16px;
        }
        .write-title {
            font-size:22px;
            font-weight:700;
        }
        .write-sub {
            font-size:12px;
            color:#9ca3af;
            margin-top:4px;
        }

        .write-meta {
            font-size:12px;
            color:#9ca3af;
            text-align:right;
        }

        .write-form {
            margin-top:10px;
            padding:18px 16px 20px;
            border-radius:18px;
            border:1px solid rgba(55,65,81,.9);
            background:#020617;
        }
        .write-form label {
            display:block;
            font-size:13px;
            margin-bottom:4px;
        }
        .write-form input[type="text"] {
            width:100%;
            padding:8px 10px;
            border-radius:10px;
            border:1px solid #4b5563;
            background:#020617;
            color:#e5e7eb;
            font-size:13px;
            margin-bottom:10px;
        }
        .write-form input[type="text"]:focus {
            outline:none;
            border-color:#38bdf8;
        }
        .write-form textarea {
            width:100%;
            min-height:220px;
            resize:vertical;
            padding:10px;
            border-radius:10px;
            border:1px solid #4b5563;
            background:#020617;
            color:#e5e7eb;
            font-size:13px;
            line-height:1.6;
        }
        .write-form textarea:focus {
            outline:none;
            border-color:#38bdf8;
        }
        .write-buttons {
            margin-top:14px;
            display:flex;
            justify-content:flex-end;
            gap:8px;
        }
        .btn-cancel, .btn-submit {
            border-radius:999px;
            padding:7px 14px;
            font-size:13px;
            border:none;
            cursor:pointer;
        }
        .btn-cancel {
            background:#111827;
            color:#e5e7eb;
        }
        .btn-cancel:hover {
            background:#1f2937;
        }
        .btn-submit {
            background:linear-gradient(135deg,#38bdf8,#6366f1);
            color:#0b1120;
            font-weight:600;
        }
        .btn-submit:hover { opacity:.93; }
    </style>
</head>
<body>

<jsp:include page="/common/gnb.jsp" />

<main>
    <div class="write-header">
        <div>
            <div class="write-title">글쓰기</div>
            <div class="write-sub">자유 게시판에 새로운 글을 작성합니다.</div>
        </div>
        <div class="write-meta">
            작성자: <strong><%= (loginName != null ? loginName : loginUser) %></strong>
        </div>
    </div>

    <form class="write-form" action="writeProc.jsp" method="post">
        <label for="title">제목</label>
        <input type="text" id="title" name="title" maxlength="200" required>

        <label for="content">내용</label>
        <textarea id="content" name="content" required></textarea>

        <div class="write-buttons">
            <button type="button" class="btn-cancel"
                    onclick="if(confirm('작성 중인 내용을 취소하시겠습니까?')) location.href='mainBoard.jsp';">
                취소
            </button>
            <button type="submit" class="btn-submit">등록하기</button>
        </div>
    </form>
</main>

</body>
</html>
