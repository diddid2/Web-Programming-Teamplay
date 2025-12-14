<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.*, java.text.SimpleDateFormat, dao.MarketChatDao, dto.ChatMessage" %>

<%!
    // JSON 문자열 escape (JSP 선언부)
    public static String jsonEscape(String s) {
        if (s == null) return "";
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < s.length(); i++) {
            char c = s.charAt(i);
            switch (c) {
                case '\\': sb.append("\\\\"); break;
                case '"':  sb.append("\\\""); break;
                case '\n': sb.append("\\n");  break;
                case '\r': sb.append("\\r");  break;
                case '\t': sb.append("\\t");  break;
                default:
                    if (c < 32) sb.append(' ');
                    else sb.append(c);
            }
        }
        return sb.toString();
    }
%>

<%
    request.setCharacterEncoding("UTF-8");

    // 캐시 방지
    response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    response.setHeader("Pragma", "no-cache");

    String userId = (String) session.getAttribute("userId");
    Integer memberNo = (Integer) session.getAttribute("memberNo");

    if (userId == null || memberNo == null) {
        out.print("[]");
        return;
    }

    long roomId = 0;
    long after = 0;
    try { roomId = Long.parseLong(request.getParameter("roomId")); } catch(Exception e) {}
    try { after  = Long.parseLong(request.getParameter("after")); }  catch(Exception e) {}

    // wait=1이면 롱폴링 모드(최대 25초 대기)
    boolean wait = "1".equals(request.getParameter("wait"));

    if (roomId <= 0) {
        out.print("[]");
        return;
    }

    MarketChatDao dao = new MarketChatDao();
    if (!dao.isParticipant(roomId, memberNo)) {
        out.print("[]");
        return;
    }

    List<ChatMessage> list = null;

    if (!wait) {
        list = dao.listMessages(roomId, after, 200);
    } else {
        long deadline = System.currentTimeMillis() + 25000; // 25초
        while (true) {
            list = dao.listMessages(roomId, after, 200);
            if (list != null && !list.isEmpty()) break; // 새 메시지 있으면 즉시 반환

            if (System.currentTimeMillis() >= deadline) {
                list = Collections.emptyList(); // 타임아웃이면 빈 배열
                break;
            }
            try { Thread.sleep(700); } catch (Exception ignored) {}
        }
    }

    // 새 메시지가 있다면 읽음 처리(롱폴링 응답 기준)
    if (list != null && !list.isEmpty()) {
        long lastId = list.get(list.size()-1).getMsgId();
        dao.markRead(roomId, memberNo, lastId);
    }

    SimpleDateFormat fmt = new SimpleDateFormat("HH:mm");

    StringBuilder outJson = new StringBuilder();
    outJson.append("[");

    if (list != null) {
        for (int i = 0; i < list.size(); i++) {
            ChatMessage m = list.get(i);
            if (i > 0) outJson.append(",");
            outJson.append("{");
            outJson.append("\"msgId\":").append(m.getMsgId()).append(",");
            outJson.append("\"senderId\":").append(m.getSenderId()).append(",");
            outJson.append("\"messageType\":\"").append(jsonEscape(m.getMessageType() != null ? m.getMessageType() : "USER")).append("\",");
            outJson.append("\"message\":\"").append(jsonEscape(m.getMessage())).append("\",");
            outJson.append("\"time\":\"").append(m.getCreatedAt() != null ? fmt.format(m.getCreatedAt()) : "").append("\"");
            outJson.append("}");
        }
    }

    outJson.append("]");
    out.print(outJson.toString());
%>
