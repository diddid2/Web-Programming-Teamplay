package util;

import java.sql.Connection;
import java.sql.DriverManager;

public class DBUtil {
    private static final String DRIVER = "oracle.jdbc.driver.OracleDriver";
    private static final String URL = "jdbc:oracle:thin:@localhost:1521:ORCL";
    private static final String USER = "KANGNAMTIME";
    private static final String PW   = "gnt1115";

    public static Connection getConnection() throws Exception {
        Class.forName(DRIVER);
        return DriverManager.getConnection(URL, USER, PW);
    }
}
