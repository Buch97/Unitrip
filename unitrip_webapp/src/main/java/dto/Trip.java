package dto;

import java.util.ArrayList;
import java.util.Date;

public class Trip {
    int id;
    String destination;
    Date date;
    int seats;
    Date expirationDate; //o questo o direttamente un timer che scorre
    String contact;
    ArrayList<String> participants;
    String description;

    public Trip(String destination, Date date, int seats, Date expirationDate, String contact, ArrayList<String> particpants, String description) {
        this.id = id;
        this.destination = destination;
        this.date = date;
        this.seats = seats;
        this.expirationDate = expirationDate;
        this.contact = contact;
        this.participants = particpants;
        this.description = description;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getDestination() {
        return destination;
    }

    public void setDestination(String destination) {
        this.destination = destination;
    }

    public Date getDate() {
        return date;
    }

    public void setDate(Date date) {
        this.date = date;
    }

    public int getSeats() {
        return seats;
    }

    public void setSeats(int seats) {
        this.seats = seats;
    }

    public Date getExpirationDate() {
        return expirationDate;
    }

    public void setExpirationDate(Date expirationDate) {
        this.expirationDate = expirationDate;
    }

    public String getContact() {
        return contact;
    }

    public void setContact(String contact) {
        this.contact = contact;
    }

    public ArrayList<String> getParticipants() {
        return participants;
    }

    public void setParticipants(ArrayList<String> particpants) {
        this.participants = particpants;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }


}
