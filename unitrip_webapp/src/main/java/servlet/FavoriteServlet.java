package servlet;

import com.ericsson.otp.erlang.OtpErlangDecodeException;
import com.ericsson.otp.erlang.OtpErlangException;
import com.ericsson.otp.erlang.OtpErlangExit;
import com.ericsson.otp.erlang.OtpErlangRangeException;
import communication.MessageHandler;
import dto.Trip;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.Objects;

@WebServlet(name = "FavoriteServlet", value = "/FavoriteServlet")
public class FavoriteServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        ArrayList<Trip> tripListFavs = null;
        try { //recupero la lista dei trip attivi e la setto nella sessione
            tripListFavs = new MessageHandler().get_favourite_trips(request.getSession(), request.getSession().getAttribute("username").toString());
            //System.out.println(tripListFavs.get(0).getDestination());
            request.setAttribute("tripListFavs", tripListFavs);
            request.getSession().setAttribute("tripListFavs", tripListFavs);
        } catch (ParseException | OtpErlangException e) {
            e.printStackTrace();
        }
        String targetJSP = "/pages/favourites.jsp";
        RequestDispatcher requestDispatcher = request.getRequestDispatcher(targetJSP);
        requestDispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String username = request.getParameter("username").trim();
        String trip_name = request.getParameter("trip_name").trim();
        String success = "";
        if (request.getParameter("likeButton") != null) {
            try {
                System.out.println("CHIAMO ADD FAVORITE");
                success = new MessageHandler().add_favorite(request.getSession(), username, trip_name);
                System.out.println("Ritorno funzione add_favs");
            } catch (OtpErlangDecodeException | OtpErlangExit e) {
                e.printStackTrace();
            }
        } else if (request.getParameter("dislikeButton") != null) {
            try {
                success = new MessageHandler().delete_favorite(request.getSession(), username, trip_name);
                //System.out.println("Ritorno funzione add_part");
            } catch (OtpErlangDecodeException | OtpErlangExit e) {
                e.printStackTrace();
            }
        }

        if(Objects.equals(success, "ok")) {
            response.sendRedirect(request.getContextPath() + "/FavoriteServlet");
        }
        else {
            System.out.println("Something went wrong");
            String targetJSP = "/pages/favourites.jsp";
            RequestDispatcher requestDispatcher = request.getRequestDispatcher(targetJSP);
            requestDispatcher.forward(request, response);
        }
    }
}
