package bgu.spl.mics.application.passiveObjects;
import java.util.*;

/**
 * Passive data-object representing a information about an agent in MI6.
 * You must not alter any of the given public methods of this class. 
 * <p>
 * You may add ONLY private fields and methods to this class.
 */
public class Squad {

	private static Squad instance = null;
	private Map<String, Agent> agents;
	private boolean flag=false;

	private Squad(){agents=new HashMap<>();}

	/**
	 * Retrieves the single instance of this class.
	 */
	public synchronized static Squad getInstance() {
		if(instance == null){
			instance = new Squad();
		}
		return instance;
	}

	/**
	 * Initializes the squad. This method adds all the agents to the squad.
	 * <p>
	 * @param agents 	Data structure containing all data necessary for initialization
	 * 						of the squad.
	 */
	public void load (Agent[] agents) {
		for (Agent agent : agents){
			this.agents.put(agent.getSerialNumber(), agent);
		}
	}

	/**
	 * Releases agents.
	 */
	public void releaseAgents(List<String> serials){
		synchronized(this.agents) {
			if(serials==null){
				for (Agent agent: agents.values()){
					agent.release();
				}
			}
			else {
				for (String serial : serials) {
					this.agents.get(serial).release();
				//	System.out.println("Agent: " + agents.get(serial).getSerialNumber() + " released");
				}
			}

			this.agents.notifyAll();
		}
	}


	/**
	 * simulates executing a mission by calling sleep.
	 * @param time   time ticks to sleep
	 */
	public void sendAgents(List<String> serials, int time) {
		try {
			Thread.currentThread().sleep(time*100);
		//	System.out.println("Agents: "+serials+" on mission");
		} catch (Exception e) {}
		releaseAgents(serials);
	}

	/**
	 * acquires an agent, i.e. holds the agent until the caller is done with it
	 * @param serials   the serial numbers of the agents
	 * @return ‘false’ if an agent of serialNumber ‘serial’ is missing, and ‘true’ otherwise
	 */
	public synchronized boolean getAgents(List<String> serials) {

		if(flag) return false;

		for (String serial : serials) {

			if (!(this.agents.containsKey(serial))) {
				return false;
			}
		}

		for (String serial : serials) {

			while (!(this.agents.get(serial).isAvailable())) {
				try {
					this.agents.wait();
				//	System.out.println("A moneypenny is waiting for agent: "+serial);
				} catch (Exception e) {
				}
			}
			this.agents.get(serial).acquire();
			//System.out.println("A moneypenny catch agent: "+serial);
		}
		return true;
	}

    /**
     * gets the agents names
     * @param serials the serial numbers of the agents
     * @return a list of the names of the agents with the specified serials.
     */
    public List<String> getAgentsNames(List<String> serials){

        List<String> agentsNames = new ArrayList<String>();

        for (String serial : serials){
        	agentsNames.add(this.agents.get(serial).getName());
		}

        return agentsNames;

    }

	public void setFlag() {
		this.flag = true;
	}
}
