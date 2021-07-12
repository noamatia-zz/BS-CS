package bgu.spl.mics.application.messages;

import bgu.spl.mics.Broadcast;

public class IncreaseTotal implements Broadcast{

    int counter;

    public IncreaseTotal (int counter){
        this.counter=counter;
    }

    public int getCounter() {return counter;}
}
