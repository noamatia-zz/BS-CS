/*---------------------------------------
 Genuine author: <name>, I.D.: <id number>
 Date: xx-xx-2018 
---------------------------------------*/
public class BinaryTree<T> {

    protected BinaryNode<T> root;

    public BinaryTree() {
        root = null;
    }

    public boolean isEmpty() {
        return root == null;
    }

    public void insert(T element) {
        if (isEmpty())
            root = new BinaryNode<T>(element);
        else
            root.insert(element);
    }

    public void remove(T toRemove) {
        if (!isEmpty())
            root = root.remove(toRemove);
    }

    public boolean contains(T element) {
        if (isEmpty())
            return false;
        else
            return root.contains(element);
    }

    public int height() {
        if (isEmpty())
            return -1;
        else
            return root.height();
    }

    public int size() {
        if (isEmpty())
            return 0;
        else
            return root.size();
    }

    public boolean equals(Object other) {
        boolean isEqual;
        if (!(other instanceof BinaryTree<?>))
            isEqual = false;
        else if (isEmpty())
            isEqual = ((BinaryTree<?>) other).isEmpty();
        else
            isEqual = root.equals(((BinaryTree<?>) other).root);
        return isEqual;
    }

    public String toString() {
        if (!isEmpty())
            return root.toString();
        else
            return "Empty Tree";
    }
}

