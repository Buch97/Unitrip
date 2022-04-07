package dto;

import java.util.ArrayList;

public class TripList {
    ArrayList<Trip> tripList;

    public TripList(ArrayList<Trip> tripList) {
        this.tripList = tripList;
    }

    public ArrayList<Trip> getTripList() {
        return tripList;
    }

    public void setTripList(ArrayList<Trip> tripList) {
        this.tripList = tripList;
    }
}
