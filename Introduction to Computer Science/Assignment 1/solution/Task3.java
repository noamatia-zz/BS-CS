import java.util.Scanner;

public class Task3 {
	
	public static void main(String[] args) {

            // ----------------- write your code BELOW this line only --------
            // your code here (add lines)
	    Scanner sc = new Scanner(System.in);

        int n = sc.nextInt(); //assume n is a non-negative integer and n>1
        int a = 2; //the first non-trivial divisor
        int counter = 0; //the number of times that some a divided the currently n

        while (a <= n) { //n is the last possible divisor of n
            while (n % a == 0) {
                n = n / a;
                counter = counter + 1;
            }
            if (counter > 1) {
                System.out.println(a + " " + counter);
            }
            if (counter == 1) {
                System.out.println(a);
            }
                a = a + 1;
                counter = 0;
            }
            // ----------------- write your code ABOVE this line only ---------
	}
}
