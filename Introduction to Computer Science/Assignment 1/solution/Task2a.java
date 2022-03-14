import java.util.Scanner;

public class Task2a {

    public static void main(String[] args) {

        // ----------------- write your code BELOW this line only --------
		// your code here (add lines)

        Scanner sc = new Scanner (System.in);

        int n = sc.nextInt(); //assume "n" is a non-negative integer
        int m = 1; //multipication

        if(n==0)

            System.out.println("1"); //0!=1

        else{

            for (int a = 1; a<=n; a = a+1)
				
            m = m*a;
				
            System.out.println(m);
        }
		// ----------------- write your code ABOVE this line only ---------
    }
}