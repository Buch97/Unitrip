let ws;

function connect(ctx, username) {
    let host = document.location.host;
    const url = "ws://" + host  + ctx + "/homepage_endpoint/" + username;
    console.log("Connecting to homepage endpoint with url: " + url);
    ws = new WebSocket(url);

    ws.onmessage = function(event) {
        //Logic to remove message
        console.log("New trip list to load")
        var tripListObject = JSON.parse(event.data);
        console.log(tripListObject);
        console.log(tripListObject.tripList);
        console.log(tripListObject.active)
        updateTripList(ctx, tripListObject.tripList, tripListObject.active);
    };
}