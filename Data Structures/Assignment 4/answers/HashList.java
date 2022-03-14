public class HashList {

    private HashListElement first;

    public HashList(HashListElement first){
        this.first=first;
    }

    public void insert (HashListElement element){
        element.setNext(this.first);
        this.first=element;
    }

    public HashListElement GetFirst(){
        return this.first;
    }
}
