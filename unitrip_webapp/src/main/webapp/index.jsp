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
    <link href="./resources/css/login.css" rel="stylesheet" type="text/css"/>
</head>

<body>
<h1>Login Page</h1>
<div class="wrapper fadeInDown">
    <div id="formContent">
        <!-- Tabs Titles -->
        <h2 class="active"> Sign In </h2>
        <h2 class="inactive underlineHover">Sign Up </h2>

        <!-- Icon -->
        <div class="fadeIn first">
            <img src="http://danielzawadzki.com/codepen/01/icon.svg" id="icon" alt="User Icon"/>
        </div>

        <!-- Login Form -->
        <form action="<%=request.getContextPath()%>/LoginServlet" method="post">
            <div>
                <input type="text" class="fadeIn second" name="username" placeholder="Enter username" aria-describedby="username" id="username" required>
            </div>
            <div>
                <input type="password" class="fadeIn third" name="password" placeholder="Enter password" id="password" required>
            </div>
            <input type="submit" class="fadeIn fourth" value="Log In">
        </form>

        <!-- Remind Password -->
        <div id="formFooter">
            <a class="underlineHover" href="#">Forgot Password?</a>
        </div>

    </div>
</div>
</body>
</html>
