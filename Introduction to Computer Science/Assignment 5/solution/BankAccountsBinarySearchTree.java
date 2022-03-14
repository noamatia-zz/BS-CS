/*---------------------------------------
 Genuine author: <name>, I.D.: <id number>
 Date: xx-xx-2018 
---------------------------------------*/
import java.util.Comparator;
import java.util.Iterator;

public class BankAccountsBinarySearchTree extends BinarySearchTree<BankAccount>{

	public BankAccountsBinarySearchTree(Comparator<BankAccount> myComparator) {
		super(myComparator);
	}
	
	//Complete the following method
	public void balance(){

		List<BankAccount> list = new LinkedList<>();

		BinaryTreeInOrderIterator iter1 = new BinaryTreeInOrderIterator(this.root);
		while (iter1.hasNext()){

			list.add((BankAccount)iter1.next());
		}

		BinaryTreeInOrderIterator iter2 = new BinaryTreeInOrderIterator(this.root);
		while (iter2.hasNext()){

			remove((BankAccount)iter2.next());
		}

		buildBalancedTree(this, list, 0, list.size()-1);

	}
	
	//Complete the following method
	private void buildBalancedTree(BankAccountsBinarySearchTree tree, List<BankAccount> list, int low, int high){

	if (low<=high){
		int Index = (low+high)/2;
		tree.insert(list.get(Index));
		buildBalancedTree(tree, list, Index+1, high);
		buildBalancedTree(tree, list, low, Index-1);
	}

	}

	public Iterator<BankAccount> iterator(){
		return new FilteredBankAccountsIterator(this);
	}
	
}
