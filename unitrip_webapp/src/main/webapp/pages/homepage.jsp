<%@ page import="dto.Trip" %>
<%@ page import="java.util.List" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.FileWriter" %><%--
  Created by IntelliJ IDEA.
  User: pucci
  Date: 07/04/2022
  Time: 10:59
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Incoming trips</title>
</head>
<body>
    <div id="container">
        <div>
            <h3>Available trips</h3>
            <button onclick="window.location.href='./NewTripServlet';">Create new trip!</button>
        </div>
        <div class="p-4 d-flex flex-wrap" id="parent_trip_list">
            <%
                List<Trip> tripList = (List<Trip>) request.getAttribute("tripList");
                if(tripList == null || tripList.size() == 0){
            %>
            <h3>Nothing to Show<h3>
                    <%
                        } else {
                            for(int i=0; i<tripList.size(); i++){
                                Trip trip = tripList.get(i);
                        %>
                <div id="event_trip">
                    <div><%=trip.getDestination()%></div>
                    <div><%=trip.getDate()%></div>
                    <div><%=trip.getSeats()%></div>
                    <div><%=trip.getExpirationDate()%></div>
                    <div><%=trip.getDestination()%></div>
                    <% File myObj = new File("subscriptions.txt");
                       FileWriter myWriter = new FileWriter("subscriptions.txt");
                       for(String user : trip.getParticipants())
                           myWriter.write(user + "\n");
                       myWriter.close();
                    %>
                    <div><a href="<%=myObj%>>" download>Joined users</a></div>
                </div>
                            <%
                            }
                        }
                    %>
            </div>
    </div>

</body>
</html>
