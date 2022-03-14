public class FloorsArrayList implements DynamicSet {

    private int maxNumofLinks;
    private int NumofLinks;
    private int maxArrSize;
    private FloorsArrayLink minusInfy;
    private FloorsArrayLink plusInfy;

    public FloorsArrayList(int N){

        this.maxNumofLinks=N;
        this.NumofLinks=0;
        this.maxArrSize=1;
        this.minusInfy=new FloorsArrayLink(Double.NEGATIVE_INFINITY, N+1);
        this.plusInfy=new FloorsArrayLink(Double.POSITIVE_INFINITY, N+1);

        for (int i=1; i<=N+1; i++){ //connecting between minus and plus Infinity
            this.minusInfy.setNext(i, this.plusInfy);
            this.plusInfy.setPrev(i, this.minusInfy);
        }
    }


    public int getSize(){

        return this.NumofLinks;
    }


    public void insert(double key, int arrSize) {

        this.NumofLinks++; //updating num of links on the list
        if (this.maxArrSize<arrSize) this.maxArrSize=arrSize; //updating maxarrsize if it's necessary
        FloorsArrayLink tmp=this.minusInfy; //starting from minusinfy
        FloorsArrayLink newLink= new FloorsArrayLink(key, arrSize); //the new link we want to insert
        int i=this.maxArrSize; //starting from the maxarrsiae

        while (i>0){ //moving through all the levels
            if (tmp.getNext(i).getKey()<=key){
                tmp=tmp.getNext(i); //moving right
            }
            else {
                if (i<=arrSize){ //updating pointers
                    tmp.setNext(i, newLink);
                    newLink.setPrev(i, tmp);
                }
                i--; //level down
            }

        }

        tmp=this.plusInfy; //starting from plusinfy
        i=this.maxArrSize; //starting from the maxarrsize

        while (i>0){ //moving through all the levels
            if (tmp.getPrev(i).getKey()>=key){
                tmp=tmp.getPrev(i); //moving left
            }
            else {
                if (i<=arrSize){ //updating pointers
                    tmp.setPrev(i, newLink);
                    newLink.setNext(i, tmp);
                }
                i--; //level down
            }
        }
    }


    public void remove(FloorsArrayLink toRemove) {

        this.NumofLinks--; //updating num of links on the list

        if (this.maxArrSize==toRemove.getArrSize()){ //updating maxarrsize if it's necessary
            boolean changed=false;
            for (int i=this.maxArrSize; !changed; i--){
                if (toRemove.getPrev(i)!=this.minusInfy|toRemove.getNext(i)!=this.plusInfy){ //finding if we are on the highest level
                    this.maxArrSize=i; //we are on the highest level
                    changed=true;
                }
                i--; //not the highest level, level down
            }
        }


        for (int i=1; i<=toRemove.getArrSize(); i++){ //updating pointers of the prev and the next
            toRemove.getNext(i).setPrev(i, toRemove.getPrev(i));
            toRemove.getPrev(i).setNext(i, toRemove.getNext(i));
        }
    }


    public FloorsArrayLink lookup(double key) {

        int i = this.maxArrSize; //starting from the maxarrsize
        FloorsArrayLink curr = this.minusInfy; //starting from minus infy

        while (i > 0) { //moving through all the levels until we will find

            if (curr.getKey() == key) return curr; //we found

            else {
                if (curr.getNext(i).getKey() <= key) {
                    curr = curr.getNext(i); //moving right
                }
                else{
                        i--; //moving down
                    }

                }
            }

        return null; //we didnt find
    }


    public double successor(FloorsArrayLink link) {

        return link.getNext(1).getKey(); //connected for sure on the first level
    }


    public double predecessor(FloorsArrayLink link) {

        return link.getPrev(1).getKey(); //connected for sure on the first level
    }


    public double minimum() {

        return successor(this.minusInfy); //the successor of minusinfy
    }


    public double maximum() {

        return predecessor(this.plusInfy); //the predecessor of plusonfy
    }
}
