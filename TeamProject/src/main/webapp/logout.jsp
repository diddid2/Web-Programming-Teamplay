<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 현재 세션 완전 삭제
    session.invalidate();
%>
<script>
    alert('로그아웃 되었습니다.');
    location.href = 'main.jsp';
</script>
