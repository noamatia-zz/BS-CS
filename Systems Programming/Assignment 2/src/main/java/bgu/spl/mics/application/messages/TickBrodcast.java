package bgu.spl.mics.application.messages;

import bgu.spl.mics.Broadcast;

public class TickBrodcast implements Broadcast{

    int numOfTicks;

    public TickBrodcast (int numOfTicks){
        this.numOfTicks=numOfTicks;
    }

    public int getNumOfTicks() {return numOfTicks;}
}
