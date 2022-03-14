import java.util.Iterator;
import java.util.NoSuchElementException;


public class FilteredBankAccountsIterator implements Iterator<BankAccount> {

    private BankAccountsBinarySearchTree bankAccountsTree;
    private BankAccount current;
    private List<BankAccount> list;

    //Complete the following method
    public FilteredBankAccountsIterator(BankAccountsBinarySearchTree bankAccountsTree) {

        bankAccountsTree = bankAccountsTree;
        list=new LinkedList<BankAccount>();

        BinaryTreeInOrderIterator iter = new BinaryTreeInOrderIterator(bankAccountsTree.root);
        if (!bankAccountsTree.isEmpty()) {
            while (iter.hasNext()) {
                BankAccount bankAccount = (BankAccount) iter.next();
                if (bankAccount.getBalance() > 100) list.add(bankAccount);
            }
            current = list.get(0);
        }
        else{
            current=null;
            list=null;
        }
    }

    //Complete the following method
    @Override
    public boolean hasNext() {
       boolean output;
       if (list==null || list.isEmpty()) output=false;
       else output=true;

       return output;
    }

    //Complete the following method
    @Override
    public BankAccount next() {
        if (list==null || list.size()==0 ) throw new NoSuchElementException();
        BankAccount output=current;
        list.remove(0);
        if (!list.isEmpty()) {
            current = list.get(0);
        }
        return output;
    }

    //Do not change this method.
    public void remove() {
        return;
    }
}
