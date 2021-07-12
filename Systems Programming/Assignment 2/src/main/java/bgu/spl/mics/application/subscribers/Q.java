package bgu.spl.mics.application.subscribers;
import bgu.spl.mics.MessageBroker;
import bgu.spl.mics.MessageBrokerImpl;
import bgu.spl.mics.Subscriber;
import bgu.spl.mics.application.messages.GadgetAvailableEvent;
import bgu.spl.mics.application.messages.TerminatedTick;
import bgu.spl.mics.application.messages.TickBrodcast;
import bgu.spl.mics.application.passiveObjects.Inventory;

/**
 * Q is the only Subscriber\Publisher that has access to the {@link bgu.spl.mics.application.passiveObjects.Inventory}.
 *
 * You can add private fields and public methods to this class.
 * You MAY change constructor signatures and even add new public constructors.
 */
public class Q extends Subscriber {

	private int time;
	private MessageBroker messageBroker = MessageBrokerImpl.getInstance();
	private Inventory inventory=Inventory.getInstance();

	public Q() {
		super("Q");
		this.time=0;
	}

	@Override
	protected void initialize() {

		this.subscribeBroadcast(TerminatedTick.class,(TerminatedTick b)->{
			this.terminate();
		});


		this.subscribeBroadcast(TickBrodcast.class, (TickBrodcast b) -> {time = b.getNumOfTicks();});

		this.subscribeEvent(GadgetAvailableEvent.class, (GadgetAvailableEvent e)->{
		//	System.out.println(this.getName()+" - take Gadget available event on time: "+time);
			e.setQTime(time);
			if(inventory.getItem(e.getGadget())) {
				messageBroker.complete(e, "success");
			}
			else{
				messageBroker.complete(e , "fail");
		//		System.out.println(this.getName()+" - take Gadget available Event fail");
			}
		});
	}
}
