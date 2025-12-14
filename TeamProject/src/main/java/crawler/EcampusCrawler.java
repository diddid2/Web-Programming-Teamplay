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
        
        Connection.Response loginPageRes = Jsoup.connect("https://ecampus.kangnam.ac.kr/login.php")
                .method(Connection.Method.GET)
                .timeout(5000)
                .execute();

        Map<String, String> cookies = loginPageRes.cookies();

        
        
        
        
        String actionUrl = "https://ecampus.kangnam.ac.kr/login/index.php";

        
        Connection.Response loginRes = Jsoup.connect(actionUrl)
                .cookies(cookies) 
                .data("username", username)
                .data("password", password)
                .data("rememberusername", "1")   
                .data("loginbutton", "로그인")   
                .method(Connection.Method.POST)
                .timeout(5000)
                .execute();

        
        Document afterLogin = loginRes.parse();

        
        
        
        boolean stillNotLoggedIn = afterLogin.select("body.notloggedin").size() > 0;

        
        if (!stillNotLoggedIn) {
            this.cookies = loginRes.cookies();  
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

        
        
        Elements events = doc.select(".course_link"); 
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
        		String dueText = datas.get("종료 일시");
        		
        		if (dueText == null || dueText.trim().isEmpty()) {
        		    System.out.println("[SKIP] 종료 일시 없음 → " + title);
        		    continue;   
        		}
        		
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
