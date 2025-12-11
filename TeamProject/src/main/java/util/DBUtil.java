package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBUtil {
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String URL = "jdbc:mysql://localhost:3306/kangnamtime?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
    private static final String USER = "kangnamtime";
    private static final String PASSWORD = "4321";


    public static Connection getConnection() throws Exception {
        Class.forName(DRIVER);
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
