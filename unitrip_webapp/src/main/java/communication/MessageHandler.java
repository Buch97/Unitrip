package communication;

import com.ericsson.otp.erlang.*;
import dto.User;

import javax.servlet.http.HttpSession;

//i metodi di questa classe sono chiamati dai vari servlet
//in questo modulo si devono inoltratre i messaggi di richiesta dei vari client al server di erlang
public class MessageHandler {
    private static final String serverNode = "server@localhost";
    private static final String serverPID = "otp_server";

    public String register_message(HttpSession s, User user) throws OtpErlangDecodeException, OtpErlangExit {
        OtpErlangMap otpErlangMap = new OtpErlangMap(
                new OtpErlangObject[]{new OtpErlangString("username"), new OtpErlangString("password")},
                new OtpErlangObject[]{new OtpErlangString(user.getUsername()), new OtpErlangString(user.getPassword())});
        send(s, serverPID, new OtpErlangAtom("register"), otpErlangMap);
        return receiveResponse(s);
    }

    public String login_message(HttpSession s, User user) throws OtpErlangDecodeException, OtpErlangExit {
        OtpErlangMap otpErlangMap = new OtpErlangMap(
                new OtpErlangObject[]{new OtpErlangString("username"), new OtpErlangString("password")},
                new OtpErlangObject[]{new OtpErlangString(user.getUsername()), new OtpErlangString(user.getPassword())});
        send(s, serverPID, new OtpErlangAtom("login"), otpErlangMap);
        return receiveResponse(s);
    }

    public void send(HttpSession session, String serverPID, OtpErlangAtom otpErlangAtom, OtpErlangMap otpErlangMap){
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session); //creo la mailbox a cui mi risponderà il server
        OtpErlangTuple request = new OtpErlangTuple(new OtpErlangObject[]{otpMbox.self(), otpErlangAtom, otpErlangMap});
        otpMbox.send(serverPID, serverNode, request);
    }

    public String receiveResponse(HttpSession session) throws OtpErlangDecodeException, OtpErlangExit {
        OtpErlangAtom status = new OtpErlangAtom("");
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session);
        OtpErlangObject message = otpMbox.receive();
        if(message instanceof OtpErlangTuple){
            OtpErlangTuple responseTuple = (OtpErlangTuple) ((OtpErlangTuple) message).elementAt(1);
            status = (OtpErlangAtom) (responseTuple).elementAt(0); //vado a vedere solo l'esito della mia richiesta
        }
        return status.toString();
    }
}
