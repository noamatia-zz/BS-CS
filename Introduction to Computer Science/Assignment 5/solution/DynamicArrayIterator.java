import java.util.Iterator;
import java.util.NoSuchElementException;

public class DynamicArrayIterator<T> implements Iterator<T> {

    private DynamicArray<T> array;
    private int index;

    public DynamicArrayIterator(DynamicArray<T> array) {
        this(array, 0);
    }

    public DynamicArrayIterator(DynamicArray<T> array, int index) {
        this.array = array;
        this.index = index;
    }

    public boolean hasNext() {
        return index < array.size();
    }

    public T next() {
        if (!hasNext())
            throw new NoSuchElementException();

        T next = array.get(index);
        index = index + 1;
        return next;
    }

    //DO NOT REMOVE OR CHANGE THIS MEHTOD – IT IS REQUIRED
    public void remove() {
        return;
    }
}