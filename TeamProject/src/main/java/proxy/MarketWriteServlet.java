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
import util.DBUtil; // 직접 쓰지 않으면 없어도 됨

import java.io.File;
import java.io.IOException;



// 만약 Tomcat 10 (jakarta) 쓰면 위 6줄을 jakarta.servlet.* 로 바꿔주면 됨.

@WebServlet("/market/write")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,      // 1MB
        maxFileSize = 5 * 1024 * 1024,        // 5MB
        maxRequestSize = 6 * 1024 * 1024      // 6MB
)
public class MarketWriteServlet extends HttpServlet {

    private final MarketItemDao marketItemDao = new MarketItemDao();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");

        String title = request.getParameter("title");
        String category = request.getParameter("category");
        String priceStr = request.getParameter("price");
        String campus = request.getParameter("campus");
        String meetingPlace = request.getParameter("meetingPlace");
        String meetingTime = request.getParameter("meetingTime");
        String tradeType = request.getParameter("tradeType");
        String description = request.getParameter("description");

        int price = 0;
        try { price = Integer.parseInt(priceStr); } catch (Exception e) {}

        // 로그인 유저 id (없으면 null)
        HttpSession session = request.getSession(false);
        Integer writerId = null;
        if (session != null) {
            Object obj = session.getAttribute("loginUserId");
            if (obj instanceof Integer) writerId = (Integer) obj;
        }

        // 썸네일 업로드
        Part thumbnailPart = request.getPart("thumbnail");
        String thumbnailUrl = null;

        if (thumbnailPart != null && thumbnailPart.getSize() > 0) {
            String uploadPath = getServletContext().getRealPath("/resources/marketImg");
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdirs();

            String originalFileName = extractFileName(thumbnailPart);
            if (originalFileName == null || originalFileName.isBlank()) {
                originalFileName = "noname.png";
            }

            String savedFileName = System.currentTimeMillis() + "_" + originalFileName;
            thumbnailPart.write(uploadPath + File.separator + savedFileName);

            thumbnailUrl = request.getContextPath() + "/resources/marketImg/" + savedFileName;
        }

        // DTO 저장
        MarketItem item = new MarketItem();
        item.setTitle(title);
        item.setCategory(category);
        item.setPrice(price);
        item.setCampus(campus);
        item.setMeetingPlace(emptyToNull(meetingPlace));
        item.setMeetingTime(emptyToNull(meetingTime));
        item.setTradeType(tradeType);
        item.setDescription(description);
        item.setStatus("ON_SALE");
        item.setWishCount(0);
        item.setChatCount(0);
        item.setThumbnailUrl(thumbnailUrl);
        item.setWriterId(writerId);

        marketItemDao.insert(item);

        response.sendRedirect(request.getContextPath() + "/market");
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        if (contentDisp == null) return null;

        for (String token : contentDisp.split(";")) {
            token = token.trim();
            if (token.startsWith("filename")) {
                String fileName = token.substring(token.indexOf('=') + 1)
                        .trim().replace("\"", "");
                int lastSep = fileName.lastIndexOf(File.separator);
                if (lastSep != -1) {
                    fileName = fileName.substring(lastSep + 1);
                }
                return fileName;
            }
        }
        return null;
    }

    private String emptyToNull(String s) {
        if (s == null) return null;
        s = s.trim();
        return s.isEmpty() ? null : s;
    }
}
