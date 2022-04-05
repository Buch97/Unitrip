package servlet;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;

@WebServlet(name = "LoginServlet", value = "/LoginServlet")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        System.out.println("doGet Login");

        // request.getSession().removeAttribute("username");
        // request.getSession().removeAttribute("loginStatus");
        String targetJSP = "/index.jsp";
        RequestDispatcher requestDispatcher = request.getRequestDispatcher(targetJSP);
        requestDispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        System.out.println("DoPost Login");
        System.out.println("username: " + username + "\npassword: " + password);

        boolean isLoginOkay = false;

        /*try {
            isLoginOkay = new CommunicationHandler().performUserLogIn(request.getSession(), new User(username, password));
        } catch (OtpErlangDecodeException | OtpErlangExit e) {
            e.printStackTrace();
        }

        if (isLoginOkay) {
            request.getSession().setAttribute("username", username);
            request.getSession().removeAttribute("loginStatus");
            System.out.println("Sign up succeded");
            response.sendRedirect(request.getContextPath() + "/MainMenuServlet");
        } else {
            System.out.println("Sign in failed");
            request.getSession().setAttribute("loginStatus", "error");
            RequestDispatcher requestDispatcher = request.getRequestDispatcher("/index.jsp");
            requestDispatcher.forward(request, response);
        }*/
    }
}