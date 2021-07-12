package bgu.spl.mics.application.messages;

import bgu.spl.mics.Event;
import java.util.List;

public class ReleaseAgentEvent implements Event<String> {

    private List<String> serials;

    public ReleaseAgentEvent (List<String> serials){
        this.serials=serials;
    }

    public List<String> getSerials(){ return this.serials; }

}
