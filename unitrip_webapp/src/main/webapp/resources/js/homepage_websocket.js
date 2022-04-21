let ws;

function connect(ctx, username) {
    let host = document.location.host;
    const url = "ws://" + host  + ctx + "/homepage_endpoint/" + username;
    console.log("Connecting to homepage endpoint with url: " + url);
    ws = new WebSocket(url);

    ws.onmessage = function(event) {
        console.log("RICEVO MESSAGE BROADCAST")
        const child = document.createElement('span');
        var message = JSON.parse(event.data);
        console.log(message.tripName);
        console.log(message.user);
        var count = document.getElementById("numSeats_" + message.tripName);
        console.log(count.innerHTML)
        var list = document.getElementById("myDropdown_" + message.user);
        if(message.action === 'add') {
            count.value = parseInt(count.text()) + 1;
            child.innerHTML = message.user
            list.append(child);
        }
        if(message.action === 'sub')
            count.value -= 1;

    };
}

function sendAdd(trip){
    console.log("DENTRO SEND ADD")
    console.log("TRIP: "  + trip)
    var json = JSON.stringify({
        "tripName":trip,
        "action":"add"
    });

    ws.send(json);
}

function sendSub(trip){
    var json = JSON.stringify({
        "tripName":trip,
        "action":"sub"
    });

    ws.send(json);
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