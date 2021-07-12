package bgu.spl.net.impl.stomp;

import bgu.spl.net.srv.Connections;
import bgu.spl.net.srv.ConnectionsImpl;
import bgu.spl.net.srv.User;
import bgu.spl.net.api.StompMessagingProtocol;

public class StompMessagingProtocolImpl implements StompMessagingProtocol<Frame>{

    private int connectionId;
    private ConnectionsImpl connections;
    private boolean shouldTerminate = false;

    @Override
    public void start(int connectionId, Connections connections) {
        this.connectionId = connectionId;
        this.connections = (ConnectionsImpl) connections;
    }

    @Override
    public void process(Frame message) {

        String command=message.getCommand();

        switch (command) {
            case "CONNECT":
                handleConnect(message);
                break;

            case "SUBSCRIBE":
                handleSubscribe(message);
                break;

            case "UNSUBSCRIBE":
                handleUnsubscribe(message);
                break;

            case "SEND":
                handleSend(message);
                break;

            case "DISCONNECT":
                handleDisconnect(message);
                break;
        }
    }

    @Override
    public boolean shouldTerminate() {
        return shouldTerminate;
    }

    public Frame createErrorFrame(String body){

        Frame output = new Frame();
        output.setCommand("ERROR");
        output.setBody(body);

        return output;
    }

    public Frame createConnectedFrame(String body){

        Frame output = new Frame();
        output.setCommand("CONNECTED");
        output.setBody(body);

        return output;
    }

    public Frame createReceiptFrame(String receiptId){

        Frame output = new Frame();
        output.setCommand("RECEIPT");
        output.addHeader("receipt-id", receiptId);

        return output;
    }

    public Frame createMessageFrame(String destination, String body){

        Frame output = new Frame();
        output.setCommand("MESSAGE");
        User user = connections.getUserByCid(connectionId);
        output.addHeader("subscription", user.getSid(destination));
        output.addHeader("Message-id", connections.getMessageId());
        connections.incrementMessageId();
        output.addHeader("destination", destination);
        output.setBody(body);

        return output;
    }

    public void handleConnect(Frame message){

        String name= message.getValue("login");
        String password= message.getValue("passcode");

        if(connections.getUserByCid(connectionId)!= null && connections.getUserByCid(connectionId).isLogin()){
            connections.send(connectionId , createErrorFrame("Client already active"));
            if(connections.getUserByCid(connectionId)!=null && connections.getUserByCid(connectionId).getUserName()==name) {
                connections.logoutUser(name);
            }
            shouldTerminate=true;
            connections.disconnect(connectionId);
        }

        else{

        if(connections.userExist(name)) {
            if (connections.isLogin(name)){
                connections.send(connectionId , createErrorFrame("User already logged in"));
                if(connections.getUserByCid(connectionId)!=null && connections.getUserByCid(connectionId).getUserName()==name) {
                    connections.logoutUser(name);
                    connections.disconnect(connectionId);
                }
               // connections.disconnect(connectionId);
               // connections.terminate(connectionId);
                shouldTerminate=true;
            }
            else if (!connections.correctPassword(name, password)){
                connections.send(connectionId , createErrorFrame("Wrong password"));
               // connections.disconnect(connectionId);
                //connections.terminate(connectionId);
                shouldTerminate=true;
            }
            else{
                connections.addReturningUser(name ,connectionId);
                connections.loginUser(name);
                connections.send(connectionId, createConnectedFrame("Login successful"));
            }
        }

        else{
            connections.addUser(name, password, connectionId);
            connections.send(connectionId, createConnectedFrame("Login successful"));
            //System.out.println("new user login!");
        }
        }

    }

    public void handleSubscribe(Frame message){

        String destination = message.getValue("destination");
        String subscriptionId = message.getValue("id");
        String receiptId = message.getValue("receipt");

        if (!connections.containChannel(destination)){
            connections.addChannel(destination);
        }
        connections.addToChannel(destination, connectionId, subscriptionId);
        connections.send(connectionId, createReceiptFrame(receiptId));

    }

    public void handleUnsubscribe(Frame message){

        String destination = message.getValue("destination");
        //String subscriptionId = message.getValue("id");
        String receiptId = message.getValue("receipt");

        connections.removeFromChannel(destination, connectionId);
        connections.send(connectionId, createReceiptFrame(receiptId));

    }

    public void handleSend(Frame message){

        String destination= message.getValue("destination");
       //String receiptId = message.getValue("receipt-id");
        String body = message.getBody();
        connections.send(destination, createMessageFrame(destination, body));

    }

    public void handleDisconnect(Frame message){
        shouldTerminate=true;
        String receiptId = message.getValue("receipt");
        connections.send(connectionId, createReceiptFrame(receiptId));
        connections.disconnect(connectionId);
    }
}
