<%@ page import="dto.Trip" %>
<%@ page import="java.util.List" %>
<%@ page import="java.io.File" %>
<%@ page import="java.io.FileWriter" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="dto.TripList" %><%--
  Created by IntelliJ IDEA.
  User: pucci
  Date: 07/04/2022
  Time: 10:59
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no" />
    <meta name="description" content="" />
    <meta name="author" content="" />
    <title>Homepage</title>
    <!-- Favicon-->
    <link rel="icon" type="image/x-icon" href="assets/favicon.ico" />
    <!-- Bootstrap icons-->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.5.0/font/bootstrap-icons.css" rel="stylesheet" />
    <!-- Core theme CSS (includes Bootstrap)-->
    <link href="./resources/css/homepage.css" rel="stylesheet" />

</head>
<body>

<nav class="navbar navbar-expand-lg navbar-light bg-light">
    <div class="container px-4 px-lg-5">
        <div style="font-size:20pt" class="navbar-brand" ><%=request.getSession().getAttribute("username")%> | <a href="<%=request.getContextPath()%>/LoginServlet" style="font-size:20pt">Logout</a></div>
        <a style="margin-left:10em; font-size:25pt" class="navbar-brand" >Incoming trips</a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation"><span class="navbar-toggler-icon"></span></button>
        <div class="collapse navbar-collapse" id="navbarSupportedContent">
            <div style="margin-left:15em" class="d-flex">
                <button onclick="window.location.href='./NewTripServlet';" class="btn btn-outline-dark" >Create new trip</button>
            </div>
        </div>
    </div>
</nav>
<!-- Section-->
<section class="py-5">
    <div class="container px-4 px-lg-5 mt-5">
        <div class="row gx-4 gx-lg-5 row-cols-2 row-cols-md-3 row-cols-xl-4 justify-content-center">
            <%
                TripList tripList = (TripList) request.getAttribute("tripList");
                if(tripList == null || tripList.getTrips().size() == 0){
            %>
            <h3>Nothing to Show<h3>
                    <%
                        } else {
                            for(int i=0; i< tripList.getTrips().size(); i++){
                                Trip trip = tripList.getTrips().get(i);
                    %>
            <div style="width:30%; height:20%" class="col mb-5">
                <div class="card h-100">
                    <div class="card-body p-4">
                        <div class="text-center">
                            <h1 class="fw-bolder"><%= trip.getDestination()%>></h1>
                            <h3><%=trip.getDate()%>></h3>
                            <h3>Founder: <%=trip.getFounder()%>></h3>
                            <h3>From: Bologna</h3>
                            <h3>Seats: <%=trip.getParticipants().size()%>/<%=trip.getSeats()%>></h3>
                            <% File myObj = new File("subscriptions.txt");
                                FileWriter myWriter = new FileWriter("subscriptions.txt");
                                for(String user : trip.getParticipants())
                                    myWriter.write(user + "\n");
                                myWriter.close();
                            %>
                            <h3><a href="<%=myObj%>" download>Participants</a></h3>
                            <h3>Remaining time: 08:27:35</h3>
                        </div>
                        <div class="text-center">
                            <form method="post" action="<%=request.getContextPath()%>/HomepageServlet">
                                <input type="hidden" name="trip" value="<%=trip.getId()%>">
                                <input type="hidden" name="username" value="<%=request.getSession().getAttribute("username")%>">
                                <% if(!trip.getParticipants().contains(request.getAttribute("username"))){%>
                                <button style="font-size:17pt" name="joinButton" class="btn btn-outline-dark mt-auto" type="submit">JOIN TRIP</button>
                                <%  } else {%>
                                <button style="font-size:17pt" name="leaveButton" class="btn btn-outline-dark mt-auto" type="submit">LEAVE TRIP</button>
                                <% } %>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
                            <%
                            }
                        }
                    %>
        </div>
    </div>
</section>
<!-- Footer-->
<footer class="py-5 bg-dark">
    <div class="container"><p class="m-0 text-center text-white">UniTrip</p></div>
</footer>
<!-- Bootstrap core JS-->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
<!-- Core theme JS-->
<script src="js/scripts.js"></script>
</body>
</html>
