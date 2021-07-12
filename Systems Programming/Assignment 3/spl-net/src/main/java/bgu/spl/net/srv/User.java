package bgu.spl.net.srv;

import java.util.concurrent.ConcurrentHashMap;

public class User {

    private String userName;
    private String password;
    private boolean isLogin;
    private ConcurrentHashMap<String, String> topicToSid;

    public User(String name, String password){
        this.userName=name;
        this.password=password;
        isLogin=true;
        topicToSid = new ConcurrentHashMap<>();
    }

    public void login(){this.isLogin=true;}

    public void logout(){this.isLogin=false;}

    public String getUserName(){return this.userName;}

    public String getPassword(){return this.password;}

    public boolean isLogin(){return this.isLogin;}

    public void addTopicToSid(String topic, String sid){
        topicToSid.put(topic, sid);
    }

    public String getSid(String topic){
        return topicToSid.get(topic);
    }
}
