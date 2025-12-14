<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userId = (String) session.getAttribute("userId");
    if (userId != null) {  // 이미 로그인 상태면 메인으로
        response.sendRedirect("main.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>로그인 - 강남타임</title>
    <style>
 		* {
    		box-sizing: border-box;
    		margin: 0;
    		padding: 0;
		}
        body {
            margin: 0;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans KR", sans-serif;
            background: #0f172a;
            color: #e5e7eb;
        }
        a { color: inherit; text-decoration: none; }

        header {
            position: sticky; top: 0; z-index: 10;
            background: rgba(15, 23, 42, .9);
            border-bottom: 1px solid rgba(148, 163, 184, .4);
        }
        .nav-inner {
            max-width: 900px; margin: 0 auto;
            padding: 12px 20px;
            display: flex; align-items: center; justify-content: space-between;
        }
        .logo { display:flex; gap:8px; align-items:center; font-weight:700; }
        .logo-mark {
            width:26px; height:26px; border-radius:999px;
            border:2px solid #38bdf8; display:flex; align-items:center; justify-content:center;
            font-size:13px; color:#38bdf8;
        }

        main {
            max-width: 380px;
            margin: 80px auto;
            padding: 22px 22px 26px;
            background: #020617;
            border-radius: 18px;
            border: 1px solid rgba(148,163,184,.5);
            box-shadow: 0 20px 40px rgba(15,23,42,.9);
        }
        h2 { margin:0 0 8px; font-size:22px; }
        .sub { font-size:13px; color:#9ca3af; margin-bottom:18px; }

        label { display:block; font-size:13px; margin-bottom:4px; }
        input {
            width:100%;
            padding:8px 10px;
            border-radius:10px;
            border:1px solid rgba(148,163,184,.6);
            background:#020617;
            color:#e5e7eb;
            font-size:13px;
            margin-bottom:12px;
        }
        input:focus {
            outline:none;
            border-color:#38bdf8;
        }
        .btn-primary {
            width:100%;
            border:none;
            border-radius:999px;
            padding:9px 0;
            background:linear-gradient(135deg,#38bdf8,#6366f1);
            color:#0b1120;
            font-weight:600;
            cursor:pointer;
            margin-top:6px;
        }
        .btn-primary:hover { opacity:.93; }
        .bottom-text {
            margin-top:14px;
            font-size:12px;
            color:#9ca3af;
            text-align:center;
        }
        .bottom-text a { color:#38bdf8; }
    </style>
</head>
<body>
<jsp:include page="common/gnb.jsp"/>

<main>
    <h2>로그인</h2>
    <div class="sub">강남타임 계정으로 로그인해 시간표·과제를 관리하세요.</div>

    <form action="loginProc.jsp" method="post">
        <label for="userId">아이디</label>
        <input type="text" id="userId" name="userId" required>

        <label for="userPw">비밀번호</label>
        <input type="password" id="userPw" name="userPw" required>

        <button type="submit" class="btn-primary">로그인</button>
    </form>

    <div class="bottom-text">
        아직 계정이 없으신가요? <a href="signup.jsp">회원가입하기</a>
    </div>
</main>
</body>
</html>
