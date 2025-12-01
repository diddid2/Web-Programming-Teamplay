<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setCharacterEncoding("UTF-8");
    request.setAttribute("currentMenu", "dalguji");

    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>달구지 시간표 & 실시간 위치 - 강남타임</title>
    <style>
        * { box-sizing:border-box; margin:0; padding:0; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Noto Sans KR", sans-serif;
            background:#0f172a;
            color:#e5e7eb;
        }
        a { text-decoration:none; color:inherit; }

        main {
            max-width: 1100px;
            margin: 24px auto 60px;
            padding: 0 20px;
            display:grid;
            grid-template-columns: minmax(0,1.4fr) minmax(0,1.6fr);
            gap:20px;
        }
        @media (max-width: 900px) {
            main {
                grid-template-columns: 1fr;
            }
        }

        .card {
            border-radius:18px;
            border:1px solid rgba(55,65,81,.9);
            background:#020617;
            padding:16px 16px 18px;
        }
        .card-header {
            display:flex;
            justify-content:space-between;
            align-items:center;
            margin-bottom:8px;
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

        /* 시간표 토글 버튼 */
        .tab-buttons {
            display:inline-flex;
            gap:4px;
            background:#020617;
            padding:2px;
            border-radius:999px;
            border:1px solid #1f2937;
        }
        .tab-btn {
            border:none;
            border-radius:999px;
            padding:4px 10px;
            font-size:12px;
            cursor:pointer;
            background:transparent;
            color:#9ca3af;
        }
        .tab-btn.active {
            background:linear-gradient(135deg,#38bdf8,#6366f1);
            color:#0b1120;
            font-weight:600;
        }

        .timetable-wrap {
            margin-top:8px;
            border-radius:14px;
            overflow:hidden;
            background:#020617;
            border:1px solid #111827;
        }
        .timetable-wrap img {
            display:block;
            width:100%;
            height:auto;
        }
        .timetable-notice {
            margin-top:8px;
            font-size:11px;
            color:#9ca3af;
        }

        /* 지도 영역 */
        .map-frame {
            width:100%;
            height:320px;
            border-radius:14px;
            border:none;
            background:#020617;
        }
        .map-notice {
            margin-top:8px;
            font-size:11px;
            color:#9ca3af;
            line-height:1.5;
        }
        .map-notice a {
            color:#38bdf8;
            text-decoration:underline;
        }
    </style>
    <script>
        function showTimetable(type) {
            var monFriImg = document.getElementById('tt-monfri');
            var tueThuImg = document.getElementById('tt-twt');

            var btnMonFri = document.getElementById('btn-monfri');
            var btnTueThu = document.getElementById('btn-twt');

            if (type === 'MON_FRI') {
                monFriImg.style.display = 'block';
                tueThuImg.style.display = 'none';
                btnMonFri.classList.add('active');
                btnTueThu.classList.remove('active');
            } else {
                monFriImg.style.display = 'none';
                tueThuImg.style.display = 'block';
                btnMonFri.classList.remove('active');
                btnTueThu.classList.add('active');
            }
        }

        // 첫 로딩 시 월·금 시간표를 기본으로
        window.addEventListener('DOMContentLoaded', function () {
            showTimetable('MON_FRI');
        });
    </script>
</head>
<body>

<jsp:include page="/common/gnb.jsp" />

<main>
    <!-- 왼쪽: 달구지 시간표 -->
    <section class="card">
        <div class="card-header">
            <div>
                <div class="card-title">달구지 시간표</div>
                <div class="card-sub">요일별로 다른 운행 시간을 이미지로 확인할 수 있습니다.</div>
            </div>
            <div class="tab-buttons">
                <button type="button" id="btn-monfri"
                        class="tab-btn" onclick="showTimetable('MON_FRI')">
                    월·금
                </button>
                <button type="button" id="btn-twt"
                        class="tab-btn" onclick="showTimetable('TUE_WED_THU')">
                    화·수·목
                </button>
            </div>
        </div>

        <div class="timetable-wrap">
            <!-- 실제 이미지 경로는 프로젝트에 맞게 수정 -->
            <img id="tt-monfri"
                 src="<%= ctx %>/resources/dalguji/dalguji_mon_fri.png"
                 alt="달구지 시간표 - 월·금">
            <img id="tt-twt"
                 src="<%= ctx %>/resources/dalguji/dalguji_tue_wed_thu.png"
                 alt="달구지 시간표 - 화·수·목"
                 style="display:none;">
        </div>

        <div class="timetable-notice">
            · 실제 운행 정보와 다를 수 있으니 여유 있게 정류장에 도착하는 것을 권장합니다.
        </div>
    </section>

    <!-- 오른쪽: 달구지 실시간 위치 (베타) -->
    <section class="card">
        <div class="card-header">
            <div>
                <div class="card-title">달구지 실시간 위치 (베타)</div>
                <div class="card-sub">
                    유비칸 차량관제 서비스를 통해 달구지 현재 위치를 확인합니다.
                </div>
            </div>
        </div>

        <!--
            실전으로는 Ubikhan의 내부 위치 API를 파싱해서
            카카오/네이버 지도에 마커를 찍는 구조로 가야 하는데,
            우선은 map 페이지를 그대로 iframe으로 띄우는 버전으로 구현.
            (브라우저에서 한 번 로그인하면 세션 유지됨)
        -->
        <div id="dalgujiMap" class="map-frame"></div>

        <div class="map-notice">
            · 최초 접속 시 유비칸 계정으로 한 번 로그인해야 지도가 표시됩니다.
        </div>
    </section>
    <!-- 카카오 지도 -->
<script type="text/javascript" src="//dapi.kakao.com/v2/maps/sdk.js?appkey=f1ec7760d278bac11590865e12b2469d&libraries=clusterer"></script>

<script>
let map;
let markers = {};

function initMap() {
    const container = document.getElementById('dalgujiMap');

    const options = {
        center: new kakao.maps.LatLng(37.274, 127.125),
        level: 5
    };

    map = new kakao.maps.Map(container, options);
}

function updateShuttle() {
    fetch("<%= ctx %>/shuttle")
        .then(r => r.json())
        .then(data => {
            if (!data.list) return;

            data.list.forEach(car => {
                const lat    = car.lat;
                const lon    = car.lon;
                const name   = car.licenseid;
                const speed  = car.carspeed;
                const report = car.repotime;
                const icon   = car.cariconurl;

                if (markers[name]) {
                    // 기존 마커 위치만 이동
                    markers[name].setPosition(new kakao.maps.LatLng(lat, lon));
                    return;
                }

                // 새 마커 생성
                let img = new kakao.maps.MarkerImage(
                    "https://new.ubikhan.com/resources/marker/" + icon,
                    new kakao.maps.Size(40, 40)
                );

                let marker = new kakao.maps.Marker({
                    map: map,
                    position: new kakao.maps.LatLng(lat, lon),
                    image: img
                });

                markers[name] = marker;

                let info = new kakao.maps.InfoWindow({
                    content: `
                        <div style="padding:8px;font-size:13px;">
                            <b>${name}</b><br>
                            속도 : ${speed} km/h<br>
                            보고시각 : ${report}
                        </div>
                    `
                });

                kakao.maps.event.addListener(marker, "click", () => {
                    info.open(map, marker);
                });
            });
        })
        .catch(err => console.error("shuttle update error:", err));
}


window.addEventListener("DOMContentLoaded", () => {
    initMap();
    updateShuttle();               // 최초 1회
    setInterval(updateShuttle, 3000); // 3초마다 업데이트
});
</script>
    
</main>

</body>
</html>
