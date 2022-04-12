package servlet;

import com.ericsson.otp.erlang.OtpErlangDecodeException;
import com.ericsson.otp.erlang.OtpErlangExit;
import communication.MessageHandler;
import dto.Trip;
import dto.User;

import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.annotation.*;
import java.io.IOException;
import java.time.Instant;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Date;
import java.util.Objects;

@WebServlet(name = "NewTripServlet", value = "/NewTripServlet")
public class NewTripServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String targetJSP = "/pages/new_trip_form.jsp";
        RequestDispatcher requestDispatcher = request.getRequestDispatcher(targetJSP);
        requestDispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        //azione post sul form del trip
        String destination = request.getParameter("destination");
        String founder = request.getParameter("founder");
        int seats = Integer.parseInt(request.getParameter("seats"));

        DateTimeFormatter format = DateTimeFormatter.ofPattern("d MMMM, yyyy");
        String success = "";
        try {
            LocalDate date = getDateFromString(request.getParameter("date"), format);
            System.out.println(date);
            success  = new MessageHandler().create_trip(request.getSession(), new Trip(destination, date, founder, seats));
        } catch (OtpErlangDecodeException | OtpErlangExit e) {
            e.printStackTrace();
        }
        catch (IllegalArgumentException | DateTimeParseException e) {
            System.out.println("Exception: " + e);
        }

        if (Objects.equals(success, "ok")) {
            response.sendRedirect(request.getContextPath() + "/HomepageServlet");
        } else {
            RequestDispatcher requestDispatcher = request.getRequestDispatcher("/pages/new_trip_form.jsp");
            requestDispatcher.forward(request, response);
        }
    }

    public static LocalDate getDateFromString(String string, DateTimeFormatter format){
        LocalDate dateTime = LocalDate.parse(string, format);
        return dateTime;
    }
}
