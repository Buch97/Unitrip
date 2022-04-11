package dto;

import com.ericsson.otp.erlang.*;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Date;

public class Trip {
    int id;
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

    public Trip(String destination, LocalDate date, String founder, int seats, ArrayList<String> participants) {
        this.destination = destination;
        this.founder = founder;
        this.date = date;
        this.seats = seats;
        this.participants = participants;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
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

    public static Trip parseErlang(OtpErlangList elem) throws OtpErlangRangeException {
        ArrayList<String> participants = null;
        int id = ((OtpErlangInt) elem.elementAt(0)).intValue();
        String destination = ((OtpErlangString) elem.elementAt(1)).stringValue();
        String dateErlang = ((OtpErlangString) elem.elementAt(2)).stringValue();
        String founder = ((OtpErlangString) elem.elementAt(3)).stringValue();
        int seats = ((OtpErlangInt) elem.elementAt(0)).intValue();
        OtpErlangList erlParticipants = (OtpErlangList) (elem.elementAt(4));
        DateTimeFormatter format = DateTimeFormatter.ofPattern("d MMMM, yyyy");
        LocalDate date = getDateFromString(dateErlang, format);

        for (OtpErlangObject obj : erlParticipants) {
            String user = obj.toString();
            participants.add(user);
        }

        return  new Trip(destination, date, founder, seats, participants);
    }

    private static LocalDate getDateFromString(String dateErlang, DateTimeFormatter format) {
        LocalDate dateTime = LocalDate.parse(dateErlang, format);
        return dateTime;
    }


}
