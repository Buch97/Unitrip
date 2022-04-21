package communication;

import com.ericsson.otp.erlang.*;
import dto.Trip;
import dto.User;

import javax.servlet.http.HttpSession;
import java.text.ParseException;
import java.util.ArrayList;

//i metodi di questa classe sono chiamati dai vari servlet
//in questo modulo si devono inoltratre i messaggi di richiesta dei vari client al server di erlang
public class MessageHandler{
    private static final String serverNode = "server@localhost";
    private static final String serverPID = "loop_server";
    private static int id = 0;

    public String register_message(HttpSession s, User user) throws OtpErlangDecodeException, OtpErlangExit {
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

    public String create_trip(HttpSession s, String trip_name, String destination, long date, String founder, int seats) throws OtpErlangDecodeException, OtpErlangExit {
        OtpErlangTuple otpErlangTuple = new OtpErlangTuple(new OtpErlangObject[]{new OtpErlangString(trip_name),
                new OtpErlangString(founder), new OtpErlangString(destination),
                new OtpErlangLong(date), new OtpErlangInt(seats)});
        send(s, serverPID, new OtpErlangAtom("create_trip"), otpErlangTuple);
        return receiveResponseTripCreation(s);
    }

    public String add_participant(HttpSession s, String user, String trip_name) throws OtpErlangDecodeException, OtpErlangExit {
        OtpErlangPid target_pid = get_trip_pid(s, trip_name);
        //System.out.println("PID RICEVUTO: " + target_pid);
        sendToPid(s, target_pid, new OtpErlangAtom("new_partecipant"), new OtpErlangString(user));
        return receiveResponseAddPartecipant(s);
    }

    private OtpErlangPid get_trip_pid(HttpSession s, String trip_name) throws OtpErlangDecodeException, OtpErlangExit {
        sendGetTripByName(s, serverPID, new OtpErlangAtom("get_trip_by_name"), new OtpErlangString(trip_name));
        return receivePid(s);
    }

    public String remove_participant(HttpSession s, String user, String trip_name) throws OtpErlangDecodeException, OtpErlangExit {
        OtpErlangPid target_pid = get_trip_pid(s, trip_name);
        //System.out.println("PID RICEVUTO: " + target_pid);
        sendToPid(s, target_pid, new OtpErlangAtom("delete_partecipant"), new OtpErlangString(user));
        return receiveResponse(s);
    }

    public ArrayList<Trip> get_active_trips(HttpSession s) throws OtpErlangDecodeException, OtpErlangExit, OtpErlangRangeException, ParseException {
        send(s, serverPID, new OtpErlangAtom("get_trips"));
        return receiveList(s);
    }

    public String delete_trip(HttpSession s, String trip) throws OtpErlangDecodeException, OtpErlangExit {
        sendDeleteTrip(s, serverPID, new OtpErlangAtom("delete_trip"), new OtpErlangString(trip));
        return receiveResponse(s);
    }

    private void sendDeleteTrip(HttpSession session, String serverPID, OtpErlangAtom otpErlangAtom, OtpErlangString otpErlangString) {
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session); //creo la mailbox a cui mi risponderà il server
        //System.out.println(otpMbox.self());
        OtpErlangTuple request = new OtpErlangTuple(new OtpErlangObject[]{otpMbox.self(), otpErlangAtom, otpErlangString});
        //System.out.println("REQUEST: " + request);
        otpMbox.send(serverPID, serverNode, request);
    }

