package bgu.spl.net.srv;


import java.io.IOException;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.LinkedBlockingQueue;

public class ConnectionsImpl<T> implements Connections<T> {

    private static ConnectionsImpl instance=null;
    private ConcurrentHashMap<String, BlockingQueue<Integer>> topicToCid=new ConcurrentHashMap<>();
    private ConcurrentHashMap<Integer, ConnectionHandler<T>> cidToCh=new ConcurrentHashMap<>();
    private ConcurrentHashMap<String, User> userNameToUser=new ConcurrentHashMap<>();
    private ConcurrentHashMap<Integer, User> cidToUser=new ConcurrentHashMap<>();
    private Integer messageId=0;

   // private ConnectionsImpl (){
  //      instance = new ConnectionsImpl();
   // }

   // public static synchronized ConnectionsImpl getInstance(){
  //      if(instance==null)
   //         instance=new ConnectionsImpl();
//
    //    return instance;
  //  }

    @Override
    public boolean send(int connectionId, T msg) {
        if (cidToCh.containsKey(connectionId)){
            cidToCh.get(connectionId).send(msg);
            return true;
        }
        else {
            return false;
        }
    }

    @Override
    public void send(String channel, T msg) {

        BlockingQueue<Integer> cidQ = topicToCid.get(channel);

        if (cidQ!=null) {
            for (Integer id : cidQ) {
                send(id, msg);
            }
        }
    }

    @Override
    public void disconnect(int connectionId) {

        cidToUser.get(connectionId).logout();

        for(String channel : topicToCid.keySet())
            topicToCid.get(channel).remove(connectionId);

        cidToUser.remove(connectionId);

        cidToCh.remove(connectionId);

    }

    public boolean isLogin(String name){return userNameToUser.get(name).isLogin();}

    public boolean userExist(String name) {
        return userNameToUser.containsKey(name);
    }

    public boolean correctPassword(String name, String password){
        return userNameToUser.get(name).getPassword().equals(password);
    }

    public void addUser (String name, String password, int connectionId){
        User newUser = new User(name ,password);
        userNameToUser.put(name, newUser);
        cidToUser.put(connectionId, newUser);
    }

    public void addReturningUser (String name, int connectionId){
        cidToUser.put(connectionId, userNameToUser.get(name));
    }

    public void loginUser(String name){
        userNameToUser.get(name).login();
    }

    public void logoutUser(String name){
        userNameToUser.get(name).logout();
    }

    public void addToChannel(String channel, Integer connectionId, String sid){
        topicToCid.get(channel).add(connectionId);
        cidToUser.get(connectionId).addTopicToSid(channel, sid);
    }

    public void removeFromChannel(String channel, Integer connectionId){
        if(topicToCid.get(channel)!=null) {
            topicToCid.get(channel).remove(connectionId);
        }
    }

    public void incrementMessageId(){
        messageId++;
    }

    public String getMessageId(){
        String output=messageId.toString();
        return output;}

    public boolean containChannel(String topic){
        return topicToCid.containsKey(topic);
    }

    public void addChannel(String topic){
        topicToCid.put(topic, new LinkedBlockingQueue<>());

    }

    public User getUserByCid(Integer cid){
        return cidToUser.get(cid);
    }

    public void addCidToCh (int cid, ConnectionHandler<T> ch){
        cidToCh.put(cid, ch);
        cid++;
    }

    public void terminate (int cid){

        ConnectionHandler<T> ch = cidToCh.get(cid);

        try {
            ch.close();
        }
        catch (IOException e){

        }
    }
}
