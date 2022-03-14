import java.util.Comparator;

public class TestToString {

	public static void main(String[] args) {
		Comparator<Integer> c = new IntegerComparator();

		BinarySearchTree t1 = new BinarySearchTree(c);
		t1.insert(4);
		t1.insert(2);
		t1.insert(6);
		t1.insert(1);
		t1.insert(3);
		t1.insert(5);
		t1.insert(7);
		t1.insert(8);
		System.out.println("----------t1:----------\n" + t1);

		BinarySearchTree t2 = new BinarySearchTree(c);
		t2.insert(5);
		t2.insert(2);
		t2.insert(6);
		t2.insert(1);
		t2.insert(4);
		t2.insert(7);
		t2.insert(3);
       	t2.insert(8);
		System.out.println("----------t2:----------\n" + t2);

		BinarySearchTree t3 = new BinarySearchTree(c);
		t3.insert(2);
		t3.insert(1);
		t3.insert(3);
		t3.insert(4);
		t3.insert(5);
		t3.insert(6);
		t3.insert(7);
		t3.insert(8);
		System.out.println("----------t3:----------\n" + t3);

		BinarySearchTree t4 = new BinarySearchTree(c);
		t4.insert(8);
		t4.insert(7);
		t4.insert(6);
		t4.insert(5);
		t4.insert(4);
		t4.insert(3);
		t4.insert(2);
		t4.insert(1);
		System.out.println("----------t4:----------\n" + t4);
	}
}
