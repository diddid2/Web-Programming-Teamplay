package proxy;

import dao.MarketItemDao;
import dto.MarketItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.StandardCopyOption;
import java.util.UUID;

@WebServlet("/market/update")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,      
        maxFileSize = 5 * 1024 * 1024,        
        maxRequestSize = 6 * 1024 * 1024      
)
public class MarketUpdateServlet extends HttpServlet {

    private final MarketItemDao marketItemDao = new MarketItemDao();

    private String emptyToNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }

    private String sanitizeSubmittedFileName(String submitted) {
        if (submitted == null) return null;
        String s = submitted.replace("\"", "").trim();
        int lastSep = Math.max(s.lastIndexOf('/'), s.lastIndexOf('\\'));
        if (lastSep != -1) s = s.substring(lastSep + 1);
        return s.isEmpty() ? null : s;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String ctx = request.getContextPath();

        
        HttpSession session = request.getSession(false);
        Integer memberNo = null;
        if (session != null) {
            Object o = session.getAttribute("memberNo");
            if (o instanceof Integer) memberNo = (Integer) o;
        }
        if (memberNo == null) {
            response.sendRedirect(ctx + "/login.jsp");
            return;
        }

        long itemId = 0;
        try { itemId = Long.parseLong(request.getParameter("itemId")); } catch (Exception ignore) {}
        if (itemId <= 0) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('잘못된 요청입니다.');location.href='" + ctx + "/market/marketMain.jsp';</script>");
            return;
        }

        MarketItem existing = marketItemDao.findById(itemId);
        if (existing == null) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('상품을 찾을 수 없습니다.');location.href='" + ctx + "/market/marketMain.jsp';</script>");
            return;
        }
        if (existing.getWriterId() == null || existing.getWriterId().intValue() != memberNo.intValue()) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('수정 권한이 없습니다.');location.href='" + ctx + "/market/marketView.jsp?id=" + itemId + "';</script>");
            return;
        }

        
        String title = emptyToNull(request.getParameter("title"));
        String category = emptyToNull(request.getParameter("category"));
        String priceStr = emptyToNull(request.getParameter("price"));
        String campus = emptyToNull(request.getParameter("campus"));
        String meetingPlace = emptyToNull(request.getParameter("meetingPlace"));
        String meetingTime = emptyToNull(request.getParameter("meetingTime"));
        String tradeType = emptyToNull(request.getParameter("tradeType"));
        String description = emptyToNull(request.getParameter("description"));
        String status = emptyToNull(request.getParameter("status"));
        boolean instantBuy = request.getParameter("instantBuy") != null;
        if (status == null) status = (existing.getStatus() != null ? existing.getStatus() : "ON_SALE");

        if (title == null || category == null || campus == null || tradeType == null || priceStr == null) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('필수 항목을 모두 입력해주세요.');history.back();</script>");
            return;
        }

        if (instantBuy && "DIRECT".equalsIgnoreCase(tradeType)) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('바로구매는 택배(또는 직거래+택배)로 설정해주세요.');history.back();</script>");
            return;
        }

        int price;
        try {
            price = Integer.parseInt(priceStr);
            if (price < 0) price = 0;
        } catch (Exception e) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('가격을 올바르게 입력해주세요.');history.back();</script>");
            return;
        }

        
        String thumbnailUrl = null;
        Part thumbnailPart = null;
        try {
            thumbnailPart = request.getPart("thumbnail");
        } catch (IllegalStateException ignore) {
            thumbnailPart = null;
        }

        if (thumbnailPart != null && thumbnailPart.getSize() > 0) {
            String submitted = sanitizeSubmittedFileName(thumbnailPart.getSubmittedFileName());
            String ext = "";
            if (submitted != null) {
                int dot = submitted.lastIndexOf('.');
                if (dot != -1 && dot < submitted.length() - 1) ext = submitted.substring(dot);
            }
            String fileName = UUID.randomUUID() + ext;

            String saveDir = getServletContext().getRealPath("/resources/MarketThumbnail");
            File dir = new File(saveDir);
            if (!dir.exists()) dir.mkdirs();

            File dest = new File(dir, fileName);
            try (InputStream in = thumbnailPart.getInputStream()) {
                Files.copy(in, dest.toPath(), StandardCopyOption.REPLACE_EXISTING);
            }

            
            thumbnailUrl = "/resources/MarketThumbnail/" + fileName;
        }

        MarketItem item = new MarketItem();
        item.setId(itemId);
        item.setWriterId(memberNo);
        item.setTitle(title);
        item.setCategory(category);
        item.setPrice(price);
        item.setCampus(campus);
        item.setMeetingPlace(meetingPlace);
        item.setMeetingTime(meetingTime);
        item.setTradeType(tradeType);
        item.setInstantBuy(instantBuy);
        item.setDescription(description);
        item.setStatus(status);

        
        item.setThumbnailUrl(thumbnailUrl);

        boolean ok = marketItemDao.update(item);
        if (!ok) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('수정에 실패했습니다.');history.back();</script>");
            return;
        }

        response.sendRedirect(ctx + "/market/marketView.jsp?id=" + itemId);
    }
}
