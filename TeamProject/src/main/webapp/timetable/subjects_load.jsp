<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>

<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.SQLException" %>

<%@ page import="java.util.regex.Pattern" %>
<%@ page import="java.util.regex.Matcher" %>

<%@ page import="org.jsoup.Jsoup" %>
<%@ page import="org.jsoup.nodes.Document" %>
<%@ page import="org.jsoup.nodes.Element" %>
<%@ page import="org.jsoup.select.Elements" %>

<%@ page import="util.DBUtil" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>강남대 강의목록 크롤링</title>
</head>
<body>
<%
    Connection dbConn = null;
    PreparedStatement pstmt = null;

    int successCount = 0;
    int failCount = 0;

    try {
        dbConn = DBUtil.getConnection();

        String sql =
            "INSERT INTO subject_info " +
            "(subj_numb, class_no, subject_name, professor_name, credit, hours, lecture_time, syllabus_link) " +
            "VALUES (?,?,?,?,?,?,?,?) " +
            "ON DUPLICATE KEY UPDATE " +
            "subject_name  = VALUES(subject_name), " +
            "professor_name= VALUES(professor_name), " +
            "credit        = VALUES(credit), " +
            "hours         = VALUES(hours), " +
            "lecture_time  = VALUES(lecture_time), " +
            "syllabus_link = VALUES(syllabus_link)";

        pstmt = dbConn.prepareStatement(sql);

        String rootUrl = "https://app.kangnam.ac.kr/knumis/sbr/sbr1010.jsp";

        Document rootDoc = Jsoup.connect(rootUrl)
                .userAgent("Mozilla/5.0")
                .timeout(30_000)
                .get();

        Element frameT = rootDoc.selectFirst("frame[name=frameT], iframe[name=frameT]");
        if (frameT == null) {
            out.println("<h3>frameT 를 찾을 수 없습니다.</h3>");
            return;
        }

        String frameTUrl = frameT.absUrl("src");
        out.println("<p>frameT URL: " + frameTUrl + "</p>");

        Document frameTDoc = Jsoup.connect(frameTUrl)
                .userAgent("Mozilla/5.0")
                .timeout(30_000)
                .get();

        Element form = frameTDoc.selectFirst("form[name=frm1], form#frm1");
        if (form == null) {
            out.println("<h3>frameT 안에서 frm1 을 찾을 수 없습니다.</h3>");
            return;
        }

        String actionUrl = form.hasAttr("action") && !form.attr("action").isEmpty()
                ? form.absUrl("action")
                : frameTUrl;

        String method = form.hasAttr("method") ? form.attr("method").toUpperCase() : "GET";

        org.jsoup.Connection jsoupConn = Jsoup.connect(actionUrl)
                .userAgent("Mozilla/5.0")
                .timeout(30_000);

        Elements inputs = form.select("input[name]");
        for (Element input : inputs) {
            String name  = input.attr("name");
            String value = input.attr("value");
            jsoupConn.data(name, value);
        }

        Elements selects = form.select("select[name]");
        for (Element sel : selects) {
            String name = sel.attr("name");
            Element selectedOpt = sel.selectFirst("option[selected]");
            String value = selectedOpt != null ? selectedOpt.attr("value") : "";
            jsoupConn.data(name, value);
        }

        jsoupConn.data("srch_gubn", "11");

        Document resultDoc;
        if ("POST".equals(method)) {
            resultDoc = jsoupConn.post();
        } else {
            resultDoc = jsoupConn.get();
        }

        Document listDoc = resultDoc;
        Elements testRows = listDoc.select("div#list table tbody tr");
        if (testRows.isEmpty()) {
            Element frameL = resultDoc.selectFirst("frame[name=frameL], iframe[name=frameL]");
            if (frameL != null) {
                String frameCUrl = frameL.absUrl("src");
                listDoc = Jsoup.connect(frameCUrl)
                        .userAgent("Mozilla/5.0")
                        .timeout(30_000)
                        .get();
            }
        }

        Elements rows = listDoc.select("div#list table tbody tr");

        if (rows.isEmpty()) {
            out.println("<h3>div#list 안에서 tr 을 찾지 못했습니다.</h3>");
        } else {
            out.println("<p>파싱한 행 개수: " + rows.size() + "</p>");

            for (Element row : rows) {
                Elements tds = row.select("td");
                if (tds.size() < 7) continue;

                try {
                    String subjNumb      = tds.get(0).text().trim();
                    String classNo       = tds.get(1).text().trim();
                    String subjectName   = tds.get(2).text().trim();
                    String professorName = tds.get(3).text().trim();
                    String creditStr     = tds.get(4).text().trim();
                    String hoursStr      = tds.get(5).text().trim();
                    String lectureTime   = tds.get(6).text().trim();

                    int credit = 0;
                    int hours  = 0;
                    try { credit = Integer.parseInt(creditStr); } catch (Exception ignore) {}
                    try { hours  = Integer.parseInt(hoursStr); }  catch (Exception ignore) {}

                    String onclickAttr = tds.get(3).attr("onclick");

                    String emplNumb = "";
                    String year     = "";
                    String smst     = "";
                    String subjFromOnclick  = "";
                    String classFromOnclick = "";

                    Pattern p = Pattern.compile("value_set\\('true','\\d+','([^']+)'\\)");
                    Matcher m = p.matcher(onclickAttr);
                    if (m.find()) {
                        String[] parts = m.group(1).split(",");
                        if (parts.length == 5) {
                            emplNumb        = parts[0];
                            year            = parts[1];
                            smst            = parts[2];
                            subjFromOnclick = parts[3];
                            classFromOnclick= parts[4];
                        }
                    }

                    if (!subjFromOnclick.isEmpty())  subjNumb = subjFromOnclick;
                    if (!classFromOnclick.isEmpty()) classNo  = classFromOnclick;

                    String syllabusUrl = "";
                    if (!year.isEmpty() && !smst.isEmpty() && !subjNumb.isEmpty()
                            && !classNo.isEmpty() && !emplNumb.isEmpty()) {

                        syllabusUrl =
                            "https://app.kangnam.ac.kr/knumis/sbr/syllabus2020.jsp" +
                            "?schl_year=" + year +
                            "&schl_smst=" + smst +
                            "&subj_numb=" + subjNumb +
                            "&lctr_clas=" + classNo +
                            "&empl_numb=" + emplNumb +
                            "&repo_path=../sbr/sbr3070_New.mrd" +
                            "&winopt=1010";
                    }

                    pstmt.setString(1, subjNumb);
                    pstmt.setString(2, classNo);
                    pstmt.setString(3, subjectName);
                    pstmt.setString(4, professorName);
                    pstmt.setInt(5, credit);
                    pstmt.setInt(6, hours);
                    pstmt.setString(7, lectureTime);
                    pstmt.setString(8, syllabusUrl);

                    int r = pstmt.executeUpdate();
                    if (r > 0) {
                        successCount++;
                    } else {
                        failCount++;
                    }

                } catch (Exception rowEx) {
                    failCount++;
                    out.println("<p>행 처리 중 오류: " + rowEx.getMessage() + "</p>");
                }
            }
        }

        out.println("<h3>크롤링 및 DB 저장 완료</h3>");
        out.println("<p>성공: " + successCount + "건</p>");
        out.println("<p>실패: " + failCount + "건</p>");

    } catch (Exception e) {
        out.println("<h3>전체 처리 중 오류 발생</h3>");
        out.println("<pre>" + e.toString() + "</pre>");
    } finally {
        try { if (pstmt  != null) pstmt.close(); } catch (Exception ignore) {}
        try { if (dbConn != null) dbConn.close(); } catch (Exception ignore) {}
    }
%>
</body>
</html>
