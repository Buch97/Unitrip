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

function time_passing(countDownDate, trip){

    setInterval(function() {

        var now = new Date().getTime();
        var timeleft = countDownDate - now;

        var days = Math.floor(timeleft / (1000 * 60 * 60 * 24));
        var hours = Math.floor((timeleft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
        var minutes = Math.floor((timeleft % (1000 * 60 * 60)) / (1000 * 60));
        var seconds = Math.floor((timeleft % (1000 * 60)) / 1000);
        console.log("time" + trip);

        document.getElementById("time" + trip).innerHTML = days + "d " + hours + "h "
            + minutes + "m " + seconds + "s ";

        // If the count down is finished, write some text
        if (distance < 0) {
            clearInterval(x);
            document.getElementById("time" + trip).innerHTML = "EXPIRED";
        }
    }, 1000)
}