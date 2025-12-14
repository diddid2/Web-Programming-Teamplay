<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    // GNB에 현재 탭 표시
    request.setAttribute("currentMenu", "notice");

    String ctx = request.getContextPath();

    String loginUser = (String) session.getAttribute("userId");
    String loginName = (String) session.getAttribute("userName");

    if (loginUser == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='" + ctx + "/login.jsp';</script>");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>공지 등록 - 강남타임</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
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
            gap:12px;
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
            white-space:nowrap;
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
            margin-bottom:6px;
            color:#cbd5e1;
        }
        .write-form input[type="text"] {
            width:100%;
            padding:9px 10px;
            border-radius:10px;
            border:1px solid #4b5563;
            background:#020617;
            color:#e5e7eb;
            font-size:13px;
            margin-bottom:12px;
        }
        .write-form input[type="text"]:focus {
            outline:none;
            border-color:#38bdf8;
        }
        .write-form textarea {
            width:100%;
            min-height:260px;
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
            padding:8px 14px;
            font-size:13px;
            border:none;
            cursor:pointer;
        }
        .btn-cancel {
            background:#111827;
            color:#e5e7eb;
        }
        .btn-cancel:hover { background:#1f2937; }

        .btn-submit {
            background:linear-gradient(135deg,#38bdf8,#6366f1);
            color:#0b1120;
            font-weight:700;
        }
        .btn-submit:hover { opacity:.93; }
    </style>
</head>
<body>

<jsp:include page="/common/gnb.jsp" />

<main>
    <div class="write-header">
        <div>
            <div class="write-title">공지 등록</div>
            <div class="write-sub">공지사항에 새로운 공지를 작성합니다.</div>
        </div>
        <div class="write-meta">
            작성자: <strong><%= (loginName != null ? loginName : loginUser) %></strong>
        </div>
    </div>

    <!-- 공지 등록 처리 -->
    <form class="write-form" action="<%= ctx %>/notice/noticeWriteProc.jsp" method="post">
        <label for="title">제목</label>
        <input type="text" id="title" name="title" maxlength="200" required
               placeholder="공지 제목을 입력하세요">

        <label for="content">내용</label>
        <textarea id="content" name="content" required
                  placeholder="공지 내용을 입력하세요"></textarea>

        <div class="write-buttons">
            <button type="button" class="btn-cancel"
                    onclick="if(confirm('작성 중인 내용을 취소하시겠습니까?')) location.href='<%= ctx %>/notice/noticeMain.jsp';">
                취소
            </button>
            <button type="submit" class="btn-submit">등록하기</button>
        </div>
    </form>
</main>

</body>
</html>
