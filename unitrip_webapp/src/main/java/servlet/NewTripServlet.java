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
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Date;
import java.util.Locale;
import java.util.Objects;
import java.util.TimeZone;

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
        String name = request.getParameter("trip_name");
        String founder = (String) request.getSession().getAttribute("username");
        System.out.println("Founder: " + founder);
        int seats = Integer.parseInt(request.getParameter("seats"));
        String success = "";
        DateTimeFormatter format = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        try {
            SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd");
            Date date = formatter.parse(request.getParameter("date"));
            System.out.println("Data in millis: " + date.getTime());
            success  = new MessageHandler().create_trip(request.getSession(), name, destination, date.getTime(), founder, seats);
            System.out.println("RIUSCITA");
        } catch (OtpErlangDecodeException | OtpErlangExit | ParseException e) {
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
}
