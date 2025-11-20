package crawler;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

import java.util.ArrayList;
import java.util.List;

public class EverytimeTimetableParser {

    public static class LectureSlot {
        public String semester;     // 학기명 (테이블별)
        public String courseName;
        public String professor;
        public String classroom;
        public String dayOfWeek;    // 아직 정확히 못 뽑으면 null
        public Integer startPeriod; // 마찬가지
        public Integer endPeriod;
        public String color;
        public String rawText;
    }

    /**
     * 공유된 시간표 URL에서 시간표 정보 파싱
     */
    public List<LectureSlot> parse(String url) throws Exception {
        List<LectureSlot> result = new ArrayList<>();

        Document doc = Jsoup.connect(url)
                .userAgent("Mozilla/5.0")
                .timeout(10000)
                .get();

        // table.tablebody 가 학기별 테이블
        Elements semesterTables = doc.select("table.tablebody");

        int semIndex = 0;
        for (Element table : semesterTables) {
            semIndex++;

            // 학기 이름 추출 시도
            // 1) table 에 data-semester 같은 속성이 있으면 그걸 사용
            String semester = table.attr("data-semester");
            // 2) 없으면 table 이전의 제목 같은 걸 사용
            if (semester == null || semester.isBlank()) {
                Element prevTitle = table.previousElementSibling();
                if (prevTitle != null) {
                    semester = prevTitle.text().trim();
                }
            }
            // 3) 그래도 없으면 index 기반으로 fallback
            if (semester == null || semester.isBlank()) {
                semester = "학기" + semIndex;
            }

            // table 안의 td 안에 .cols 가 과목 블록
            Elements cols = table.select("td .cols");
            for (Element col : cols) {
                LectureSlot slot = new LectureSlot();
                slot.semester = semester;

                // 과목명: 보통 .subject, .name, strong 등 안에 있음. 없으면 첫 줄 텍스트.
                Element nameEl = col.selectFirst(".subject, .name, .articlename, strong");
                if (nameEl != null) {
                    slot.courseName = nameEl.text().trim();
                } else {
                    // 줄바꿈 기준 첫 줄을 제목으로 사용
                    String[] lines = col.text().split("\\r?\\n");
                    slot.courseName = lines.length > 0 ? lines[0].trim() : "(이름 없음)";
                }

                // 교수명 / 강의실 등은 보통 나머지 줄에 들어있을 가능성 큼
                String allText = col.text().trim();
                slot.rawText = allText;

                // 매우 단순한 패턴: "과목명\n교수명\n강의실" 형태라고 가정
                String[] lines = allText.split("\\r?\\n");
                if (lines.length >= 2) {
                    slot.professor = lines[1].trim();
                }
                if (lines.length >= 3) {
                    slot.classroom = lines[2].trim();
                }

                // 요일/교시/색상은 나중에 cols 의 data-* 속성이나 style 에서 추출 가능
                // 예시:
                // String style = col.attr("style");
                // slot.color = col.attr("data-color");

                result.add(slot);
            }
        }

        return result;
    }
}
