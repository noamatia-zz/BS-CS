package bgu.spl.mics.application.subscribers;
import bgu.spl.mics.*;
import bgu.spl.mics.application.messages.*;
import bgu.spl.mics.application.passiveObjects.Diary;
import bgu.spl.mics.application.passiveObjects.Report;

/**
 * M handles ReadyEvent - fills a report and sends agents to mission.
 *
 * You can add private fields and public methods to this class.
 * You MAY change constructor signatures and even add new public constructors.
 */
public class M extends Subscriber {

	private String id;
	private int time;
	private MessageBroker messageBroker = MessageBrokerImpl.getInstance();
	private Diary diary = Diary.getInstance();

	public M(String id) {
		super("M"+id);
		this.id = id;
		this.time=0;
	}

	@Override
	protected void initialize() {

		this.subscribeBroadcast(TerminatedTick.class,(TerminatedTick b)->{
			this.terminate();});

		this.subscribeBroadcast(TickBrodcast.class, (TickBrodcast b)->{
			time=b.getNumOfTicks();});

		this.subscribeBroadcast(IncreaseTotal.class, (IncreaseTotal b)->{
			for (int i=1; i<=b.getCounter(); i++)
				diary.incrementTotal();
		});

		this.subscribeEvent(MissionReceivedEvent.class, (MissionReceivedEvent e)->{

				//	System.out.println(this.getName()+" ----------- take "+ e.getInfo().getMissionName()+" on time: "+time+"----------");

					diary.incrementTotal();
					AgentAvailableEvent agentAvailableEvent = new AgentAvailableEvent(e.getInfo().getSerialAgentsNumbers());
					Future<String> f1 =this.getSimplePublisher().sendEvent(agentAvailableEvent);

					while(f1!=null && !f1.isDone())
						synchronized (f1){f1.wait();}

					if(f1!=null && f1.get()=="success") {
				//		System.out.println(e.getInfo().getMissionName());
						GadgetAvailableEvent gadgetAvailableEvent = new GadgetAvailableEvent(e.getInfo().getGadget());
						Future<String> f2 = this.getSimplePublisher().sendEvent(gadgetAvailableEvent);


						if ((f2!=null && f2.get() == "success") & this.time <= e.getInfo().getTimeExpired()) {
							
							SendAgentEvent sendAgentEvent = new SendAgentEvent(e.getInfo().getSerialAgentsNumbers());
							sendAgentEvent.setMissionTime(e.getInfo().getDuration());
							this.getSimplePublisher().sendEvent(sendAgentEvent);
							messageBroker.complete(e, "success");
							loadReport(e, gadgetAvailableEvent, agentAvailableEvent, sendAgentEvent);
				//			System.out.println(e.getInfo().getMissionName()+"--------Success--------"+"on time: "+time);
						} else {

							if (f1.get() != "fail" | f2==null) {
								ReleaseAgentEvent releaseAgentEvent = new ReleaseAgentEvent(e.getInfo().getSerialAgentsNumbers());
								this.getSimplePublisher().sendEvent(releaseAgentEvent);
							}
							messageBroker.complete(e, "fail");
/*
							if(f2!=null&&f2.get()=="fail")
							System.out.println(e.getInfo().getMissionName()+"-------Fail---------"+"on time: "+time+"because gadget: "+e.getInfo().getGadget()+" is not available");

							if(f1!=null&&f1.get()=="fail")
								System.out.println(e.getInfo().getMissionName()+"-------Fail---------"+"on time: "+time+"because an agent is not exist");

							if(this.time>e.getInfo().getTimeExpired())
								System.out.println(e.getInfo().getMissionName()+"-------Fail---------"+"on time: "+time+"because time expired");

							if (f2==null)
								System.out.println(e.getInfo().getMissionName()+"-------Fail---------"+"on time: "+time+"because there is no Q");

							if (f1==null)
							System.out.println(e.getInfo().getMissionName()+"-------Fail---------"+"on time: "+time+"because there is no moneypenny");
				*/		}
					}
					else{
						messageBroker.complete(e, "fail");

					}
				}
				);
	}

	private void loadReport(MissionReceivedEvent e , GadgetAvailableEvent g , AgentAvailableEvent a , SendAgentEvent s){

		Report report = new Report();
		report.setMissionName(e.getInfo().getMissionName());
		report.setGadgetName(e.getInfo().getGadget());
		report.setM(Integer.parseInt(this.id));
		report.setTimeIssued(e.getInfo().getTimeIssued());
		report.setQTime(g.getQTime());
		report.setTimeCreated(this.time);
		report.setMoneypenny(a.getMoneypennyId());
		report.setAgentsSerialNumbers(e.getInfo().getSerialAgentsNumbers());
		report.setAgentsNames(s.getNames());

		diary.addReport(report);
	}
}
