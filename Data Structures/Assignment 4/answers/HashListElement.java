public class HashListElement {

    private int key;
    private HashListElement next;

    public HashListElement(int key, HashListElement next){
        this.key=key;
        this.next=next;
    }

    public void setNext(HashListElement next){
        this.next=next;
    }

    public HashListElement getNext(){
        return this.next;
    }

    public int getkey(){
        return this.key;
    }
}
