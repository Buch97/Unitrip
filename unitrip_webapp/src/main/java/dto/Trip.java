package dto;

import com.ericsson.otp.erlang.*;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;

public class Trip {
    OtpErlangPid pid;
    String destination;
    LocalDate date;
    String founder;
    int seats;
    ArrayList<String> participants;


    public Trip(String destination, LocalDate date, String founder, int seats) {
        this.destination = destination;
        this.founder = founder;
        this.date = date;
        this.seats = seats;
    }

    public Trip(OtpErlangPid pid, String destination, LocalDate date, String founder, int seats, ArrayList<String> participants) {
        this.pid = pid;
        this.destination = destination;
        this.founder = founder;
        this.date = date;
        this.seats = seats;
        this.participants = participants;
    }

    /*public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }*/

    public OtpErlangPid getPid() {
        return pid;
    }

    public void setPid(OtpErlangPid pid) {
        this.pid = pid;
    }

    public String getFounder() {
        return founder;
    }

    public void setFounder(String founder) {
        this.founder = founder;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public LocalDate getDate() {
        return date;
    }

    public void setDate(LocalDate date) {
        this.date = date;
    }

    public int getSeats() {
        return seats;
    }

    public void setSeats(int seats) {
        this.seats = seats;
    }

    public ArrayList<String> getParticipants() {
        return participants;
    }

    public void setParticipants(ArrayList<String> particpants) {
        this.participants = particpants;
    }

    public static Trip parseErlang(OtpErlangList elem) throws OtpErlangRangeException, ParseException {
        OtpErlangTuple record = (OtpErlangTuple) elem.elementAt(0);
        System.out.println("RECORD --> " + record);
        ArrayList<String> participants = null;
        String destination = record.elementAt(4).toString().replace("'","");
        System.out.println("DEST:" + destination);
        OtpErlangPid pid = ((OtpErlangPid) record.elementAt(1));
        System.out.println("PID: "+ pid);
        String dateErlang = record.elementAt(5).toString().replace("'","");
        //LocalDate date = Instant.ofEpochMilli(Long.parseLong(dateErlang)).atZone(ZoneId.systemDefault()).toLocalDate();
        DateTimeFormatter format = DateTimeFormatter.ofPattern("dd/MM/yyyy");
        LocalDate date = LocalDate.parse(dateErlang, format);
        System.out.println("DATE: " + date);

        String founder = record.elementAt(2).toString();
        System.out.println("FOUNDER: " + founder);
        int seats = Integer.parseInt(String.valueOf(record.elementAt(6)));
        System.out.println("SEATS: " + seats);
        String check = record.elementAt(7).toString();
        System.out.println(record.elementAt(7).toString());
        //if(Objects.equals(record.elementAt(7).toString(), "none"))
        //OtpErlangList erlParticipants = (OtpErlangList) (record.elementAt(7));

        /*for (OtpErlangObject obj : erlParticipants) {
            String user = obj.toString();
            if(!Objects.equals(user, "none"))
                participants.add(user);
        }*/

        System.out.println("CREA TRIP");
        return  new Trip(pid, destination, date, founder, seats, participants);
    }


}
