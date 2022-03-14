/*---------------------------------------
 Genuine author: <name>, I.D.: <id number>
 Date: xx-xx-2018 
---------------------------------------*/

import java.util.Comparator;

public class BinarySearchNode<T> extends BinaryNode<T> {

    protected Comparator<T> comparator;

    public BinarySearchNode(T data, Comparator<T> comparator) {
        super(data);
        this.comparator = comparator;
    }

    // element is an entry with one "dummy" field
    public T findData(T element) {
        if (comparator.compare(data, element) > 0) {
            if (left != null)
                return ((BinarySearchNode<T>) left).findData(element);
            else
                return null;
        } else if (comparator.compare(data, element) < 0) {
            if (right != null)
                return ((BinarySearchNode<T>) right).findData(element);
            else
                return null;
        } else
            return this.data;
    }

    public T findMin() {
        BinaryNode<T> currNode = this;
        while (currNode.left != null) {
            currNode = currNode.left;
        }
        return currNode.data;
    }

    public Comparator<T> getComparator() {
        return comparator;
    }

    public void insert(T toInsert) {
        if (comparator.compare(data, toInsert) > 0) {
            if (left == null)
                left = new BinarySearchNode<T>(toInsert, comparator);
            else
                left.insert(toInsert);
        } else if (comparator.compare(data, toInsert) < 0) {
            if (right == null)
                right = new BinarySearchNode<T>(toInsert, comparator);
            else
                right.insert(toInsert);
        }
    }

    public boolean contains(T element) {
        if (comparator.compare(data, element) == 0)
            return true;
        else if (comparator.compare(data, element) > 0) {
            return (left != null && left.contains(element));
        } else
            return (right != null && right.contains(element));
    }

    public BinaryNode<T> remove(T toRemove) {
        if (comparator.compare(data, toRemove) > 0) {
            if (left != null)
                left = left.remove(toRemove);
        } else if (comparator.compare(data, toRemove) < 0) {
            if (right != null)
                right = right.remove(toRemove);
        } else {//need to remove the data in this node
            if (left == null || right == null) { // the base cases...
                if (left == null)
                    return right;
                else
                    return left;
            } else { // this node has two children
                data = ((BinarySearchNode<T>) right).findMin();
                right = right.remove(data);
            }
        }
        return this;
    }

}


