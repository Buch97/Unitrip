let ws;

function connect(ctx, username) {
    let host = document.location.host;
    const url = "ws://" + host  + ctx + "/homepage_endpoint/" + username;
    console.log("Connecting to homepage endpoint with url: " + url);
    ws = new WebSocket(url);

    ws.onmessage = function(event) {
        console.log("RICEVO MESSAGE BROADCAST")
        var child = document.createElement("span");
        var message = JSON.parse(event.data);
        console.log("TRIP: " + message.name);
        console.log("USER: " + message.user);
        console.log("ACTION: " + message.action)
        var count = document.getElementById("numSeats_" + message.name);
        var list = document.getElementById("myDropdown_" + message.name);
        var child_span = document.getElementById("child_" + message.user);
        if(message.action === 'add') {
            count.innerHTML = (parseInt(count.innerHTML) + 1).toString();
            child.innerHTML = message.user.toString()
            child.setAttribute('id','child_' + message.user)
            list.appendChild(child);
        }
        if(message.action === 'sub') {
            count.innerHTML = (parseInt(count.innerHTML) - 1).toString();
            list.removeChild(child_span)
        }

    };
}

function sendAdd(trip){
    console.log("DENTRO SEND ADD")
    console.log("TRIP NAME: " + trip)
    var json = JSON.stringify({
        "name":trip,
        "action":"add"
    });

    ws.send(json);
}

function sendSub(trip){
    var json = JSON.stringify({
        "name":trip,
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