public class FloorsArrayLink {

    private double key;
    private int arrSize;
    private FloorsArrayLink [] prev;
    private FloorsArrayLink [] next;

    public FloorsArrayLink(double key, int arrSize){

        this.key=key;
        this.arrSize=arrSize;
        this.prev=new FloorsArrayLink[arrSize];
        this.next=new FloorsArrayLink[arrSize];
    }

    public double getKey() {
        return this.key;
    }

    public FloorsArrayLink getNext(int i) {

        if (i>this.arrSize) return null;

        return this.next[i-1];
    }

    public FloorsArrayLink getPrev(int i) {

        if (i>this.arrSize) return null;

        return this.prev[i-1];
    }

    public void setNext(int i, FloorsArrayLink next) {

        if (i<=this.arrSize & i>0) this.next[i-1]=next;
    }

    public void setPrev(int i, FloorsArrayLink prev) {

        if (i<=this.arrSize & i>0) this.prev[i-1]=prev;
    }

    public int getArrSize(){

        return this.arrSize;

    }
}

