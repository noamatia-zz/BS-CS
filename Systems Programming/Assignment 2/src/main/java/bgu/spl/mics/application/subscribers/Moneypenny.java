package bgu.spl.mics.application.subscribers;
import java.util.*;
import java.util.Comparator;
import bgu.spl.mics.MessageBroker;
import bgu.spl.mics.MessageBrokerImpl;
import bgu.spl.mics.Subscriber;
import bgu.spl.mics.application.messages.*;
import bgu.spl.mics.application.passiveObjects.Squad;

/**
 * Only this type of Subscriber can access the squad.
 * Three are several Moneypenny-instances - each of them holds a unique serial number that will later be printed on the report.
 *
 * You can add private fields and public methods to this class.
 * You MAY change constructor signatures and even add new public constructors.
 */
public class Moneypenny extends Subscriber {

	private String id;
	private int time;
	private MessageBroker messageBroker = MessageBrokerImpl.getInstance();
	private Squad squad = Squad.getInstance();

	public Moneypenny(String id) {
		super("Moneypenny"+id);
		this.id = id;
		this.time = 0;
	}

	@Override
	protected void initialize() {

		this.subscribeBroadcast(TerminatedTick.class, (TerminatedTick b) -> {

				squad.setFlag();

			squad.releaseAgents(null);
			this.terminate();
		});

		this.subscribeBroadcast(TickBrodcast.class, (TickBrodcast b) -> {time = b.getNumOfTicks();});

		if (Integer.parseInt(this.id) > 0) {

			this.subscribeEvent(AgentAvailableEvent.class, (AgentAvailableEvent e) -> {

		//		System.out.println(this.getName()+" - take Agent available Event on time: "+time);
				e.setMoneypennyId(Integer.parseInt(this.id));
				List<String> list = e.getSerials();
				list.sort((s, t1) -> s.compareTo(t1));

				boolean available = squad.getAgents(list);

				if (!available) {
					messageBroker.complete(e, "fail");
				//	System.out.println(this.getName()+" - take Agent available Event fail");
				}
				else {
					messageBroker.complete(e, "success");
				}
			});
		}

		if (Integer.parseInt(this.id) == 0) {

			this.subscribeEvent(SendAgentEvent.class, (SendAgentEvent e) -> {
				e.setNames(squad.getAgentsNames(e.getSerials()));
			//	System.out.println(this.getName()+" - take Send Agent event on time: "+time);
				squad.sendAgents(e.getSerials(), e.getMissionTimeTime());

				messageBroker.complete(e, "success");
			});

			this.subscribeEvent(ReleaseAgentEvent.class, (ReleaseAgentEvent e) -> {
			//	System.out.println(this.getName()+" - take Release Agent event on time:"+time);
				squad.releaseAgents(e.getSerials());
				messageBroker.complete(e, "success");
			});
		}
	}
}
