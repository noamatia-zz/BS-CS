package bgu.spl.net.impl.stomp;

import java.util.HashMap;
import java.util.Map;

public class Frame {

    private String command;
    private HashMap <String, String> headers = new HashMap<>();
    private String body;

    public Frame (){}

    public Frame (Frame other){
        command = other.command;
        headers = new HashMap<>(other.headers);
        body = other.body;
    }

    public String getCommand() {
        return command;
    }

    public void setCommand(String command){
        this.command=command;
    }

    public void addHeader(String key, String value){
        headers.put(key, value);
    }

    public String getValue(String key){return headers.get(key);}

    public String getBody(){
        return body;
    }

    public void setBody(String body){
        this.body=body;
    }

    public String toString(){

        String output = command + "\n";

        for (Map.Entry mapElement : headers.entrySet()){
            output = output + mapElement.getKey()+":"+mapElement.getValue()+"\n";
        }

            output = output + "\n" + body + '\0';


        return output;
    }

    public void clear(){
        command="";
        headers.clear();
        body="";
    }
}
