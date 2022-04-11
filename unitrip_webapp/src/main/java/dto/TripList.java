package dto;

import java.util.ArrayList;

public class TripList {
    ArrayList<Trip> trips;

    public TripList(ArrayList<Trip> trips) {
        this.trips = trips;
    }

    public TripList() {

    }

    public ArrayList<Trip> getTrips() {
        return trips;
    }

    public void setTrips(ArrayList<Trip> trips) {
        this.trips = trips;
    }
}
