package bgu.spl.mics;
import bgu.spl.mics.application.messages.IncreaseTotal;
import bgu.spl.mics.application.messages.MissionReceivedEvent;
import bgu.spl.mics.application.messages.TerminatedTick;
import bgu.spl.mics.application.subscribers.M;
import bgu.spl.mics.application.subscribers.Moneypenny;

import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.LinkedBlockingQueue;

/**
 * The {@link MessageBrokerImpl class is the implementation of the MessageBroker interface.
 * Write your implementation here!
 * Only private fields and methods can be added to this class.
 */
public class MessageBrokerImpl implements MessageBroker {

	private static MessageBrokerImpl instance = null;
	private ConcurrentHashMap<Subscriber , LinkedBlockingQueue<Message>> loop;
	private ConcurrentHashMap<Class , LinkedBlockingQueue<Subscriber>> messageClassToSubscribers;
	private ConcurrentHashMap <Event, Future> activeEvents;

	private MessageBrokerImpl(){
		loop = new ConcurrentHashMap<>();
		messageClassToSubscribers = new ConcurrentHashMap<>();
		activeEvents = new ConcurrentHashMap<>();
	};


	/**
	 * Retrieves the single instance of this class.
	 */
	public synchronized static MessageBroker getInstance() {
		if(instance == null){
			instance = new MessageBrokerImpl();
		}
		return instance;
	}

	@Override
	public <T> void subscribeEvent(Class<? extends Event<T>> type, Subscriber m) {

		if (messageClassToSubscribers.get(type)==null){
			messageClassToSubscribers.put(type, new LinkedBlockingQueue<>());
		}
			messageClassToSubscribers.get(type).add(m);
	}

	@Override
	public void subscribeBroadcast(Class<? extends Broadcast> type, Subscriber m) {

		if (messageClassToSubscribers.get(type)==null){
			messageClassToSubscribers.put(type, new LinkedBlockingQueue<>());
		}
				messageClassToSubscribers.get(type).add(m);
	}

	@Override
	public  <T> void complete(Event<T> e, T result) {
		synchronized (activeEvents.get(e)) {
			activeEvents.get(e).resolve(result);
			activeEvents.get(e).notifyAll();
		}
	}

	@Override
	public void sendBroadcast(Broadcast b) throws InterruptedException {

		if (messageClassToSubscribers.get(b.getClass()) == null) {
			return;
		}

		LinkedBlockingQueue<Subscriber> q = messageClassToSubscribers.get(b.getClass());

		if (b instanceof TerminatedTick) {
			for (Subscriber s : q) {
				synchronized (loop.get(s)) {

					if(!(s instanceof M)) {

						if (s instanceof Moneypenny)
							loop.get(s).add(b);

						else {

							loop.get(s).add(b);
							for (int i = 0; i < loop.get(s).size() - 1; i++) {
								loop.get(s).add(loop.get(s).poll());
							}
						}
					}
					else{
						int counter=0;
						for(Message m: loop.get(s)){
							if(m instanceof MissionReceivedEvent)
								counter++;
						}
						IncreaseTotal e = new IncreaseTotal(counter);
						loop.get(s).add(e);
					loop.get(s).add(b);
						for (int i = 0; i < loop.get(s).size() - 2; i++) {
							loop.get(s).add(loop.get(s).poll());
										}
					}

					loop.get(s).notifyAll();
				}
			}
		}
		else {
			for (Subscriber s : q) {
				synchronized (loop.get(s)) {
					loop.get(s).add(b);
					loop.get(s).notifyAll();
				}
			}
		}
	}

	@Override
	public <T> Future<T> sendEvent(Event<T> e) {



		LinkedBlockingQueue<Subscriber> q = messageClassToSubscribers.get(e.getClass());


		if (q==null || q.isEmpty()) return null;
		Future f = new Future<T>();
		activeEvents.put(e, f);

		Subscriber s = q.poll();

		synchronized (loop.get(s)) {
			loop.get(s).add(e);
			q.add(s);
			loop.get(s).notifyAll();
		}

		return f;

		}

	@Override
	public void register(Subscriber m) {

		if (loop.containsKey(m)) return;

		loop.put(m , new LinkedBlockingQueue<>());
	}

	@Override
	public void unregister(Subscriber m) {

		synchronized (loop.get(m)) {

			loop.remove(m);
		}

		for (LinkedBlockingQueue<Subscriber> q : messageClassToSubscribers.values()){

				q.remove(m);

		}

	}

	@Override
	public Message awaitMessage(Subscriber m) throws InterruptedException {
		if (!loop.containsKey(m)) throw new IllegalStateException("Subscriber is not registered!");
		Message output;
		synchronized (loop.get(m)) {
			while (loop.get(m).isEmpty()) {
				loop.get(m).wait();
			}
			output = loop.get(m).poll();
			loop.get(m).notifyAll();
		}
		return output;
	}

	

}
