package crawler;

import java.net.CookieHandler;
import java.net.CookieManager;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jsoup.Connection;
import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

public class EcampusCrawler {

    private static final String LOGIN_URL     = "https://ecampus.kangnam.ac.kr/login.php";
    private static final String UPCOMING_URL = "https://ecampus.kangnam.ac.kr/"; 

    private final CookieManager cookieManager;

    public static class EcampusAssignment {
        public String title;
        public String course;
        public Date   dueDate;
        public String link;
        public boolean isPassed;
    }

    public EcampusCrawler() {
        cookieManager = new CookieManager();
        CookieHandler.setDefault(cookieManager);
    }
    
    Map<String, String> cookies;

    public boolean login(String username, String password) throws Exception {
        // 1) login.php 먼저 열어서 쿠키/세션 확보
        Connection.Response loginPageRes = Jsoup.connect("https://ecampus.kangnam.ac.kr/login.php")
                .method(Connection.Method.GET)
                .timeout(5000)
                .execute();

        Map<String, String> cookies = loginPageRes.cookies();

        // 2) HTML에서 form action을 읽어와도 되고, 그냥 상수로 써도 됨
        // Document loginPage = loginPageRes.parse();
        // Element form = loginPage.selectFirst("form.mform.form-login");
        // String actionUrl = form.absUrl("action");
        String actionUrl = "https://ecampus.kangnam.ac.kr/login/index.php";

        // 3) 로그인 POST (username / password / rememberusername)
        Connection.Response loginRes = Jsoup.connect(actionUrl)
                .cookies(cookies) // 위에서 받은 쿠키 이어서 사용
                .data("username", username)
                .data("password", password)
                .data("rememberusername", "1")   // 체크박스: 기억하기 옵션 (생략해도 보통 OK)
                .data("loginbutton", "로그인")   // 버튼 name (필수는 아닐 확률이 큼, 그래도 맞춰줌)
                .method(Connection.Method.POST)
                .timeout(5000)
                .execute();

        // 4) 로그인 이후 페이지 HTML
        Document afterLogin = loginRes.parse();

        // 5) 로그인 성공 여부 체크
        // 로그인 페이지 body에는 class에 "notloggedin"이 들어있음:
        // <body ... class="... notloggedin loginpage_7 ">
        boolean stillNotLoggedIn = afterLogin.select("body.notloggedin").size() > 0;

        // 성공시 쿠키를 이 인스턴스에서 계속 쓰고 싶다면 필드에 저장
        if (!stillNotLoggedIn) {
            this.cookies = loginRes.cookies();  // 필드 Map<String,String> cookies;
            return true;
        } else {
            return false;
        }
    }


    public List<EcampusAssignment> fetchUpcomingAssignments() throws Exception {
        List<EcampusAssignment> list = new ArrayList<>();

        Document doc = Jsoup.connect(UPCOMING_URL)
                .timeout(5000)
                .get();

        // ★★★ 이 부분은 실제 HTML 구조 보고 selector 수정 필요 ★★★
        // 예: Moodle 기준 upcoming events에서 assignment들의 li 요소를 파싱
        Elements events = doc.select(".course_link"); // 예시
        for (Element ev : events) {
        	String link = ev.attr("href");
        	System.out.println(link);
        	
        	Document class_page = Jsoup.connect(link)
                    .timeout(5000)
                    .get();
        	Elements element = class_page.select(".coursename h1 a");
        	String course_name = element.text();
        	
        	System.out.println(course_name);
        	
        	Elements assignments = class_page.select(".activity.assign.modtype_assign");
        	for (Element assignment : assignments) {
        		String assign_link = assignment.select("a").attr("href");
        		if (assign_link.equals(""))
        		{
        			//예외 처리, assign_link가 ""인 경우 과제이지만 기한 제한이 걸려있어 접근이 안되는경우.
        			//임시로 건너뛰기 처리함. 
        			continue;
        		}
        		Document assign_page = Jsoup.connect(assign_link)
                        .timeout(5000)
                        .get();
        		Elements main_elements = assign_page.select("#region-main");
        		String title = main_elements.select("h2").text();
        		HashMap<String, String> datas = new HashMap<String, String>();
        		Elements target_table = main_elements.select("td");
        		for (int i = 0; i < target_table.size(); i += 2) {
        			datas.put(target_table.get(i).text(), target_table.get(i+1).text());
        		}
        		
        		String formatPattern = "yyyy-MM-dd HH:mm";
        		Date date = null;
                try {
                    SimpleDateFormat formatter = new SimpleDateFormat(formatPattern);
                    date = formatter.parse(datas.get("종료 일시"));

                } catch (ParseException e) {
                    System.err.println("날짜 파싱 오류: " + e.getMessage());
                }
        		
        		EcampusAssignment a = new EcampusAssignment();
                a.title = title;
                a.course = course_name;
                a.link = assign_link;
                a.dueDate = date;
                a.isPassed = datas.get("제출 여부").contains("완료") || datas.get("제출 여부").contains("요구하지 않습니다.");
                list.add(a);
        	}
        }
        return list;
    }
    
    public boolean getPassed(String link) throws Exception {
        Document assign_page = Jsoup.connect(link).timeout(5000).get();
		Elements main_elements = assign_page.select("#region-main");
		String title = main_elements.select("h2").text();
		HashMap<String, String> datas = new HashMap<String, String>();
		Elements target_table = main_elements.select("td");
		for (int i = 0; i < target_table.size(); i += 2) {
			datas.put(target_table.get(i).text(), target_table.get(i+1).text());
		}
        return datas.get("제출 여부").contains("완료") || datas.get("제출 여부").contains("요구하지 않습니다.");
    }
}
