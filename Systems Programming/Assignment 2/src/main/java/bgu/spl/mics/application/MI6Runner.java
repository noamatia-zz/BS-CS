package bgu.spl.mics.application;
import bgu.spl.mics.application.passiveObjects.Diary;
import bgu.spl.mics.application.passiveObjects.Inventory;
import bgu.spl.mics.application.passiveObjects.Squad;
import bgu.spl.mics.application.publishers.TimeService;
import bgu.spl.mics.application.subscribers.Intelligence;
import bgu.spl.mics.application.subscribers.M;
import bgu.spl.mics.application.subscribers.Moneypenny;
import bgu.spl.mics.application.subscribers.Q;
import com.google.gson.Gson;
import com.google.gson.stream.JsonReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

/** This is the Main class of the application. You should parse the input file,
 * create the different instances of the objects, and run the system.
 * In the end, you should output serialized objects.
 */
public class MI6Runner {

    public static void main(String[] args) throws IOException, InterruptedException {

        Squad squad = Squad.getInstance();
        Inventory inventory = Inventory.getInstance();
        Diary diary = Diary.getInstance();

        Gson gson = new Gson();
        JsonReader reader = new JsonReader(new FileReader(args[0]));
        Review review = gson.fromJson(reader, Review.class);
        inventory.load(review.inventory);
        squad.load(review.squad);
        List<Runnable> subscribers = new LinkedList<>();
        loadServices(subscribers,review.services);
        List<Thread> execute=new LinkedList<>();



        for(Runnable r:subscribers){
            Thread thread=new Thread(r);
            execute.add(thread); }

        for(Thread thread:execute)
            thread.start();

        for(Thread thread:execute)
            thread.join();


      inventory.printToFile(args[1]);
      diary.printToFile(args[2]);

    }

    public static void loadServices(List<Runnable> subscribers, services services){

        for (int i = 0; i < services.M; i++) {
            subscribers.add(new M(Integer.toString(i)));
        }
        for (int i = 0; i < services.Moneypenny; i++) {
            subscribers.add(new Moneypenny(Integer.toString(i)));
        }
        for (int i = 0; i < services.intelligence.length; i++) {
            Intelligence intelligence = new Intelligence(Integer.toString(i),services.intelligence[i].missions);
            subscribers.add(intelligence);
        }
        TimeService timeService = new TimeService(services.time);
        subscribers.add(timeService);
        subscribers.add(new Q());
    }
}
