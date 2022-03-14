/*---------------------------------------
 Genuine author: <name>, I.D.: <id number>
 Date: xx-xx-2018 
---------------------------------------*/
import java.util.Comparator;

public class AccountComparatorByName implements Comparator<BankAccount>{

	@Override
	//Complete the following method
	public int compare(BankAccount account1, BankAccount account2) {

		int output = 0;
		String Name1=account1.getName();
		String Name2=account2.getName();
		int size1=Name1.length();
		int size2=Name2.length();
		boolean found=false;

		for (int i=0; i<size1 & i<size2 & !found; i=i+1 )
			if (Name2.charAt(i)!=Name1.charAt(i)){
				output = Name1.charAt(i) - Name2.charAt(i);
				found =true;
			}
			if (!found) output = size1-size2;
	
		return output;
	}

}
