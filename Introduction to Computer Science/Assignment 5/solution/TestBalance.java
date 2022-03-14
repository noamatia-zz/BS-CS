/*---------------------------------------
 Genuine author: <name>, I.D.: <id number>
 Date: xx-xx-2018
---------------------------------------*/

import java.util.Comparator;

public class TestBalance {

    public static void main(String[] args) {
        Comparator<BankAccount> c = new AccountComparatorByNumber();

        BankAccountsBinarySearchTree t1 = new BankAccountsBinarySearchTree(c);
        t1.insert(new BankAccount("a", 4, 0));
        t1.insert(new BankAccount("b", 2, 0));
        t1.insert(new BankAccount("c", 6, 0));
        t1.insert(new BankAccount("d", 1, 0));
        t1.insert(new BankAccount("f", 3, 0));
        t1.insert(new BankAccount("g", 5, 0));
        t1.insert(new BankAccount("h", 7, 0));
        t1.insert(new BankAccount("i", 8, 0));
        System.out.println("----------unbalanced t1:----------\n" + t1);
        t1.balance();
        System.out.println("\n----------balanced t1:----------\n" + t1 + "\n\n");

        BankAccountsBinarySearchTree t2 = new BankAccountsBinarySearchTree(c);
        t2.insert(new BankAccount("a", 5, 0));
        t2.insert(new BankAccount("a", 2, 0));
        t2.insert(new BankAccount("a", 6, 0));
        t2.insert(new BankAccount("a", 1, 0));
        t2.insert(new BankAccount("a", 4, 0));
        t2.insert(new BankAccount("a", 7, 0));
        t2.insert(new BankAccount("a", 3, 0));
        t2.insert(new BankAccount("a", 8, 0));
        System.out.println("----------unbalanced t2:----------\n" + t2);
        t2.balance();
        System.out.println("\n----------balanced t2:----------\n" + t2 + "\n\n");
        BankAccountsBinarySearchTree t3 = new BankAccountsBinarySearchTree(c);
        t3.insert(new BankAccount("a", 2, 0));
        t3.insert(new BankAccount("a", 1, 0));
        t3.insert(new BankAccount("a", 3, 0));
        t3.insert(new BankAccount("a", 4, 0));
        t3.insert(new BankAccount("a", 5, 0));
        t3.insert(new BankAccount("a", 6, 0));
        t3.insert(new BankAccount("a", 7, 0));
        t3.insert(new BankAccount("a", 8, 0));
        System.out.println("----------unbalanced t3:----------\n" + t3);
        t3.balance();
        System.out.println("\n----------balanced t3:----------\n" + t3 + "\n\n");

        BankAccountsBinarySearchTree t4 = new BankAccountsBinarySearchTree(c);
        t4.insert(new BankAccount("a", 8, 0));
        t4.insert(new BankAccount("a", 7, 0));
        t4.insert(new BankAccount("a", 6, 0));
        t4.insert(new BankAccount("a", 5, 0));
        t4.insert(new BankAccount("a", 4, 0));
        t4.insert(new BankAccount("a", 3, 0));
        t4.insert(new BankAccount("a", 2, 0));
        t4.insert(new BankAccount("a", 1, 0));
        System.out.println("----------unbalanced t4:----------\n" + t4);
        t4.balance();
        System.out.println("\n----------balanced t4:----------\n" + t4 + "\n\n");

    }
}
