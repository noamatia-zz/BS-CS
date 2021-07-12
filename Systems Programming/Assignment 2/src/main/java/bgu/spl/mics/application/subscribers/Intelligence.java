package bgu.spl.mics.application.subscribers;
import bgu.spl.mics.application.messages.MissionReceivedEvent;
import bgu.spl.mics.application.messages.TerminatedTick;
import bgu.spl.mics.application.messages.TickBrodcast;
import bgu.spl.mics.application.passiveObjects.MissionInfo;
import bgu.spl.mics.Subscriber;
import java.util.Comparator;
import java.util.concurrent.PriorityBlockingQueue;

/**
 * A Publisher\Subscriber.
 * Holds a list of Info objects and sends them
 *
 * You can add private fields and public methods to this class.
 * You MAY change constructor signatures and even add new public constructors.
 */
public class Intelligence extends Subscriber {

	public static class comparatorByTimeIssued<T extends MissionInfo> implements Comparator<MissionInfo>{
		public int compare(MissionInfo m1, MissionInfo m2) {
			return m1.getTimeIssued()-m2.getTimeIssued();
		}
	}

	private PriorityBlockingQueue <MissionInfo> missionInfoHeap;
	private String id;

	public Intelligence(String id,MissionInfo[] missions) {
		super("intelligence"+id);
		this.id=id;
		missionInfoHeap = new PriorityBlockingQueue(missions.length , new comparatorByTimeIssued<>());
		for(MissionInfo m: missions){
			missionInfoHeap.put(m);
		}
	}

	@Override
	protected void initialize() {

		this.subscribeBroadcast(TerminatedTick.class,(TerminatedTick b)->{
			this.terminate();
		});

		this.subscribeBroadcast(TickBrodcast.class, (TickBrodcast b)->{
			while (!missionInfoHeap.isEmpty() && missionInfoHeap.peek().getTimeIssued()==(b).getNumOfTicks()){
				MissionReceivedEvent missionReceivedEvent = new MissionReceivedEvent(missionInfoHeap.poll());
				this.getSimplePublisher().sendEvent(missionReceivedEvent);
			//	System.out.println(this.getName()+" send "+missionReceivedEvent.getInfo().getMissionName()+
			//	" on time: "+b.getNumOfTicks());
			}
		});
	}
}
