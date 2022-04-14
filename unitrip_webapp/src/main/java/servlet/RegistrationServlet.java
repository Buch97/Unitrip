package servlet;

import com.ericsson.otp.erlang.OtpErlangDecodeException;
import com.ericsson.otp.erlang.OtpErlangExit;
import communication.MessageHandler;
import dto.User;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.Objects;

@WebServlet(name = "RegistrationServlet", value = "/RegistrationServlet")
public class RegistrationServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String targetJSP = "/pages/registration.jsp";
        RequestDispatcher requestDispatcher = request.getRequestDispatcher(targetJSP);
        requestDispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        String confirmRegistration = "";
        try {
            confirmRegistration  = new MessageHandler().register_message(request.getSession(), new User(username, password));
        } catch (OtpErlangDecodeException | OtpErlangExit e) {
            e.printStackTrace();
        }

        if (Objects.equals(confirmRegistration, "ok")) {
            request.getSession().setAttribute("username", username);
            request.getSession().removeAttribute("loginStatus");
            System.out.println("Registration succeded");
            response.sendRedirect(request.getContextPath() + "/LoginServlet");
        } else {
            System.out.println("Registration failed");
            request.getSession().setAttribute("loginStatus", "error");
            RequestDispatcher requestDispatcher = request.getRequestDispatcher("/pages/registration.jsp");
            requestDispatcher.forward(request, response);
        }
    }
}
