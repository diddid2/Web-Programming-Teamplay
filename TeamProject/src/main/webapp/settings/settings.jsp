<%@ page import="java.sql.*" %>
<%@ page import="util.DBUtil" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");

    String userId = (String) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    request.setAttribute("currentMenu", "settings");
    
    // 로그인 안 되어 있으면 로그인 페이지로 보냄
    if (userId == null) {
        response.sendRedirect("../login.jsp");
        return;
    }

    String everytimeId = "";
    String everytimePw = "";
    String kangnamId   = "";
    String kangnamPw   = "";
    String ecampusId   = "";
    String ecampusPw   = "";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = DBUtil.getConnection();
        String sql = "SELECT EVERYTIME_ID, EVERYTIME_PW, KANGNAM_ID, KANGNAM_PW, ECAMPUS_ID, ECAMPUS_PW " +
                     "FROM USER_INTEGRATION WHERE USER_ID = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setString(1, userId);
        rs = pstmt.executeQuery();

        if (rs.next()) {
            everytimeId = rs.getString("EVERYTIME_ID") == null ? "" : rs.getString("EVERYTIME_ID");
            everytimePw = rs.getString("EVERYTIME_PW") == null ? "" : rs.getString("EVERYTIME_PW");
            kangnamId   = rs.getString("KANGNAM_ID")   == null ? "" : rs.getString("KANGNAM_ID");
            kangnamPw   = rs.getString("KANGNAM_PW")   == null ? "" : rs.getString("KANGNAM_PW");
            ecampusId   = rs.getString("ECAMPUS_ID")   == null ? "" : rs.getString("ECAMPUS_ID");
            ecampusPw   = rs.getString("ECAMPUS_PW")   == null ? "" : rs.getString("ECAMPUS_PW");
        }
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        try { if (rs != null) rs.close(); } catch (Exception ex) {}
        try { if (pstmt != null) pstmt.close(); } catch (Exception ex) {}
        try { if (conn != null) conn.close(); } catch (Exception ex) {}
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>설정 - 강남타임</title>
    <style>
        * { box-sizing: border-box; margin:0; padding:0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans KR", sans-serif;
            background:#0f172a;
            color:#e5e7eb;
        }
        a { text-decoration:none; color:inherit; }

        header {
            position: sticky; top:0; z-index:10;
            background:rgba(15,23,42,.9);
            border-bottom:1px solid rgba(148,163,184,.4);
        }
        .nav-inner {
            max-width:1100px; margin:0 auto;
            padding:12px 20px;
            display:flex; align-items:center; justify-content:space-between;
        }
        .logo { display:flex; align-items:center; gap:8px; font-weight:700; font-size:20px; }
        .logo-mark {
            width:28px; height:28px; border-radius:999px;
            border:2px solid #38bdf8;
            display:flex; align-items:center; justify-content:center;
            font-size:14px; color:#38bdf8;
        }
        .nav-links { display:flex; gap:18px; font-size:14px; color:#cbd5f5; }
        .nav-links a { padding:6px 10px; border-radius:999px; }
        .nav-links a:hover { background:rgba(148,163,184,.15); color:#f9fafb; }
        .nav-auth { font-size:13px; }

        main {
            max-width:900px;
            margin:28px auto 60px;
            padding:0 20px;
            display:flex;
            flex-direction:column;
            gap:18px;
        }
        .page-title {
            font-size:22px;
            font-weight:700;
            margin-bottom:4px;
        }
        .page-sub {
            font-size:13px;
            color:#9ca3af;
        }
        .card {
            margin-top:12px;
            padding:18px 18px 20px;
            border-radius:18px;
            border:1px solid rgba(148,163,184,.5);
            background:#020617;
        }
        .card-title {
            font-size:16px;
            font-weight:600;
            margin-bottom:4px;
        }
        .card-sub {
            font-size:12px;
            color:#9ca3af;
            margin-bottom:12px;
        }
        .section-grid {
            display:grid;
            grid-template-columns:repeat(3, minmax(0,1fr));
            gap:16px;
        }
        .section {
            padding:12px 12px 14px;
            border-radius:14px;
            border:1px solid rgba(55,65,81,.9);
            background:#020617;
        }
        .section-header {
            font-size:13px;
            font-weight:600;
            margin-bottom:4px;
        }
        .section-desc {
            font-size:11px;
            color:#9ca3af;
            margin-bottom:10px;
        }
        label {
            display:block;
            font-size:12px;
            margin-bottom:3px;
        }
        input {
            width:100%;
            padding:7px 9px;
            border-radius:9px;
            border:1px solid rgba(148,163,184,.6);
            background:#020617;
            color:#e5e7eb;
            font-size:12px;
            margin-bottom:8px;
        }
        input:focus {
            outline:none;
            border-color:#38bdf8;
        }
        .btn-row {
            margin-top:14px;
            display:flex;
            justify-content:flex-end;
            gap:8px;
        }
        .btn-secondary, .btn-primary {
            border-radius:999px;
            padding:7px 14px;
            border:none;
            cursor:pointer;
            font-size:12px;
        }
        .btn-secondary {
            background:transparent;
            border:1px solid rgba(148,163,184,.7);
            color:#e5e7eb;
        }
        .btn-secondary:hover {
            background:rgba(148,163,184,.18);
        }
        .btn-primary {
            background:linear-gradient(135deg,#38bdf8,#6366f1);
            color:#0b1120;
            font-weight:600;
        }
        .btn-primary:hover { opacity:.93; }

        .warning {
            font-size:11px;
            color:#f97373;
            margin-top:8px;
        }

        @media (max-width:900px) {
            .section-grid {
                grid-template-columns:1fr;
            }
        }
    </style>
</head>
<body>

<jsp:include page="/common/gnb.jsp"/>

<main>
    <div>
        <div class="page-title">계정 연동 설정</div>
        <div class="page-sub">
            에브리타임, 강남대 포털, e캠퍼스 계정을 연동하면  
            AI 시간표 생성과 과제 스케줄러 기능을 자동으로 사용할 수 있습니다.
        </div>
    </div>

    <div class="card">
        <div class="card-title">외부 서비스 계정 정보</div>
        <div class="card-sub">
            입력한 정보는 이 프로젝트의 Oracle DB에 저장되며, 자동 로그인·데이터 연동에만 사용됩니다.
            실제 서비스 계정보다는 <b>실습용 계정 사용</b>을 권장합니다.
        </div>

        <form action="settingsProc.jsp" method="post">
            <div class="section-grid">

                <!-- 에브리타임 -->
                <div class="section">
                    <div class="section-header">에브리타임 계정</div>
                    <div class="section-desc">
                        강의평, 시간표 데이터를 불러오기 위해 사용됩니다.
                    </div>
                    <label for="everytimeId">에브리타임 아이디</label>
                    <input type="text" id="everytimeId" name="everytimeId" value="<%= everytimeId %>">

                    <label for="everytimePw">에브리타임 비밀번호</label>
                    <input type="password" id="everytimePw" name="everytimePw" value="<%= everytimePw %>">
                </div>

                <!-- 강남대 포털 -->
                <div class="section">
                    <div class="section-header">강남대 포털 계정</div>
                    <div class="section-desc">
                        학적·수강 정보 등 포털 데이터를 연동할 때 사용될 예정입니다.
                    </div>
                    <label for="kangnamId">강남대 포털 아이디</label>
                    <input type="text" id="kangnamId" name="kangnamId" value="<%= kangnamId %>">

                    <label for="kangnamPw">강남대 포털 비밀번호</label>
                    <input type="password" id="kangnamPw" name="kangnamPw" value="<%= kangnamPw %>">
                </div>

                <!-- e캠퍼스 -->
                <div class="section">
                    <div class="section-header">e캠퍼스 계정</div>
                    <div class="section-desc">
                        과제 목록을 가져와 캘린더에 자동으로 표시하는 데 사용됩니다.
                    </div>
                    <label for="ecampusId">e캠퍼스 아이디</label>
                    <input type="text" id="ecampusId" name="ecampusId" value="<%= ecampusId %>">

                    <label for="ecampusPw">e캠퍼스 비밀번호</label>
                    <input type="password" id="ecampusPw" name="ecampusPw" value="<%= ecampusPw %>">
                </div>
            </div>

            <div class="btn-row">
                <button type="button" class="btn-secondary" onclick="location.href='../main.jsp'">취소</button>
                <button type="submit" class="btn-primary">저장하기</button>
            </div>

            <div class="warning">
                ※ 실제 서비스에는 비밀번호를 평문으로 저장하면 안 되며, 암호화/토큰 기반 인증이 필요합니다.  
                본 프로젝트에서는 학습/시연용으로만 사용합니다.
            </div>
        </form>
    </div>
</main>

</body>
</html>
