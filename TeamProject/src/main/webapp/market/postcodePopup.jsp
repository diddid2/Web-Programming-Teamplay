<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <title>우편번호 검색</title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
  <style>
    body { margin: 0; font-family: system-ui, -apple-system, Segoe UI, Roboto, "Noto Sans KR", sans-serif; }
    .wrap { padding: 12px; }
    h3 { margin: 0 0 10px; font-size: 16px; }
    #postcode { width: 100%; height: 560px; }
  </style>
</head>
<body>
  <div class="wrap">
    <h3>우편번호 검색</h3>
    <div id="postcode"></div>
  </div>

  <script>
    new daum.Postcode({
      oncomplete: function (data) {
        var addr = (data.roadAddress && data.roadAddress.length > 0) ? data.roadAddress : data.jibunAddress;

        if (window.opener && !window.opener.closed && typeof window.opener.setCheckoutAddress === "function") {
          window.opener.setCheckoutAddress({
            postcode: data.zonecode,
            address1: addr
          });
        }
        window.close();
      },
      width: "100%",
      height: "100%"
    }).embed(document.getElementById("postcode"));
  </script>
</body>
</html>
