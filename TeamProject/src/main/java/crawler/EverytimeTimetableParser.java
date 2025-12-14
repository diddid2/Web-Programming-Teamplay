package crawler;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.util.ArrayList;
import java.util.List;

public class EverytimeTimetableParser {

    public static class LectureSlot {
        public String semester;     
        public String courseName;
        public String professor;
        public String classroom;
        public String dayOfWeek;    
        public Integer startPeriod; 
        public Integer endPeriod;
        public String color;
        public String rawText;
    }

    


    public List<LectureSlot> parse(String url) throws Exception {
        List<LectureSlot> result = new ArrayList<>();

        Document doc = Jsoup.connect(url)
                .userAgent("Mozilla/5.0")
                .timeout(10000)
                .get();

        
        Elements semesterTables = doc.select("table.tablebody");

        int semIndex = 0;
        for (Element table : semesterTables) {
            semIndex++;

            
            
            String semester = table.attr("data-semester");
            
            if (semester == null || semester.isBlank()) {
                Element prevTitle = table.previousElementSibling();
                if (prevTitle != null) {
                    semester = prevTitle.text().trim();
                }
            }
            
            if (semester == null || semester.isBlank()) {
                semester = "학기" + semIndex;
            }

            
            Elements cols = table.select("td .cols");
            for (Element col : cols) {
                LectureSlot slot = new LectureSlot();
                slot.semester = semester;

                
                Element nameEl = col.selectFirst(".subject, .name, .articlename, strong");
                if (nameEl != null) {
                    slot.courseName = nameEl.text().trim();
                } else {
                    
                    String[] lines = col.text().split("\\r?\\n");
                    slot.courseName = lines.length > 0 ? lines[0].trim() : "(이름 없음)";
                }

                
                String allText = col.text().trim();
                slot.rawText = allText;

                
                String[] lines = allText.split("\\r?\\n");
                if (lines.length >= 2) {
                    slot.professor = lines[1].trim();
                }
                if (lines.length >= 3) {
                    slot.classroom = lines[2].trim();
                }

                
                
                
                

                result.add(slot);
            }
        }

        return result;
    }
}