    public void send(HttpSession session, String serverPID, OtpErlangAtom otpErlangAtom) {
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session); //creo la mailbox a cui mi risponderà il server
        //System.out.println(otpMbox.self());
        OtpErlangTuple request = new OtpErlangTuple(new OtpErlangObject[]{otpMbox.self(), otpErlangAtom});
        otpMbox.send(serverPID, serverNode, request);
    }

    public void sendGetTripByName(HttpSession session, String serverPID, OtpErlangAtom otpErlangAtomOne, OtpErlangString otpErlangAtomTwo) {
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session); //creo la mailbox a cui mi risponderà il server
        //System.out.println(otpMbox.self());
        OtpErlangTuple request = new OtpErlangTuple(new OtpErlangObject[]{otpMbox.self(), otpErlangAtomOne, otpErlangAtomTwo});
        //System.out.println("REQUEST(sendToGetPid): " + request);
        otpMbox.send(serverPID, serverNode, request);
    }

    public void send(HttpSession session, String serverPID, OtpErlangAtom otpErlangAtom, OtpErlangTuple otpErlangTuple){
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session); //creo la mailbox a cui mi risponderà il server
        //System.out.println("funzione: " + otpErlangAtom + " ,Mbox creata");
        //System.out.println("tupla: " + otpErlangTuple);
        OtpErlangTuple request = new OtpErlangTuple(new OtpErlangObject[]{otpMbox.self(), otpErlangAtom, otpErlangTuple});
        //System.out.println("Request: " + request);
        otpMbox.send(serverPID, serverNode, request);
        //System.out.println("Send Mbox fatta");
    }

    public void sendToPid(HttpSession session, OtpErlangPid trip_process, OtpErlangAtom otpErlangAtom, OtpErlangString otpErlangTuple){
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session); //creo la mailbox a cui mi risponderà il server
        //System.out.println("sendToPId: Mbox creata");
        OtpErlangTuple request = new OtpErlangTuple(new OtpErlangObject[]{otpMbox.self(), otpErlangAtom, otpErlangTuple});
        //System.out.println("REQUEST ADD PARTICPANT: " + request);
        otpMbox.send(trip_process, request);
        //System.out.println("sendToPid: Inviata");
    }

    public String receiveResponse(HttpSession session) throws OtpErlangDecodeException, OtpErlangExit {
        OtpErlangAtom status = new OtpErlangAtom("");
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session);
        //System.out.println("MBOX CREATA ASPETTO RISPOSTA");
        OtpErlangObject message = otpMbox.receive();
        //System.out.println("Message: " + message);
        if(message instanceof OtpErlangTuple){
            OtpErlangTuple responseTuple = (OtpErlangTuple) ((OtpErlangTuple) message).elementAt(1);
            status = (OtpErlangAtom) (responseTuple).elementAt(1); //vado a vedere solo l'esito della mia richiesta
        }
        //System.out.println(status.toString()); //ricevo {atomic,ok} perchè?
        return status.toString();
    }

    public String receiveResponseAddPartecipant(HttpSession session) throws OtpErlangDecodeException, OtpErlangExit {
        OtpErlangAtom status = new OtpErlangAtom("");
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session);
        //System.out.println("MBOX CREATA ASPETTO RISPOSTA");
        OtpErlangObject message = otpMbox.receive();
        //System.out.println("Message: " + message);
        if(message instanceof OtpErlangTuple){
            OtpErlangTuple responseTuple = (OtpErlangTuple) ((OtpErlangTuple) message).elementAt(1);
            status = (OtpErlangAtom) (responseTuple).elementAt(1);
        }
        //System.out.println(status.toString()); //ricevo {atomic,ok} perchè?
        return status.toString();
    }

    public OtpErlangPid receivePid(HttpSession session) throws OtpErlangDecodeException, OtpErlangExit {
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session);
        //System.out.println("MBOX CREATA ASPETTO RISPOSTA COL PID");
        OtpErlangObject message = otpMbox.receive();
        //System.out.println("Message: " + message);
        OtpErlangList obj = null;
        if(message instanceof OtpErlangTuple){
            OtpErlangTuple responseTuple = (OtpErlangTuple) ((OtpErlangTuple) message).elementAt(1);
            //System.out.println("response tuple " + responseTuple);
            obj = (OtpErlangList) responseTuple.elementAt(1);
        }
        return (OtpErlangPid) obj.elementAt(0);
    }

    public String receiveResponseTripCreation(HttpSession session) throws OtpErlangDecodeException, OtpErlangExit {
        OtpErlangAtom status = new OtpErlangAtom("");
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session);
        //System.out.println("MBOX CREATA ASPETTO RISPOSTA");
        OtpErlangObject message = otpMbox.receive();
        //System.out.println("Message: " + message);
        if(message instanceof OtpErlangTuple){
            OtpErlangTuple responseTuple = (OtpErlangTuple) ((OtpErlangTuple) message).elementAt(1);
            OtpErlangTuple first = (OtpErlangTuple) responseTuple.elementAt(0);
            status = (OtpErlangAtom) (first).elementAt(1);//vado a vedere solo l'esito della mia richiesta
        }
        System.out.println(status.toString()); //ricevo {atomic,ok} perchè?
        return status.toString();
    }

    public ArrayList<Trip> receiveList(HttpSession session) throws OtpErlangDecodeException, OtpErlangExit, OtpErlangRangeException, ParseException {
        OtpMbox otpMbox = OtpMboxSingleton.getInstance(session);
        OtpErlangObject message = otpMbox.receive();
        //System.out.println("Message: " + message);
        ArrayList<Trip> tripList = new ArrayList<>();
        if(message instanceof OtpErlangTuple) {
            OtpErlangList responseList = (OtpErlangList) ((OtpErlangTuple) message).elementAt(1);
            //OtpErlangTuple tuple = new OtpErlangTuple(responseObj[]);
            for(OtpErlangObject obj : responseList){
                OtpErlangTuple tuple = (OtpErlangTuple) obj;
                OtpErlangList event_trip = (OtpErlangList) tuple.elementAt(1);
                for(OtpErlangObject elem: event_trip) {
                    //System.out.println("LISTA: " + elem);
                    Trip trip = Trip.parseErlang((OtpErlangList) elem);
                    tripList.add(trip);
                }
            }
        }
        return tripList;

    }


}
