package bgu.spl.mics.application.publishers;
import bgu.spl.mics.application.messages.TerminatedTick;
import bgu.spl.mics.application.messages.TickBrodcast;
import bgu.spl.mics.Publisher;

/**
 * TimeService is the global system timer There is only one instance of this Publisher.
 * It keeps track of the amount of ticks passed since initialization and notifies
 * all other subscribers about the current time tick using {@link Tick Broadcast}.
 * This class may not hold references for objects which it is not responsible for.
 * 
 * You can add private fields and public methods to this class.
 * You MAY change constructor signatures and even add new public constructors.
 */
public class TimeService extends Publisher {

	private int duration;
	private int currentTick;

	public TimeService(int duration) {
		super("clock");
		this.duration = duration;
		this.currentTick = 0;
	}

	@Override
	protected void initialize() throws InterruptedException {
		Thread.sleep(200);
	}

	@Override
	public void run() {
		try {
			this.initialize();
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		while (currentTick<duration) {
			try {
				this.getSimplePublisher().sendBroadcast(new TickBrodcast(currentTick));
			//	System.out.println("TimeService send tick number: "+currentTick);
			} catch (InterruptedException e) {
			}
			try {
				Thread.sleep(100);
				currentTick++;
			} catch (InterruptedException e) {
			}
		}
		try {
			this.getSimplePublisher().sendBroadcast(new TerminatedTick());
		//	System.out.println("TimeService send TerminatedTick: "+currentTick);
		} catch (InterruptedException e) {
		}
	}
}

