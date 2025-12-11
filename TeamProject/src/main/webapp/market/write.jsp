<%@ page contentType="text/html; charset=UTF-8" language="java" %>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>KangnamTime – 중고거래 글쓰기</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <!-- 폰트 -->
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

        .page-wrapper {
            max-width: 900px;
            margin: 0 auto;
            padding: 24px 24px 60px;
        }

        .page-title { font-size: 22px; font-weight: 700; margin-bottom: 6px; }
        .page-subtitle { font-size: 13px; color: #9ca3af; margin-bottom: 18px; }

        .card {
            background: radial-gradient(circle at top left, rgba(56, 189, 248, 0.09), rgba(15, 23, 42, 0.98));
            border-radius: 22px;
            padding: 20px 22px;
            border: 1px solid rgba(148, 163, 184, 0.16);
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.9);
        }

        .form-grid {
            display: grid;
            grid-template-columns: minmax(0, 2.2fr) minmax(260px, 1.2fr);
            gap: 18px;
        }

        .form-group { margin-bottom: 14px; }

        .form-label {
            font-size: 13px;
            font-weight: 500;
            margin-bottom: 6px;
            display: inline-flex;
            align-items: center;
            gap: 4px;
        }

        .form-label span.required {
            font-size: 12px;
            color: #fb7185;
        }

        .form-input,
        .form-select,
        .form-textarea {
            width: 100%;
            border-radius: 12px;
            border: 1px solid rgba(148, 163, 184, 0.5);
            background: rgba(15, 23, 42, 0.98);
            color: #e5e7eb;
            font-size: 13px;
            padding: 9px 11px;
            outline: none;
        }

        .form-input:focus,
        .form-select:focus,
        .form-textarea:focus {
            border-color: #60a5fa;
            box-shadow: 0 0 0 1px rgba(96, 165, 250, 0.4);
        }

        .form-textarea {
            min-height: 160px;
            resize: vertical;
            line-height: 1.5;
        }

        .form-row-2 {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 10px;
        }

        .help-text {
            font-size: 11px;
            color: #9ca3af;
            margin-top: 4px;
        }

        .radio-group {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
            font-size: 12px;
        }

        .radio-item {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            padding: 4px 8px;
            border-radius: 999px;
            border: 1px solid rgba(148, 163, 184, 0.4);
            background: rgba(15, 23, 42, 0.96);
        }

        .thumbnail-card {
            border-radius: 18px;
            border: 1px dashed rgba(148, 163, 184, 0.6);
            padding: 14px 14px 16px;
            background: rgba(15, 23, 42, 0.96);
        }

        .thumbnail-preview {
            width: 100%;
            border-radius: 12px;
            background: linear-gradient(135deg, #1f2937, #020617);
            height: 180px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            color: #9ca3af;
            overflow: hidden;
            margin-bottom: 10px;
        }

        .thumbnail-preview img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .file-input {
            font-size: 12px;
            color: #9ca3af;
        }

        .file-input input[type="file"] {
            font-size: 12px;
        }

        .btn-row {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 18px;
        }

        .btn-outline {
            padding: 8px 16px;
            border-radius: 999px;
            border: 1px solid rgba(148, 163, 184, 0.7);
            background: transparent;
            color: #e5e7eb;
            font-size: 13px;
            cursor: pointer;
        }

        .btn-primary {
            padding: 8px 18px;
            border-radius: 999px;
            border: none;
            background: linear-gradient(135deg, #2563eb, #38bdf8);
            color: #f9fafb;
            font-size: 13px;
            font-weight: 600;
            cursor: pointer;
            box-shadow: 0 12px 30px rgba(37, 99, 235, 0.7);
        }

        .btn-outline:hover { border-color: #60a5fa; }
        .btn-primary:hover { filter: brightness(1.07); }

        .footer {
            margin-top: 40px;
            padding: 18px 0 10px;
            font-size: 11px;
            text-align: center;
            color: #6b7280;
            border-top: 1px solid rgba(148, 163, 184, 0.12);
        }

        @media (max-width: 820px) {
            .page-wrapper { padding: 18px 16px 40px; }
            .form-grid { grid-template-columns: minmax(0, 1fr); }
        }
    </style>
</head>
<body>

<jsp:include page="../common/gnb.jsp" />

<main class="page-wrapper">
    <h1 class="page-title">중고상품 판매 등록</h1>
    <p class="page-subtitle">
        강남대 학생들끼리 안전하게 거래할 수 있도록, 상품 정보를 자세히 입력해주세요.
    </p>

    <section class="card">
        <!-- multipart + 서블릿으로 전송 -->
        <form action="<c:url value='/market/write' />"
              method="post"
              enctype="multipart/form-data">

            <div class="form-grid">
                <!-- 왼쪽: 기본 정보 -->
                <div>
                    <!-- 제목 -->
                    <div class="form-group">
                        <label class="form-label">
                            제목 <span class="required">*</span>
                        </label>
                        <input type="text" name="title" class="form-input"
                               placeholder="예) 운영체제 공룡책 10판 (거의 새책)"
                               required>
                        <p class="help-text">상품 상태가 잘 보이도록 구체적으로 적어주세요.</p>
                    </div>

                    <!-- 카테고리 / 가격 -->
                    <div class="form-row-2">
                        <div class="form-group">
                            <label class="form-label">
                                카테고리 <span class="required">*</span>
                            </label>
                            <select name="category" class="form-select" required>
                                <option value="">선택하세요</option>
                                <option value="교재 · 전공책">교재 · 전공책</option>
                                <option value="전자기기">전자기기</option>
                                <option value="가구 · 자취템">가구 · 자취템</option>
                                <option value="패션 · 잡화">패션 · 잡화</option>
                                <option value="기타">기타</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                가격 (원) <span class="required">*</span>
                            </label>
                            <input type="number" name="price" class="form-input"
                                   placeholder="예) 18000"
                                   min="0" step="100"
                                   required>
                            <p class="help-text">실제 거래 희망 가격을 입력해주세요.</p>
                        </div>
                    </div>

                    <!-- 캠퍼스 / 거래 장소 -->
                    <div class="form-row-2">
                        <div class="form-group">
                            <label class="form-label">
                                거래 캠퍼스/위치 <span class="required">*</span>
                            </label>
                            <select name="campus" class="form-select" required>
                                <option value="">선택하세요</option>
                                <option value="강남대 정문">강남대 정문</option>
                                <option value="기숙사">기숙사</option>
                                <option value="역 인근">역 인근</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">상세 위치</label>
                            <input type="text" name="meetingPlace" class="form-input"
                                   placeholder="예) 교양관 근처, 기숙사 로비 등">
                        </div>
                    </div>

                    <!-- 거래 시간 / 방식 -->
                    <div class="form-row-2">
                        <div class="form-group">
                            <label class="form-label">거래 가능 시간</label>
                            <input type="text" name="meetingTime" class="form-input"
                                   placeholder="예) 평일 저녁 6시 이후, 주말 협의 등">
                        </div>

                        <div class="form-group">
                            <label class="form-label">
                                거래 방식 <span class="required">*</span>
                            </label>
                            <div class="radio-group">
                                <label class="radio-item">
                                    <input type="radio" name="tradeType" value="DIRECT" checked>
                                    직거래
                                </label>
                                <label class="radio-item">
                                    <input type="radio" name="tradeType" value="DELIVERY">
                                    택배
                                </label>
                                <label class="radio-item">
                                    <input type="radio" name="tradeType" value="BOTH">
                                    모두 가능
                                </label>
                            </div>
                        </div>
                    </div>

                    <!-- 상세 설명 -->
                    <div class="form-group">
                        <label class="form-label">
                            상세 설명 <span class="required">*</span>
                        </label>
                        <textarea name="description" class="form-textarea" required
                                  placeholder="상품 상태, 사용 기간, 하자 여부, 포함되는 구성품 등을 자세히 적어주세요.&#10;예) 1학기 동안만 사용했고 필기 거의 없음, 겉표지 모서리에 약간의 사용감 있음."></textarea>
                    </div>
                </div>

                <!-- 오른쪽: 썸네일 업로드 -->
                <div>
                    <div class="form-group">
                        <label class="form-label">대표 썸네일 이미지</label>
                        <div class="thumbnail-card">
                            <div class="thumbnail-preview" id="thumbnailPreview">
                                대표 이미지가 여기 미리보기됩니다.
                            </div>
                            <div class="file-input">
                                <input type="file"
                                       name="thumbnail"
                                       id="thumbnailInput"
                                       accept="image/*">
                                <p class="help-text">
                                    첫 번째 이미지가 목록에 노출됩니다. (최대 5MB, JPG/PNG 권장)<br>
                                    업로드 경로: <code>/resources/marketImg</code>
                                </p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- 버튼 -->
            <div class="btn-row">
                <button type="button" class="btn-outline"
                        onclick="location.href='<c:url value="/market"/>'">
                    목록으로
                </button>
                <button type="submit" class="btn-primary">
                    판매 글 등록하기
                </button>
            </div>

        </form>
    </section>

    <footer class="footer">
        © 2025 KangnamTime. JSP Web Programming Team Project. All rights reserved.
    </footer>
</main>

<!-- 썸네일 미리보기 -->
<script>
    const thumbnailInput = document.getElementById("thumbnailInput");
    const thumbnailPreview = document.getElementById("thumbnailPreview");

    if (thumbnailInput) {
        thumbnailInput.addEventListener("change", function (e) {
            const file = e.target.files[0];
            if (!file) {
                thumbnailPreview.innerHTML = "대표 이미지가 여기 미리보기됩니다.";
                return;
            }
            const reader = new FileReader();
            reader.onload = function (event) {
                thumbnailPreview.innerHTML =
                    '<img src="' + event.target.result + '" alt="thumbnail preview">';
            };
            reader.readAsDataURL(file);
        });
    }
</script>

</body>
</html>
