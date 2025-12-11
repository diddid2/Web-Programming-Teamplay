<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%
    request.setCharacterEncoding("UTF-8");
    String ctx = request.getContextPath();

    // 세션에 로그인 정보가 있다면, 회원 PK 가져와서 숨은 필드로 보낼 수도 있음
    // Integer memberNo = (Integer)session.getAttribute("memberNo");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>KangnamTime – 중고상품 등록</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@300;400;500;700&display=swap" rel="stylesheet">

    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: "Noto Sans KR", system-ui, -apple-system, BlinkMacSystemFont, sans-serif;
            background: #050816;
            color: #e5e7eb;
        }
        a { color: inherit; text-decoration: none; }

        .navbar {
            position: sticky;
            top: 0;
            z-index: 50;
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px 60px;
            background: rgba(5, 10, 25, 0.96);
            backdrop-filter: blur(10px);
            border-bottom: 1px solid rgba(148, 163, 184, 0.1);
        }
        .navbar-left { display: flex; align-items: center; gap: 12px; }
        .navbar-logo {
            width: 32px;
            height: 32px;
            border-radius: 999px;
            background: radial-gradient(circle at 30% 30%, #4f9cff, #1f2937);
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            color: #f9fafb;
            font-size: 14px;
        }
        .navbar-title { font-size: 18px; font-weight: 700; }
        .navbar-menu { display: flex; gap: 24px; font-size: 14px; }
        .navbar-menu a { opacity: 0.7; transition: opacity 0.15s ease, color 0.15s ease; }
        .navbar-menu a:hover { opacity: 1; color: #60a5fa; }
        .navbar-menu .active { opacity: 1; color: #60a5fa; font-weight: 600; }
        .navbar-right { display: flex; gap: 10px; }
        .btn-outline {
            padding: 6px 16px;
            border-radius: 999px;
            border: 1px solid rgba(148, 163, 184, 0.6);
            font-size: 13px;
            background: transparent;
            color: #e5e7eb;
            cursor: pointer;
        }
        .btn-primary {
            padding: 6px 18px;
            border-radius: 999px;
            border: none;
            font-size: 13px;
            background: linear-gradient(135deg, #2563eb, #38bdf8);
            color: white;
            cursor: pointer;
        }

        .page-wrapper {
            max-width: 800px;
            margin: 24px auto 60px;
            padding: 0 20px;
        }

        .card {
            background: radial-gradient(circle at top left, rgba(56, 189, 248, 0.09), rgba(15, 23, 42, 0.98));
            border-radius: 22px;
            padding: 20px 22px 24px;
            border: 1px solid rgba(148, 163, 184, 0.16);
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.9);
        }

        h1 {
            font-size: 22px;
            margin-bottom: 8px;
        }
        .subtitle {
            font-size: 13px;
            color: #9ca3af;
            margin-bottom: 18px;
        }

        .form-row {
            margin-bottom: 14px;
        }
        .form-row label {
            display: block;
            font-size: 13px;
            margin-bottom: 4px;
        }
        .form-row label span {
            color: #f97316;
            margin-left: 4px;
        }
        .form-row input[type="text"],
        .form-row input[type="number"],
        .form-row select,
        .form-row textarea {
            width: 100%;
            padding: 8px 10px;
            border-radius: 10px;
            border: 1px solid rgba(148, 163, 184, 0.4);
            background: rgba(15, 23, 42, 0.98);
            color: #e5e7eb;
            font-size: 13px;
        }
        .form-row textarea {
            resize: vertical;
            min-height: 120px;
        }

        .form-row-inline {
            display: flex;
            gap: 10px;
        }
        .form-row-inline .form-row {
            flex: 1;
        }

        .help-text {
            font-size: 11px;
            color: #9ca3af;
            margin-top: 2px;
        }

        .form-actions {
            margin-top: 18px;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
        }
        .btn-secondary {
            padding: 7px 16px;
            border-radius: 999px;
            border: 1px solid rgba(148, 163, 184, 0.7);
            background: transparent;
            color: #e5e7eb;
            font-size: 13px;
            cursor: pointer;
        }
        .btn-submit {
            padding: 7px 18px;
            border-radius: 999px;
            border: none;
            background: linear-gradient(135deg, #22c55e, #16a34a);
            color: #f9fafb;
            font-size: 13px;
            cursor: pointer;
            font-weight: 600;
        }
        .btn-submit:hover {
            filter: brightness(1.1);
        }

        @media (max-width: 768px) {
            .navbar {
                padding: 12px 16px;
            }
            .page-wrapper {
                padding: 0 14px;
            }
        }
    </style>
</head>
<body>

<header class="navbar">
    <div class="navbar-left">
        <div class="navbar-logo">KT</div>
        <div class="navbar-title">KangnamTime</div>
    </div>
    <nav class="navbar-menu">
        <a href="<%=ctx%>/main.jsp">홈</a>
        <a href="<%=ctx%>/timetable/timetableMain.jsp">시간표</a>
        <a href="<%=ctx%>/board/mainBoard.jsp">게시판</a>
        <a href="#">강의평가</a>
        <a href="#">캠퍼스 정보</a>
        <a href="<%=ctx%>/market/marketMain.jsp" class="active">중고거래</a>
    </nav>
    <div class="navbar-right">
        <button class="btn-outline" onclick="location.href='<%=ctx%>/login.jsp'">로그인</button>
        <button class="btn-primary" onclick="location.href='<%=ctx%>/signup.jsp'">회원가입</button>
    </div>
</header>

<main class="page-wrapper">
    <section class="card">
        <h1>중고상품 등록</h1>
        <p class="subtitle">
            실제 거래할 정보를 정확하게 입력해주세요. 제목, 가격, 거래 위치는 특히 중요합니다.
        </p>

        <form method="post" action="<%=ctx%>/market/marketWriteProc.jsp" enctype="multipart/form-data">
            <div class="form-row">
                <label>제목<span>*</span></label>
                <input type="text" name="title" required placeholder="예) 운영체제 공룡책 10판 (거의 새책)">
            </div>

            <div class="form-row-inline">
                <div class="form-row">
                    <label>카테고리<span>*</span></label>
                    <select name="category" required>
                        <option value="">선택하세요</option>
                        <option value="교재 · 전공책">교재 · 전공책</option>
                        <option value="전자기기">전자기기</option>
                        <option value="자취템">자취템</option>
                        <option value="패션 · 잡화">패션 · 잡화</option>
                        <option value="기타">기타</option>
                    </select>
                </div>
                <div class="form-row">
                    <label>가격(원)<span>*</span></label>
                    <input type="number" name="price" min="0" required placeholder="예) 18000">
                    <p class="help-text">무료 나눔이면 0원을 입력해주세요.</p>
                </div>
            </div>

            <div class="form-row-inline">
                <div class="form-row">
                    <label>캠퍼스/위치<span>*</span></label>
                    <select name="campus" required>
                        <option value="">선택하세요</option>
                        <option value="강남대 정문">강남대 정문</option>
                        <option value="기숙사">기숙사</option>
                        <option value="역 인근">역 인근</option>
                    </select>
                </div>
                <div class="form-row">
                    <label>상세 위치</label>
                    <input type="text" name="meetingPlace" placeholder="예) 교양관 근처, 기숙사 1동 로비 등">
                </div>
            </div>

            <div class="form-row-inline">
                <div class="form-row">
                    <label>선호 거래 시간</label>
                    <input type="text" name="meetingTime" placeholder="예) 오늘 18:00, 이번 주말 등">
                </div>
                <div class="form-row">
                    <label>거래 방식<span>*</span></label>
                    <select name="tradeType" required>
                        <option value="">선택하세요</option>
                        <option value="DIRECT">직거래</option>
                        <option value="DELIVERY">택배</option>
                        <option value="BOTH">직거래+택배</option>
                    </select>
                </div>
            </div>
            
		    <div class="form-row">
		        <label>썸네일 업로드</label>
		        <input type="file" name="thumbnail" accept="image/*" id="thumbInput">
		
		        <div style="margin-top:10px;">
		            <img id="thumbPreview" style="max-width:180px; border-radius:10px; display:none;">
		        </div>
		
		        <script>
		            document.getElementById("thumbInput").addEventListener("change", function(e) {
		                const file = e.target.files[0];
		                if (!file) return;
		
		                let reader = new FileReader();
		                reader.onload = function(ev) {
		                    const img = document.getElementById("thumbPreview");
		                    img.src = ev.target.result;
		                    img.style.display = "block";
		                };
		                reader.readAsDataURL(file);
		            });
		        </script>
		
		        <p class="help-text">이미지를 선택하면 즉시 미리보기가 나타납니다.</p>
		    </div>

            <div class="form-row">
                <label>상세 설명</label>
                <textarea name="description" placeholder="상품 상태, 사용 기간, 구성품, 흠집 여부 등을 자세히 적어주세요."></textarea>
            </div>

            <div class="form-actions">
                <button type="button" class="btn-secondary"
                        onclick="location.href='<%=ctx%>/market/marketMain.jsp'">취소</button>
                <button type="submit" class="btn-submit">등록하기</button>
            </div>
        </form>
    </section>
</main>

</body>
</html>
