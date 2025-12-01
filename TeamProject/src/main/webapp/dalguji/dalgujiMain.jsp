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
            align-items:flex-start;
            margin-bottom:8px;
            gap:8px;
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

        /* 출발점 선택 버튼 */
        .depart-buttons {
            display:inline-flex;
            gap:4px;
            background:#020617;
            padding:2px;
            border-radius:999px;
            border:1px solid #1f2937;
        }
        .depart-btn {
            border:none;
            border-radius:999px;
            padding:3px 9px;
            font-size:11px;
            cursor:pointer;
            background:transparent;
            color:#9ca3af;
        }
        .depart-btn.active {
            background:#111827;
            color:#e5e7eb;
            font-weight:600;
        }

        .header-right {
            display:flex;
            flex-direction:column;
            gap:6px;
            align-items:flex-end;
        }

        .timetable-wrap {
            margin-top:8px;
            border-radius:14px;
            overflow:hidden;
            background:#020617;
            border:1px solid #111827;
            position:relative; /* 오버레이 박스를 위해 필요 */
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

        /* 다음 달구지 오버레이 박스 */
        .next-bus-box {
            position:absolute;
            top:12px;
            left:50%;
            transform:translateX(-50%);
            padding:10px 16px;
            border-radius:999px;
            background:rgba(15,23,42,0.92);
            border:1px solid rgba(148,163,184,0.7);
            backdrop-filter:blur(10px);
            font-size:13px;
            text-align:center;
            z-index:10;
            color:#e5e7eb;
            min-width:240px;
        }
        .next-bus-main {
            font-size:13px;
        }
        .next-bus-time {
            color:#38bdf8;
            font-weight:600;
            font-size:15px;
        }
        .next-bus-sub {
            font-size:11px;
            color:#9ca3af;
            margin-top:2px;
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
        /* =========================================
         *  탭(월·금 / 화·수·목) 이미지 토글
         * ========================================= */
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
                currentDayType = 'MON_FRI';
            } else {
                monFriImg.style.display = 'none';
                tueThuImg.style.display = 'block';
                btnMonFri.classList.remove('active');
                btnTueThu.classList.add('active');
                currentDayType = 'TUE_WED_THU';
            }

            updateNextBus(); // 요일 탭 바뀌면 다시 계산
        }

        /* =========================================
         *  달구지 시간표 데이터
         *  - 각 배열은 "HH:MM" 형식 (24시간제)
         *  - 네 군데에 네 줄씩 시간 직접 입력해서 쓰면 됨
         * ========================================= */

        // 월·금 기준
        var timesMonFri_EE = [ // 이공관 출발 기준 월·금
            "10:40", "11:00", "11:10", "11:20", "11:30", "11:50", "13:00", "13:20", "14:00", "14:10", "14:20", "14:30", "17:30", "17:50"
        ];
        var timesMonFri_GI = [ // 기흥역 출발 기준 월·금
            "10:30", "10:50", "11:00", "11:10", "11:20", "11:30", "12:50", "13:10", "13:40", "14:00", "14:10", "14:20", "17:00", "17:20"
        ];

        // 화·수·목 기준
        var timesTwt_EE = [   // 이공관 출발 기준 화·수·목
            "10:40", "10:50", "11:00", "11:10", "11:20", "11:30", "11:50", "13:00", "13:20", "13:40", "13:50", "14:00", "14:10", "14:20", "14:30", "14:40", "15:30", "16:30", "17:30", "17:50"
        ];
        var timesTwt_GI = [   // 기흥역 출발 기준 화·수·목
        	"10:30", "10:40", "10:50", "11:00", "11:10", "11:20", "11:30", "12:50", "13:10", "13:30", "13:40", "13:50", "14:00", "14:10", "14:20", "14:30", "15:00", "16:00", "17:00", "17:20"
        ];

        // 현재 선택 상태
        var currentDayType = 'MON_FRI'; // 'MON_FRI' 또는 'TUE_WED_THU'
        var currentDepart = 'EE';       // 'EE' (이공관), 'GI' (기흥역)

        /* =========================================
         *  공통 유틸
         * ========================================= */
        function toMin(t) {
            var parts = t.split(":");
            var h = parseInt(parts[0], 10);
            var m = parseInt(parts[1], 10);
            return h * 60 + m;
        }

        function getNextFromSchedule(arr) {
            var now = new Date();
            var nowMin = now.getHours() * 60 + now.getMinutes();

            for (var i = 0; i < arr.length; i++) {
                var t = arr[i];
                if (!t) continue;
                var mins = toMin(t);
                if (mins >= nowMin) {
                    return { time: t, diffMin: mins - nowMin };
                }
            }
            return null; // 오늘 운행 종료
        }

        function formatRemain(sec) {
            if (sec <= 0) return "(곧 도착)";
            var m = Math.floor(sec / 60);
            var s = sec % 60;
            return " (약 " + m + "분 " + String(s).padStart(2, '0') + "초 후)";
        }

        function getCurrentScheduleArray() {
            if (currentDayType === 'MON_FRI') {
                return (currentDepart === 'EE') ? timesMonFri_EE : timesMonFri_GI;
            } else {
                return (currentDepart === 'EE') ? timesTwt_EE : timesTwt_GI;
            }
        }

        /* =========================================
         *  메인 갱신 함수 (다음 도착시간 / 남은시간)
         * ========================================= */
        function updateNextBus() {
            var schedule = getCurrentScheduleArray();
            var box = document.getElementById("next-bus-box");
            var timeEl = document.getElementById("next-time");
            var remainEl = document.getElementById("next-remain");
            var subEl = document.getElementById("next-sub");

            if (!box || !timeEl || !remainEl || !subEl) return;

            var now = new Date();
            var next = getNextFromSchedule(schedule);

            var departLabel = (currentDepart === 'EE') ? "이공관 기준" : "기흥역 기준";
            var dayLabel = (currentDayType === 'MON_FRI') ? "월·금 시간표" : "화·수·목 시간표";

            if (!next) {
                timeEl.textContent = "--:--";
                remainEl.textContent = "";
                subEl.textContent = departLabel + " " + dayLabel + " 기준 오늘 운행은 모두 종료되었습니다.";
                return;
            }

            timeEl.textContent = next.time;

            // 초 단위 카운트다운
            var nowSec = now.getHours() * 3600 + now.getMinutes() * 60 + now.getSeconds();
            var targetSec = toMin(next.time) * 60;
            var diffSec = targetSec - nowSec;
            if (diffSec < 0) diffSec = 0;

            remainEl.textContent = formatRemain(diffSec);
            subEl.textContent = departLabel + " " + dayLabel + " 기준 다음 달구지 예상 도착시간입니다.";
        }

        /* =========================================
         *  출발점 선택 버튼
         * ========================================= */
        function setDepart(type) {
            currentDepart = type; // 'EE' or 'GI'

            var btnEE = document.getElementById("btn-depart-ee");
            var btnGI = document.getElementById("btn-depart-gi");

            if (btnEE && btnGI) {
                if (type === 'EE') {
                    btnEE.classList.add("active");
                    btnGI.classList.remove("active");
                } else {
                    btnEE.classList.remove("active");
                    btnGI.classList.add("active");
                }
            }

            updateNextBus();
        }

        /* =========================================
         *  초기 설정
         * ========================================= */
        window.addEventListener('DOMContentLoaded', function () {
            // 요일 기준 기본 탭 선택
            var now = new Date();
            var day = now.getDay(); // 0:일 ~ 6:토

            if (day === 2 || day === 3 || day === 4) {
                currentDayType = 'TUE_WED_THU';
                showTimetable('TUE_WED_THU');
            } else {
                currentDayType = 'MON_FRI';
                showTimetable('MON_FRI');
            }

            // 기본 출발점: 이공관
            setDepart('EE');

            // 1초마다 카운트다운 갱신
            setInterval(updateNextBus, 1000);
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
                <div class="card-sub">요일별·출발점 기준으로 다음 달구지 도착시간을 표시합니다.</div>
            </div>
            <div class="header-right">
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
                <div class="depart-buttons">
                    <button type="button" id="btn-depart-ee"
                            class="depart-btn" onclick="setDepart('EE')">
                        이공관 기준
                    </button>
                    <button type="button" id="btn-depart-gi"
                            class="depart-btn" onclick="setDepart('GI')">
                        기흥역 기준
                    </button>
                </div>
            </div>
        </div>

        <div class="timetable-wrap">
            <!-- 다음 달구지 정보 오버레이 -->
            <div id="next-bus-box" class="next-bus-box">
                <div class="next-bus-main">
                    다음 달구지 <span id="next-time" class="next-bus-time">--:--</span>
                    <span id="next-remain"></span>
                </div>
                <div id="next-sub" class="next-bus-sub">
                    이공관 기준 월·금 시간표 기준 다음 달구지 예상 도착시간입니다.
                </div>
            </div>

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
        <iframe class="map-frame"
                title="달구지 실시간 위치"
                loading="lazy">
        </iframe>

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
