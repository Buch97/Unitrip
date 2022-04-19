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

// Close the dropdown menu if the user clicks outside of it
window.onclick = function(event) {
    if (!event.target.matches('.dropbtn')) {
        var dropdowns = document.getElementsByClassName("dropdown-content");
        var i;
        for (i = 0; i < dropdowns.length; i++) {
            var openDropdown = dropdowns[i];
            if (openDropdown.classList.contains('show')) {
                openDropdown.classList.remove('show');
            }
        }
    }
}