package servlet;

import com.ericsson.otp.erlang.OtpErlangDecodeException;
import com.ericsson.otp.erlang.OtpErlangExit;
import communication.MessageHandler;
import dto.User;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.Objects;

@WebServlet(name = "LoginServlet", value = "/LoginServlet")
public class LoginServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
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

        String allowLogin = "";
        try {
            allowLogin  = new MessageHandler().login_message(request.getSession(), new User(username, password));
        } catch (OtpErlangDecodeException | OtpErlangExit e) {
            e.printStackTrace();
        }

        if (Objects.equals(allowLogin, "ok")) {
            request.getSession().setAttribute("username", username);
            //request.getSession().removeAttribute("loginStatus");
            response.sendRedirect(request.getContextPath() + "/HomepageServlet");
        } else {
            System.out.println("Login failed");
            //request.getSession().setAttribute("loginStatus", "error");
            RequestDispatcher requestDispatcher = request.getRequestDispatcher("/index.jsp");
            requestDispatcher.forward(request, response);
        }
    }
}