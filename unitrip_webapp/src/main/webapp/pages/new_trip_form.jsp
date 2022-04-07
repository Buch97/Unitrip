<%--
  Created by IntelliJ IDEA.
  User: pucci
  Date: 07/04/2022
  Time: 12:52
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <link href="./resources/css/newTrip.css" rel="stylesheet" type="text/css"/>
    <title>New trip</title>
</head>
<body>
<div>
    <h1>Compile this form to create a new Trip</h1>
    <form action="<%=request.getContextPath()%>/HomepageServlet" method="post">
        <ul class="form-style-1">
            <li><label>Destination <span class="required">*</span></label><input type="text" name="field1" class="field-divided" placeholder="city" /> </li>
            <li>
                <label>Contact <span class="required">*</span></label>
                <input type="email" name="field2" class="field-long" />
            </li>
            <li><label>Available seats <span class="required">*</span></label><input type="number" name="field3" class="field-divided" placeholder="0" /> </li>
            <li>
                <label >Trip date <span class="required">*</span></label>
                <input type="date" id="trip_date" name="field4" class="field-divided">
            </li>
            <li>
                <label >Expiration date for subscriptions <span class="required">*</span></label>
                <input type="date" id="sub_date" name="field5" class="field-divided">
            </li>
            <li>
                <label>Description <span class="required">*</span></label>
                <textarea name="field5" id="field6" class="field-long field-textarea"></textarea>
            </li>
            <li>
                <input type="submit" value="Publish" />
            </li>
        </ul>
    </form>
</div>

</body>
</html>
