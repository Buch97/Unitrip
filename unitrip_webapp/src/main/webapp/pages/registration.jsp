<%--
  Created by IntelliJ IDEA.
  User: matteo
  Date: 04/04/22
  Time: 15:21
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <link href="<%=request.getContextPath()%>/resources/css/login.css" rel="stylesheet" type="text/css"/>
</head>

<body>

<div class="wrapper fadeInDown">
    <div id="formContent">
        <!-- Tabs Titles -->
        <h1>Registration Page</h1>
        <h2 class="active"> Sign Up </h2>
        <!-- Login Form -->
        <form action="<%=request.getContextPath()%>/RegistrationServlet" method="post">
            <div>
                <input type="text" class="fadeIn second" name="username" placeholder="Enter username" aria-describedby="username" id="username" required>
            </div>
            <div>
                <input type="password" class="fadeIn third" name="password" placeholder="Enter password" id="password" required>
            </div>
            <input type="submit" class="fadeIn fourth" value="Register">
        </form>
        <div id="formFooter">
            <div class="underlineHover" href="#">Already Registered? Log in <a href="<%=request.getContextPath()%>/LoginServlet">here</a></div>
        </div>
    </div>
</div>
</body>
</html>
