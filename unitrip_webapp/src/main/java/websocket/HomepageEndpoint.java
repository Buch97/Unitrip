package websocket;

import dto.Message;
import dto.Message;
import dto.TripList;

import javax.websocket.*;
import javax.websocket.server.PathParam;
import javax.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Set;
import java.util.concurrent.CopyOnWriteArraySet;

@ServerEndpoint(value="/homepage_endpoint/{username}", decoders = HomepageDecoder.class, encoders = HomepageEncoder.class)
public class HomepageEndpoint {

    private static final Set<HomepageEndpoint> homeEndpoints = new CopyOnWriteArraySet<>();
    private Session session;
    private static final HashMap<String, String> users = new HashMap<String, String>();

    @OnOpen
    public void onOpen(Session session, @PathParam("username") String username) {
        // Metodo eseguito all'apertura della connessione
        System.out.println("[MAIN MENU ENDPOINT] OnOpen");
        this.session = session;
        homeEndpoints.add(this);
        users.put(session.getId(), username);
    }

    @OnMessage
    public void onMessage(Session session, @PathParam("username") String username, Message message) throws EncodeException, IOException {
        // Metodo eseguito alla ricezione di un messaggio
        // La stringa 'message' rappresenta il messaggio
        // Il valore di ritorno di questo metodo sara' automaticamente
        // inviato come risposta al client. Ad esempio:
        System.out.println("[MAIN MENU ENDPOINT] OnMessage");
        System.out.println("[MAIN MENU ENDPOINT] Trip list is going to be broadcast");
        System.out.println("MESSAGE RECEIVED BY WS: " + message.getName());
        message.setUser(username);
        broadcast(message);
    }

    @OnClose
    public void onClose(Session session) {
        // Metodo eseguito alla chiusura della connessione
        System.out.println("[MAIN MENU ENDPOINT] OnClose: " + users.get(session.getId()) + " is exiting");
        homeEndpoints.remove(this);
        users.remove(session.getId());
    }

    @OnError
    public void onError(Throwable exception, Session session) {
        // Metodo eseguito in caso di errore
    }

    private static void broadcast(Message message) throws IOException, EncodeException {

        homeEndpoints.forEach(endpoint -> {
            synchronized (endpoint) {
                try {
                    endpoint.session.getBasicRemote().
                            sendObject(message);
                } catch (IOException | EncodeException e) {
                    e.printStackTrace();
                }
            }
        });
    }
}
