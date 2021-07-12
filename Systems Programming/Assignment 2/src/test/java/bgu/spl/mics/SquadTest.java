package bgu.spl.mics;

import bgu.spl.mics.application.passiveObjects.Agent;
import bgu.spl.mics.application.passiveObjects.Inventory;
import bgu.spl.mics.application.passiveObjects.Squad;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

public class SquadTest {

    Squad squad;
    Agent agent1;
    Agent agent2;
    Agent agent3;
    List<String> s1;
    List<String> s2;

    @BeforeEach
    public void setUp() {
        squad = Squad.getInstance();
        agent1 = new Agent();
        agent1.setName("Tomer");
        agent1.setSerialNumber("001");
        agent1.release();
        agent2 = new Agent();
        agent2.setName("Noam");
        agent2.setSerialNumber("002");
        agent2.release();
        agent3 = new Agent();
        agent3.setName("Ron");
        agent3.setSerialNumber("007");
        agent3.release();
        s1 = new ArrayList<String>();
        s2 = new ArrayList<String>();
        s1.add("007");
        s1.add("002");
        s1.add("001");
        s2.add("Tomer");
        s2.add("Noam");
        s2.add("Ron");
    }

    @Test
    public void testGetInstance(){
        Squad squad2 = Squad.getInstance();
        assertEquals(squad , squad2);
    }

    @Test
    public void testLoad() {

        Agent[] Agent={agent1,agent2,agent3};

        try {
            squad.load(Agent);
        } catch (Exception e){
            fail("Unexpected exception: ");
        }

        assertTrue(squad.getAgents(s1));
    }

    @Test
    public void testReleaseAgents(){

        try {
            squad.releaseAgents(s1);
        } catch (Exception e){
            fail("Unexpected exception: ");
        }
        assertTrue(agent1.isAvailable());
        assertTrue(agent2.isAvailable());
        assertTrue(agent3.isAvailable());
    }

    @Test
    public void testSendAgents() {
    }

    @Test
    public void testGetAgents(){

        squad.releaseAgents(s1);
        assertTrue(squad.getAgents(s1));
        squad.releaseAgents(s1);
        s1.add("003");
        assertFalse(squad.getAgents(s1));
        s1.remove("003");
    }

    @Test
    public void testGetAgentsNames(){
        try {
            List<String> names=squad.getAgentsNames(s1);
            for(int i=0; i<s2.size(); i++){
            assertTrue(names.contains(s2.get(i)));}
        } catch (Exception e){
            fail("Unexpected exception: ");
        }

    }
}
