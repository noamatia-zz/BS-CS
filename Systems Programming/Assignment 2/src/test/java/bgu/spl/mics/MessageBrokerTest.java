package bgu.spl.mics;

import bgu.spl.mics.application.messages.GadgetAvailableEvent;
import bgu.spl.mics.application.messages.AgentAvailableEvent;
import bgu.spl.mics.application.subscribers.Q;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.util.LinkedList;
import java.util.concurrent.TimeUnit;

import static org.junit.jupiter.api.Assertions.*;

public class MessageBrokerTest {

    private MessageBroker messageBroker;
    private Subscriber Q1;
    Class GadgetAvailableEvent;
    private Future<String> future;
    private GadgetAvailableEvent E1;
    private AgentAvailableEvent E2;
    private GadgetAvailableEvent E3;
    private GadgetAvailableEvent E4;
    private GadgetAvailableEvent E5;
    private Message m;

    @BeforeEach
    public void setUp(){
        messageBroker=MessageBrokerImpl.getInstance();
        Q1 = new Q();
        E1 = new GadgetAvailableEvent("");
        E2 = new AgentAvailableEvent(new LinkedList<>());
        E3 = new GadgetAvailableEvent("");
        E4 = new GadgetAvailableEvent("");
        E5 = new GadgetAvailableEvent("");
    }

    @Test
    public void testGetInstance(){
        MessageBroker messageBroker2 = MessageBrokerImpl.getInstance();
        assertEquals(messageBroker , messageBroker2);
    }

    @Test
    public void testSubscribeEvent() throws InterruptedException {
        messageBroker.register(Q1);
        messageBroker.subscribeEvent(GadgetAvailableEvent, Q1);
        future = messageBroker.sendEvent(E1);
        m=messageBroker.awaitMessage(Q1);
        future.get();
        assertTrue(future.isDone());
        future = messageBroker.sendEvent(E2);
        Future<String> future2 = messageBroker.sendEvent(E1);
        m=messageBroker.awaitMessage(Q1);
        future.get(1000, TimeUnit.MILLISECONDS);
        assertFalse(future.isDone());

    }

    @Test
    public void testSubscribeBroadcast(){
    }

    @Test
    public void testComplete(){
        messageBroker.complete(E2,"test");
        assertTrue(future.isDone());
    }

    @Test
    public void testSendBroadcast(){
    }

    @Test
    public void testSendEvent() throws InterruptedException {
        future=messageBroker.sendEvent(E3);
        m=messageBroker.awaitMessage(Q1);
        future.get();
        assertTrue(future.isDone());
    }

    @Test
    public void testRegister(){
    }

    @Test
    public void testUnregister() throws InterruptedException {
        messageBroker.unregister(Q1);
        future = messageBroker.sendEvent(E4);
        assertNull(future);
    }

    @Test
    public void testAwaitMessage() throws InterruptedException {
        messageBroker.register(Q1);
        messageBroker.subscribeEvent(GadgetAvailableEvent, Q1);
        m=messageBroker.awaitMessage(Q1);
        future=messageBroker.sendEvent(E5);
        future.get();
        assertTrue(future.isDone());
    }
}
