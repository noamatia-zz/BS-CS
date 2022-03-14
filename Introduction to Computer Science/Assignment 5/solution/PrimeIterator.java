/*---------------------------------------
 Genuine author: <name>, I.D.: <id number>
 Date: xx-xx-2018 
---------------------------------------*/
import java.util.Iterator;

public class PrimeIterator implements Iterator<Integer> {

    private List<Integer> primes;

    public PrimeIterator(){
        //each time we initialize a PrimeIterator we initialize "primes" as a new LinkedList and add the first prime "2"
        this.primes=new LinkedList<Integer>();
        primes.add(2);
    }

    public boolean hasNext(){
        //there is always a next prime
    	return true;
    }

    public Integer next(){
        //the next prime, before we return it we have to add to our "primes" the next prime after it
        Integer output = primes.get(primes.size()-1);
        boolean valid=false;
        //we gonna run on all the next numbers until we find the next prime and valid will become "true"
        for (int NextPrime=output+1; !valid; NextPrime=NextPrime+1){
            boolean isPrime=true;
            //on the next loop we will rely on the fact that not prime number is a multiple of at least
            //one of the primes that smaller from his root
            for(int primesIndex = 0; primesIndex<primes.size() &&
                    primes.get(primesIndex)*primes.get(primesIndex)<= NextPrime &
                                isPrime;
                    primesIndex = primesIndex + 1){
                    if (NextPrime%primes.get(primesIndex) == 0) {
                        isPrime = false;
                    }
                }

                if(isPrime) {
                    primes.add(NextPrime);
                    valid=true;
                }
            }
        return output;
    }
	
	//DO NOT REMOVE OR CHANGE THIS MEHTOD – IT IS REQUIRED 
	public void remove() {
		return;
	}
}
