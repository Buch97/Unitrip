package servlet;

import com.ericsson.otp.erlang.*;
import communication.MessageHandler;
import dto.Trip;
import dto.TripList;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.text.ParseException;
import java.util.ArrayList;

@WebServlet(name = "HomepageServlet", value = "/HomepageServlet")
public class HomepageServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //ce da aggiungerci la sessione e la richiesta dei trip attivi
        ArrayList<Trip> tripList;
        try { //recupero la lista dei trip attivi e la setto nella sessione
            tripList = new MessageHandler().get_active_trips(request.getSession());
            //System.out.println(tripList.get(0).getDestination());
            request.setAttribute("tripList", tripList);
            request.getSession().setAttribute("tripList", tripList);
        } catch (OtpErlangDecodeException | OtpErlangExit | OtpErlangRangeException | ParseException e) {
            e.printStackTrace();
        }
        String targetJSP = "/pages/homepage.jsp";
        RequestDispatcher requestDispatcher = request.getRequestDispatcher(targetJSP);
        requestDispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {

        String username = request.getParameter("username");
        String pid = "#Pid<" + request.getParameter("pid") + ">";
        if(request.getParameter("joinButton") != null) {
            String success = "";
            try {
                success = new MessageHandler().add_participant(request.getSession(), username, pid);
            } catch (OtpErlangDecodeException | OtpErlangExit e) {
                e.printStackTrace();
            }
        }
        else if(request.getParameter("leaveButton") != null){
            String success = "";
            try {
                success = new MessageHandler().remove_participant(request.getSession(), username, pid);
            } catch (OtpErlangDecodeException | OtpErlangExit e) {
                e.printStackTrace();
            }
        }
            String targetJSP = "/pages/homepage.jsp";
            RequestDispatcher requestDispatcher = request.getRequestDispatcher(targetJSP);
            requestDispatcher.forward(request, response);

    }
}
