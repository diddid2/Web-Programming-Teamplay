<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String userId = (String) session.getAttribute("userId");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입 - 강남타임</title>
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
            max-width: 420px;
            margin: 60px auto;
            padding: 24px 22px 28px;
            background: #020617;
            border-radius: 18px;
            border: 1px solid rgba(148,163,184,.5);
            box-shadow: 0 20px 40px rgba(15,23,42,.9);
        }
        h2 {
            margin-top: 0;
            margin-bottom: 6px;
            font-size: 22px;
        }
        .sub {
            font-size: 13px;
            color: #9ca3af;
            margin-bottom: 18px;
        }
        label {
            display:block;
            font-size: 13px;
            margin-bottom: 4px;
        }
        input, select {
            width: 100%;
            padding: 8px 10px;
            border-radius: 10px;
            border: 1px solid rgba(148,163,184,.6);
            background: #020617;
            color: #e5e7eb;
            font-size: 13px;
            margin-bottom: 12px;
        }
        input:focus, select:focus {
            outline: none;
            border-color: #38bdf8;
        }
        .btn-primary {
            width: 100%;
            border: none;
            border-radius: 999px;
            padding: 9px 0;
            background: linear-gradient(135deg,#38bdf8,#6366f1);
            color:#0b1120;
            font-weight:600;
            cursor:pointer;
            margin-top: 4px;
        }
        .btn-primary:hover { opacity:.93; }
        .bottom-text {
            margin-top: 16px;
            font-size: 12px;
            color:#9ca3af;
            text-align:center;
        }
        .bottom-text a {
            color:#38bdf8;
        }
    </style>
</head>
<body>
<header>
    <div class="nav-inner">
        <div class="logo">
            <div class="logo-mark">KT</div>
            <span>강남타임</span>
        </div>
        <div>
            <a href="main.jsp">← 메인으로</a>
        </div>
    </div>
</header>

<main>
    <h2>회원가입</h2>
    <div class="sub">강남타임 계정을 만들어 시간을 한 번에 관리해보세요.</div>

    <form action="signupProc.jsp" method="post">
        <label for="userId">아이디</label>
        <input type="text" id="userId" name="userId" required>

        <label for="userPw">비밀번호</label>
        <input type="password" id="userPw" name="userPw" required>

        <label for="name">이름</label>
        <input type="text" id="name" name="name" required>

        <label for="major">학과</label>
        <input type="text" id="major" name="major" placeholder="예: 컴퓨터공학부">

        <button type="submit" class="btn-primary">가입하기</button>
    </form>

    <div class="bottom-text">
        이미 계정이 있으신가요? <a href="login.jsp">로그인하기</a>
    </div>
</main>
</body>
</html>
