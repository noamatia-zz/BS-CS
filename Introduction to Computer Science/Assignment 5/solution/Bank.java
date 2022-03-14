/*---------------------------------------
 Genuine author: <name>, I.D.: <id number>
 Date: xx-xx-2018 
---------------------------------------*/
public class Bank {

	private BankAccountsBinarySearchTree namesTree;
	private BankAccountsBinarySearchTree accountNumbersTree;
	
	public Bank() {
		namesTree = new BankAccountsBinarySearchTree(new AccountComparatorByName());
		accountNumbersTree = new BankAccountsBinarySearchTree(new AccountComparatorByNumber());
	}

	public BankAccount lookUp(String name){
		// create an Entry with the given name, a "dummy" accountNumber (1) and zero balance
		// This "dummy" accountNumber will be ignored when executing getData
		BankAccount lookFor = new BankAccount(name, 1, 0);
		return (BankAccount)namesTree.findData(lookFor);
	}
	
	public BankAccount lookUp(int accountNumber){
		// create an Entry with a "dummy" name, zero balance and the given accountNumber
		// This "dummy" name will be ignored when executing getData
		BankAccount lookFor = new BankAccount("dummy", accountNumber,0);
		return (BankAccount)accountNumbersTree.findData(lookFor);
	}
	
	public void balance(){
		namesTree.balance();
		accountNumbersTree.balance();
	}
	
	public Object exportNames() {
		return this.namesTree;
	}
	public Object exportAccountNumbers() {
		return this.accountNumbersTree;
	}
	
	// END OF Given code -----------------------------------
	
	//Complete the following method
	public boolean add(BankAccount newAccount) {
		boolean output;
		BinaryTreeInOrderIterator iter = new BinaryTreeInOrderIterator(namesTree.root);
		boolean name = false;
		boolean number = false;
		while (iter.hasNext() & !name & !number){
			BankAccount tmp = (BankAccount)iter.next();
			if (tmp.getName().equals(newAccount.getName())) name=true;
			if (tmp.getAccountNumber()==newAccount.getAccountNumber()) number=true;
		}
		if (!name & !number){
			output=true;
			namesTree.insert(newAccount);
			accountNumbersTree.insert(newAccount);
		}
		else output=false;

		return output;
	}

	//Complete the following method
	public boolean delete(String name){
		// this first line is given in the assignment file
		BankAccount toRemove = lookUp(name);
		// complete this:

		boolean output=false;

		BinaryTreeInOrderIterator iter = new BinaryTreeInOrderIterator(namesTree.root);

		while (iter.hasNext() & !output){

			BankAccount tmp = (BankAccount)iter.next();

			if (tmp.getName().equals(name)){
				output = true;
				namesTree.remove(tmp);
				accountNumbersTree.remove(tmp);
			}
		}

		return output;
	}
	
	//Complete the following method
	public boolean delete(int accountNumber){
		// this first line is given in the assignment file
		BankAccount toRemove = lookUp(accountNumber);
		// complete this:

		boolean output=false;

		BinaryTreeInOrderIterator iter = new BinaryTreeInOrderIterator(namesTree.root);

		while (iter.hasNext() & !output){

			BankAccount tmp = (BankAccount)iter.next();

			if (tmp.getAccountNumber()==accountNumber){
				output = true;
				namesTree.remove(tmp);
				accountNumbersTree.remove(tmp);
			}
		}

		return output;
	}

	//Complete the following method
	public boolean depositMoney(int amount, int accountNumber) {
		boolean output;
		BankAccount b = lookUp(accountNumber);
		if (b != null) {
			output = lookUp(accountNumber).depositMoney(amount);

		}
		else output = false;
		return output;
	}

	//Complete the following method
	public boolean withdrawMoney(int amount, int accountNumber){
		boolean output;
		BankAccount b = lookUp(accountNumber);
		if (b != null) {
			output = lookUp(accountNumber).withdrawMoney(amount);

		}
		else output = false;
		return output;
	}
	


}
