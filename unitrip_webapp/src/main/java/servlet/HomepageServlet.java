package servlet;

import com.ericsson.otp.erlang.OtpErlangDecodeException;
import com.ericsson.otp.erlang.OtpErlangExit;
import com.ericsson.otp.erlang.OtpErlangRangeException;
import communication.MessageHandler;
import dto.TripList;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.util.ArrayList;

@WebServlet(name = "HomepageServlet", value = "/HomepageServlet")
public class HomepageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //ce da aggiungerci la sessione e la richiesta dei trip attivi
        TripList tripList;
        try {
            tripList = new MessageHandler().get_active_trips(request.getSession());
            request.setAttribute("triplist", tripList);
            request.getSession().setAttribute("tripList", tripList);
        } catch (OtpErlangDecodeException | OtpErlangExit | OtpErlangRangeException e) {
            e.printStackTrace();
        }
        String targetJSP = "/pages/homepage.jsp";
        RequestDispatcher requestDispatcher = request.getRequestDispatcher(targetJSP);
        requestDispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String username = request.getParameter("username");
        int trip = Integer.parseInt(request.getParameter("trip"));
        String success="";
        try {
            success = new MessageHandler().add_participant(request.getSession(), username, trip);
        } catch (OtpErlangDecodeException | OtpErlangExit e) {
            e.printStackTrace();
        }
        String targetJSP = "/pages/homepage.jsp";
        RequestDispatcher requestDispatcher = request.getRequestDispatcher(targetJSP);
        requestDispatcher.forward(request, response);
    }
}
