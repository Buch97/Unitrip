package communication;

import com.ericsson.otp.erlang.*;
import dto.Trip;
import dto.TripList;
import dto.User;

import javax.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;

//i metodi di questa classe sono chiamati dai vari servlet
//in questo modulo si devono inoltratre i messaggi di richiesta dei vari client al server di erlang
public class MessageHandler {
    private static final String serverNode = "server@localhost";
    private static final String serverPID = "otp_server";

    public String register_message(HttpSession s, User user) throws OtpErlangDecodeException, OtpErlangExit {
        /*OtpErlangMap otpErlangMap = new OtpErlangMap(
                new OtpErlangObject[]{new OtpErlangString("username"), new OtpErlangString("password")},
                new OtpErlangObject[]{new OtpErlangString(user.getUsername()), new OtpErlangString(user.getPassword())});*/
        OtpErlangTuple otpErlangTuple = new OtpErlangTuple(new OtpErlangObject[]{new OtpErlangString(user.getUsername()),
                new OtpErlangString(user.getPassword())});
        send(s, serverPID, new OtpErlangAtom("register"), otpErlangTuple);
        return receiveResponse(s);
    }

    public String login_message(HttpSession s, User user) throws OtpErlangDecodeException, OtpErlangExit {
        OtpErlangTuple otpErlangTuple = new OtpErlangTuple(new OtpErlangObject[]{new OtpErlangString(user.getUsername()),
                new OtpErlangString(user.getPassword())});
        send(s, serverPID, new OtpErlangAtom("login"), otpErlangTuple);
        return receiveResponse(s);
    }

    public String create_trip(HttpSession s, Trip trip) throws OtpErlangDecodeException, OtpErlangExit {
        OtpErlangTuple otpErlangTuple = new OtpErlangTuple(new OtpErlangObject[]{new OtpErlangString(trip.getDestination()), new OtpErlangString(trip.getDate().toString()),
                new OtpErlangString(trip.getFounder()), new OtpErlangInt(trip.getSeats())});
        send(s, serverPID, new OtpErlangAtom("create_trip"), otpErlangTuple);
        return receiveResponse(s);
    }

    public String add_participant(HttpSession s, String user, int trip) throws OtpErlangDecodeException, OtpErlangExit {
        OtpErlangTuple otpErlangTuple = new OtpErlangTuple(new OtpErlangObject[]{new OtpErlangString(user),
                new OtpErlangInt(trip)});
        send(s, serverPID, new OtpErlangAtom("add_participant"), otpErlangTuple);
        return receiveResponse(s);
    }

    public String remove_participant(HttpSession s, String user, int trip) throws OtpErlangDecodeException, OtpErlangExit {
        OtpErlangTuple otpErlangTuple = new OtpErlangTuple(new OtpErlangObject[]{new OtpErlangString(user),
                new OtpErlangInt(trip)});
        send(s, serverPID, new OtpErlangAtom("remove_participant"), otpErlangTuple);
        return receiveResponse(s);
    }

    public TripList get_active_trips(HttpSession s) throws OtpErlangDecodeException, OtpErlangExit, OtpErlangRangeException {
        send(s, serverPID, new OtpErlangAtom("get_active_trips"));
        return receiveList(s);
    }

    private void send(HttpSession session, String serverPID, OtpErlangAtom otpErlangAtom) {
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session); //creo la mailbox a cui mi risponderà il server
        OtpErlangTuple request = new OtpErlangTuple(new OtpErlangObject[]{otpMbox.self(), otpErlangAtom});
        otpMbox.send(serverPID, serverNode, request);
    }

    public void send(HttpSession session, String serverPID, OtpErlangAtom otpErlangAtom, OtpErlangTuple otpErlangTuple){
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session); //creo la mailbox a cui mi risponderà il server
        OtpErlangTuple request = new OtpErlangTuple(new OtpErlangObject[]{otpMbox.self(), otpErlangAtom, otpErlangTuple});
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

    public TripList receiveList(HttpSession session) throws OtpErlangDecodeException, OtpErlangExit, OtpErlangRangeException {
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session);
        OtpErlangObject message = otpMbox.receive();
        List<Trip> tripList = new ArrayList<>();
        if(message instanceof OtpErlangTuple) {
            OtpErlangTuple responseTuple = (OtpErlangTuple) ((OtpErlangTuple) message).elementAt(1);
            OtpErlangList otpErlangList = (OtpErlangList) (responseTuple).elementAt(0);

            for (OtpErlangObject elem : otpErlangList) {
                Trip trip = Trip.parseErlang((OtpErlangList) elem);
                tripList.add(trip);
            }
        }
        return (TripList) tripList;

    }


}
