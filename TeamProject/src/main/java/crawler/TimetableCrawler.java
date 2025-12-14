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

    
    public boolean login(String username, String password) throws Exception {

        
        Connection.Response loginPageRes = Jsoup.connect(LOGIN_PAGE)
                .method(Connection.Method.GET)
                .timeout(5000)
                .execute();

        cookies = loginPageRes.cookies();

        
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

        
        boolean fail = doc.select("body.notloggedin").size() > 0;
        return !fail;
    }

    
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

            
            
            
            String title = raw;
            if (raw.contains("("))
                title = raw.substring(0, raw.indexOf("(")).trim();

            
            
            
            if (!raw.contains("(") || !raw.contains(")"))
                continue; 

            String inside = raw.substring(raw.indexOf("(") + 1, raw.indexOf(")")).trim();

            
            
            
            
            if (inside.equals("") || inside.contains("온라인"))
                continue; 

            String[] parts = inside.split(" ");

            if (parts.length < 2)
                continue; 

            String yoil = parts[0].trim();  

            String[] times = parts[1].split("-");
            if (times.length < 2)
                continue; 

            int day = parseDay(yoil);
            if (day == -1)
                continue;

            int start = parseMin(times[0]);
            int end = parseMin(times[1]);

            
            
            
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