/*---------------------------------------
 Genuine author: <name>, I.D.: <id number>
 Date: xx-xx-2018 
---------------------------------------*/
public class TestPrimeIterator {

	public static void main(String[] args) {
		PrimeIterator iter = new PrimeIterator();
		for (int i = 1; i < 21; i = i + 1) {
			System.out.print(iter.next()+", ");
		}
	}

}
