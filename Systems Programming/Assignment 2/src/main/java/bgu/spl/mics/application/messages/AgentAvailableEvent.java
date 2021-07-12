package bgu.spl.mics.application.messages;

import bgu.spl.mics.Event;
import java.util.List;

public class AgentAvailableEvent implements Event<String> {

    private List<String> serials;
    private int moneypennyId;

    public AgentAvailableEvent (List<String> serials){
        this.serials=serials;
    }

    public List<String> getSerials(){
        return this.serials;
    }

    public int getMoneypennyId(){return this.moneypennyId;}

    public void setMoneypennyId(int serial){this.moneypennyId=serial;}
}
