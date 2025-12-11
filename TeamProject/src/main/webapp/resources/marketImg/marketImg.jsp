<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>KangnamTime – 상품 이미지</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: -apple-system, BlinkMacSystemFont, system-ui, "Noto Sans KR", sans-serif;
            background: #020617;
            color: #e5e7eb;
        }

        .page-wrapper {
            max-width: 900px;
            margin: 0 auto;
            padding: 18px 18px 40px;
        }

        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 14px;
        }

        .top-title {
            font-size: 16px;
            font-weight: 600;
        }

        .btn-close {
            border-radius: 999px;
            border: 1px solid rgba(148, 163, 184, 0.6);
            background: rgba(15, 23, 42, 0.96);
            color: #e5e7eb;
            font-size: 12px;
            padding: 6px 12px;
            cursor: pointer;
        }

        .btn-close:hover {
            border-color: #60a5fa;
        }

        .img-card {
            border-radius: 18px;
            border: 1px solid rgba(148, 163, 184, 0.3);
            background: radial-gradient(circle at top left, rgba(56, 189, 248, 0.12), rgba(15, 23, 42, 0.98));
            padding: 16px;
            box-shadow: 0 18px 40px rgba(15, 23, 42, 0.9);
        }

        .img-wrapper {
            border-radius: 14px;
            background: linear-gradient(135deg, #1f2937, #020617);
            overflow: hidden;
            max-height: 600px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .img-wrapper img {
            width: 100%;
            height: auto;
            object-fit: contain;
        }

        .img-info {
            margin-top: 10px;
            font-size: 12px;
            color: #9ca3af;
            display: flex;
            justify-content: space-between;
            gap: 8px;
        }

        .img-info span {
            white-space: nowrap;
            text-overflow: ellipsis;
            overflow: hidden;
        }

        @media (max-width: 720px) {
            .page-wrapper {
                padding: 14px 12px 30px;
            }
        }
    </style>
</head>
<body>

<jsp:include page="../common/gnb.jsp" />

<main class="page-wrapper">

    <div class="top-bar">
        <div class="top-title">상품 이미지 보기</div>
        <button class="btn-close" type="button" onclick="window.close(); history.back();">
            닫기
        </button>
    </div>

    <section class="img-card">
        <c:choose>
            <c:when test="${not empty param.fileName}">
                <div class="img-wrapper">
                    <img src="${pageContext.request.contextPath}/resources/marketImg/${param.fileName}"
                         alt="market image">
                </div>
                <div class="img-info">
                    <span>파일명: ${param.fileName}</span>
                    <span>경로: /resources/marketImg/${param.fileName}</span>
                </div>
            </c:when>
            <c:otherwise>
                <div class="img-wrapper" style="padding: 40px 20px; color:#9ca3af; font-size:13px;">
                    표시할 이미지가 없습니다.<br>
                    URL에 <code>?fileName=파일명.jpg</code> 형태로 접근하거나, 목록에서 다시 시도해주세요.
                </div>
            </c:otherwise>
        </c:choose>
    </section>
</main>

</body>
</html>
