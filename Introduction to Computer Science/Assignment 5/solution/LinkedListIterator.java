import java.util.Iterator;
import java.util.NoSuchElementException;

public class LinkedListIterator<T> implements Iterator<T> {
    private Link<T> current;

    public LinkedListIterator(Link<T> start) {
        current = start;
    }

    public boolean hasNext() {
        return current != null;
    }

    public T next() {
        if (!hasNext())
            throw new NoSuchElementException();
        T data = current.getData();
        current = current.getNext();
        return data;
    }

    //DO NOT REMOVE OR CHANGE THIS MEHTOD – IT IS REQUIRED
    public void remove() {
        return;
    }
}