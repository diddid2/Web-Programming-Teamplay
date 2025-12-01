package crawler;

import java.net.CookieHandler;
import java.net.CookieManager;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.jsoup.Connection;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

public class TimetableCrawler {

    private static final String LOGIN_PAGE = "https://ecampus.kangnam.ac.kr/login.php";
    private static final String LOGIN_POST = "https://ecampus.kangnam.ac.kr/login/index.php";
    private static final String MAIN_URL = "https://ecampus.kangnam.ac.kr/";

    private CookieManager cookieManager;
    private Map<String,String> cookies;

    public TimetableCrawler() {
        cookieManager = new CookieManager();
        CookieHandler.setDefault(cookieManager);
    }

    /** 로그인 */
    public boolean login(String username, String password) throws Exception {

        // 1) login.php GET
        Connection.Response loginPageRes = Jsoup.connect(LOGIN_PAGE)
                .method(Connection.Method.GET)
                .timeout(5000)
                .execute();

        cookies = loginPageRes.cookies();

        // 2) POST 로그인
        Connection.Response loginRes = Jsoup.connect(LOGIN_POST)
                .cookies(cookies)
                .data("username", username)
                .data("password", password)
                .data("rememberusername", "1")
                .data("loginbutton", "로그인")
                .method(Connection.Method.POST)
                .timeout(5000)
                .execute();

        cookies = loginRes.cookies();

        Document doc = loginRes.parse();

        // 실패 여부 확인
        boolean fail = doc.select("body.notloggedin").size() > 0;
        return !fail;
    }

    /** 강의 구조 */
    public static class Lecture {
        public String title;
        public String professor;
        public int day;
        public int start;
        public int end;
    }

    private int parseDay(String s) {
        if (s.startsWith("월")) return 0;
        if (s.startsWith("화")) return 1;
        if (s.startsWith("수")) return 2;
        if (s.startsWith("목")) return 3;
        if (s.startsWith("금")) return 4;
        return -1;
    }

    private int parseMin(String hhmm) {
        String[] sp = hhmm.split(":");
        return Integer.parseInt(sp[0])*60 + Integer.parseInt(sp[1]);
    }

    /** 시간표 크롤링 */
    public List<Lecture> fetchTimetable() throws Exception {

        List<Lecture> list = new ArrayList<>();

        Document doc = Jsoup.connect(MAIN_URL)
                .cookies(cookies)
                .timeout(5000)
                .get();

        Elements boxes = doc.select(".course_box");

        for (Element box : boxes) {

            String raw = box.select(".course-title h3").text();
            if (raw == null || raw.trim().equals("")) continue;

            String prof = box.select("p.prof").text();

            // ---------------------------
            // ① 제목 추출
            // ---------------------------
            String title = raw;
            if (raw.contains("("))
                title = raw.substring(0, raw.indexOf("(")).trim();

            // ---------------------------
            // ② 괄호 안 추출 (없으면 skip)
            // ---------------------------
            if (!raw.contains("(") || !raw.contains(")"))
                continue; // 시간 정보 없는 강좌 → 건너뛰기

            String inside = raw.substring(raw.indexOf("(") + 1, raw.indexOf(")")).trim();

            // inside 예: "수 09:00-12:40"
            // inside 예: "목"
            // inside 예: "온라인"
            // inside 예: ""
            if (inside.equals("") || inside.contains("온라인"))
                continue; // 시간 없는 경우 skip

            String[] parts = inside.split(" ");

            if (parts.length < 2)
                continue; // "목" 이런 경우 skip

            String yoil = parts[0].trim();  // 요일

            String[] times = parts[1].split("-");
            if (times.length < 2)
                continue; // "09:00"만 있는 경우 skip

            int day = parseDay(yoil);
            if (day == -1)
                continue;

            int start = parseMin(times[0]);
            int end = parseMin(times[1]);

            // ---------------------------
            // ③ Lecture 객체 저장
            // ---------------------------
            Lecture L = new Lecture();
            L.title = title;
            L.professor = prof;
            L.day = day;
            L.start = start;
            L.end = end;

            list.add(L);
        }

        return list;
    }
}