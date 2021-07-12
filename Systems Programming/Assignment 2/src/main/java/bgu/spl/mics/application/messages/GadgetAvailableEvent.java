package bgu.spl.mics.application.messages;

import bgu.spl.mics.Event;
import java.util.List;

public class GadgetAvailableEvent implements Event<String> {

    String gadget;
    private int Qtime=0;

    public GadgetAvailableEvent (String gadget){
        this.gadget=gadget;
    }

    public String getGadget(){
        return this.gadget;
    }

    public void setQTime(int time){this.Qtime=time;}

    public int getQTime(){return this.Qtime;}
}
