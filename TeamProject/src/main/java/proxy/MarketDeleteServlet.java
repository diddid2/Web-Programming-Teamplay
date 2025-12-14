package proxy;

import dao.MarketItemDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/market/delete")
public class MarketDeleteServlet extends HttpServlet {

    private final MarketItemDao marketItemDao = new MarketItemDao();

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
            response.getWriter().println("<script>alert('잘못된 요청입니다.');history.back();</script>");
            return;
        }

        boolean ok = marketItemDao.delete(itemId, memberNo);
        if (!ok) {
            response.setContentType("text/html; charset=UTF-8");
            response.getWriter().println("<script>alert('삭제에 실패했습니다. (작성자만 삭제 가능)');history.back();</script>");
            return;
        }

        response.sendRedirect(ctx + "/market/myMarket.jsp");
    }
}
