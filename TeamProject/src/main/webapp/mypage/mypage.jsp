<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    // GNB에서 '설정' 혹은 '마이페이지' 탭에 불 들어가게 조절
    request.setAttribute("currentMenu", "settings");  // 필요하면 "mypage"로 바꾸고 gnb.jsp도 맞춰줘

    String userId = (String)session.getAttribute("userId");
    if (userId == null) {
        out.println("<script>alert('로그인이 필요합니다.'); location.href='../login.jsp';</script>");
        return;
    }

    String userName = null;
    String major    = null;
    int memberNo    = 0;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();
        String sql = "SELECT MEMBER_NO, USER_ID, NAME, MAJOR FROM MEMBER WHERE USER_ID = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            memberNo = rs.getInt("MEMBER_NO");
            userName = rs.getString("NAME");
            major    = rs.getString("MAJOR");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }

    if (userName == null) userName = "";
    if (major == null) major = "";

    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>마이페이지 - 강남타임</title>
    <style>
        * { box-sizing:border-box; margin:0; padding:0; }
        body {
            font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,"Noto Sans KR",sans-serif;
            background:#0f172a;
            color:#e5e7eb;
        }
        a { text-decoration:none; color:inherit; }

        main {
            max-width:900px;
            margin:24px auto 60px;
            padding:0 20px;
            display:grid;
            grid-template-columns:minmax(0,1.1fr) minmax(0,1.1fr);
            gap:20px;
        }
        @media (max-width: 900px) {
            main { grid-template-columns:1fr; }
        }

        .section-full {
            grid-column:1 / -1;
        }

        .card {
            border-radius:18px;
            border:1px solid rgba(55,65,81,.9);
            background:#020617;
            padding:16px 16px 18px;
        }
        .card-header {
            margin-bottom:10px;
        }
        .card-title {
            font-size:16px;
            font-weight:600;
        }
        .card-sub {
            font-size:11px;
            color:#9ca3af;
            margin-top:2px;
        }

        .profile-row {
            margin-top:8px;
            font-size:13px;
            line-height:1.8;
        }
        .profile-label {
            display:inline-block;
            width:80px;
            color:#9ca3af;
        }

        .form-group {
            margin-top:10px;
        }
        .form-group label {
            display:block;
            font-size:12px;
            margin-bottom:3px;
        }
        .form-group input[type="text"],
        .form-group input[type="password"] {
            width:100%;
            border-radius:9px;
            border:1px solid #4b5563;
            background:#020617;
            color:#e5e7eb;
            font-size:12px;
            padding:7px 9px;
        }
        .form-group input:focus {
            outline:none;
            border-color:#38bdf8;
        }

        .btn-row {
            margin-top:12px;
            text-align:right;
            display:flex;
            justify-content:flex-end;
            gap:8px;
        }
        .btn {
            border-radius:999px;
            border:none;
            padding:7px 14px;
            font-size:12px;
            cursor:pointer;
        }
        .btn-outline {
            background:#111827;
            color:#e5e7eb;
        }
        .btn-outline:hover { background:#1f2937; }
        .btn-primary {
            background:linear-gradient(135deg,#38bdf8,#6366f1);
            color:#0b1120;
            font-weight:600;
        }
        .btn-primary:hover { opacity:.93; }

        .hint {
            margin-top:6px;
            font-size:11px;
            color:#9ca3af;
            line-height:1.5;
        }
    </style>
</head>
<body>

<jsp:include page="/common/gnb.jsp" />

<main>
    <!-- 상단: 간단 프로필 요약 -->
    <section class="card section-full">
        <div class="card-header">
            <div class="card-title">내 계정</div>
            <div class="card-sub">강남타임에서 사용하는 기본 계정 정보입니다.</div>
        </div>

        <div class="profile-row">
            <span class="profile-label">회원번호</span>
            <span><%= memberNo %></span>
        </div>
        <div class="profile-row">
            <span class="profile-label">아이디</span>
            <span><%= userId %></span>
        </div>
        <div class="profile-row">
            <span class="profile-label">이름</span>
            <span><%= userName %></span>
        </div>
        <div class="profile-row">
            <span class="profile-label">전공</span>
            <span><%= major %></span>
        </div>
    </section>

    <!-- 좌측: 이름/전공 수정 -->
    <section class="card">
        <div class="card-header">
            <div class="card-title">프로필 수정</div>
            <div class="card-sub">이름과 전공 정보를 수정할 수 있습니다.</div>
        </div>

        <form action="updateProfile.jsp" method="post">
            <div class="form-group">
                <label for="name">이름</label>
                <input type="text" id="name" name="name" value="<%= userName %>" maxlength="50" required>
            </div>
            <div class="form-group">
                <label for="major">전공</label>
                <input type="text" id="major" name="major" value="<%= major %>" maxlength="100">
            </div>

            <div class="btn-row">
                <button type="submit" class="btn btn-primary">저장하기</button>
            </div>
            <div class="hint">
                · 이름/전공 정보는 게시판 닉네임 표시 등에 사용될 수 있습니다.<br>
                · 학적부 정보와 다를 수 있으니 공식 기록은 학교 시스템을 확인하세요.
            </div>
        </form>
    </section>

    <!-- 우측: 비밀번호 변경 -->
    <section class="card">
        <div class="card-header">
            <div class="card-title">비밀번호 변경</div>
            <div class="card-sub">현재 비밀번호를 확인한 후 새 비밀번호로 변경합니다.</div>
        </div>

        <form action="changePassword.jsp" method="post" onsubmit="return checkPwForm();">
            <div class="form-group">
                <label for="curPw">현재 비밀번호</label>
                <input type="password" id="curPw" name="curPw" required>
            </div>
            <div class="form-group">
                <label for="newPw">새 비밀번호</label>
                <input type="password" id="newPw" name="newPw" required>
            </div>
            <div class="form-group">
                <label for="newPw2">새 비밀번호 확인</label>
                <input type="password" id="newPw2" name="newPw2" required>
            </div>

            <div class="btn-row">
                <button type="submit" class="btn btn-primary">비밀번호 변경</button>
            </div>
            <div class="hint">
                · 비밀번호는 암호화되어 저장되며, 원문은 서버에서도 확인할 수 없습니다.<br>
                · 다른 서비스와는 다른 비밀번호를 사용하는 것을 권장합니다.
            </div>
        </form>
    </section>
</main>

<script>
    function checkPwForm() {
        const newPw  = document.getElementById('newPw').value;
        const newPw2 = document.getElementById('newPw2').value;

        if (newPw.length < 6) {
            alert('새 비밀번호는 6자 이상으로 설정해주세요.');
            return false;
        }
        if (newPw !== newPw2) {
            alert('새 비밀번호가 서로 일치하지 않습니다.');
            return false;
        }
        return true;
    }
</script>

</body>
</html>
