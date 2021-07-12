package bgu.spl.mics.application.messages;

import bgu.spl.mics.Event;

import java.util.List;


public class SendAgentEvent implements Event<String> {

    private int missionTime;
    private List<String> serials;
    private List<String> names;

    public SendAgentEvent (List<String> serials){
        this.serials=serials;
    }

    public List<String> getSerials(){ return this.serials; }

    public int getMissionTimeTime(){return this.missionTime;}

    public void setMissionTime(int time){this.missionTime = time;}

    public void setNames(List<String> names){this.names=names;}

    public List<String> getNames(){ return this.names; }
}
