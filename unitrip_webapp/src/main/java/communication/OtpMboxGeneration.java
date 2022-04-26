package communication;

import com.ericsson.otp.erlang.OtpMbox;
import com.ericsson.otp.erlang.OtpNode;

import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.net.InetAddress;

public class OtpMboxGeneration {
    private static final String cookie = "unitrip";
    private static OtpNode otpNode = null;
    private OtpMbox otpMbox;

    private OtpMboxGeneration(String id) throws IOException {
        otpMbox = otpNode.createMbox(id);
        System.out.println("OtpMBOX name: " + otpMbox.getName() + ", otpMBOX pid" + otpMbox.self().toString());
    }

    public static OtpMbox getInstance(HttpSession session) {
        if(otpNode == null){
            try {
                String nodeName = InetAddress.getLocalHost().getHostName();
                //otpNode = new OtpNode(nodeName + "@localhost", cookie); //nome client + cookie
                otpNode = new OtpNode(nodeName + "@localhost", cookie); //nome client + cookie
            } catch(Exception e){
                e.printStackTrace();
            }
        }

        OtpMboxGeneration ret = (OtpMboxGeneration) session.getAttribute("otpmbox");

        if (ret == null) {
            try {
                ret = new OtpMboxGeneration(session.getId());
                session.setAttribute("otpmbox", ret);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return ret.otpMbox;
    }
}

