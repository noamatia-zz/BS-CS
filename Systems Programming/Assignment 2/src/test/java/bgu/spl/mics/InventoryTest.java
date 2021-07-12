package bgu.spl.mics;

import bgu.spl.mics.application.passiveObjects.Inventory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class InventoryTest {

    Inventory inventory;
    String gadget1;
    String gadget2;
    String gadget3;
    String gadget4;
    String gadget5;
    String[] s1;
    String[] s2;

    @BeforeEach
    public void setUp(){
     inventory = Inventory.getInstance();
     gadget1 = "a";
     gadget2 = "b";
     gadget3 = "c";
     gadget4 = "d";
     gadget5 = "e";
     s1 = new String[]{gadget1 , gadget2 , gadget3};
     s2 = new String[]{gadget1};
    }

    @Test
    public void testGetInstance(){
        Inventory inventory2 = Inventory.getInstance();
        assertEquals(inventory , inventory2);
    }

    @Test
    public void testLoad(){
        try {
            inventory.load(s1);
        } catch (Exception e){
            fail("Unexpected exception: ");
        }
        assertTrue(inventory.getItem(gadget1));
        assertTrue(inventory.getItem(gadget2));
        assertTrue(inventory.getItem(gadget3));
    }

    @Test
    public void testGetItem(){
        assertFalse(inventory.getItem(gadget1));
        inventory.load(s2);
        assertTrue(inventory.getItem(gadget1));
        assertFalse(inventory.getItem(gadget1));
    }

    @Test
    public void testPrintToFile(){
    }
}
