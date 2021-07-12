package bgu.spl.mics;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import java.util.concurrent.TimeUnit;
import static org.junit.jupiter.api.Assertions.*;

public class FutureTest {

    private Future<String> future1;
    private Future<Integer> future2;
    private Future<Boolean> future3;
    private Future<String> future4;

    @BeforeEach
    public void setUp() {

        try {
            future1 = new Future<String>();
            future2 = new Future<Integer>();
            future3 = new Future<Boolean>();
            future4 = new Future<String>();
        } catch (Exception e) {
            fail("Unexpected exception: ");
        }

    }

    @Test
    public void testGet() throws InterruptedException {
        String test = "test";
        future1.resolve(test);
        String result = future1.get();
        assertEquals(result, test);
    }

    @Test
    public void testResolve() throws InterruptedException {
        Integer test = 23;
        assertFalse(future2.isDone());
        future2.resolve(test);
        assertEquals(future2.get(),test);

    }

    @Test
    public void testIsDone(){
        assertFalse(future3.isDone());
        future3.resolve(true);
        assertTrue(future3.isDone());

    }
    @Test
    public void testGetTime() throws InterruptedException {
    assertFalse(future4.isDone());
    TimeUnit timeUnit = TimeUnit.MILLISECONDS;
    assertNull(future4.get(1000,timeUnit));
    future4.resolve("test");
    assertEquals(future4.get(1000,timeUnit),"test");
    }
}
