import java.util.Scanner;

public class Task1b {

    public static void main(String[] args) {

        // ----------------- write your code BELOW this line only --------
		// your code here (add lines)

        Scanner sc = new Scanner (System.in);

        int n = sc.nextInt();
		
		//assume "n" is a non-negative integer
		//3 4 5 is the smallest Pythagorean triple
		//https://en.wikipedia.org/wiki/Pythagorean_triple

        for (int c = 5; c<=n; c = c+1) {

            for (int b = 4; b<=c; b = b+1) {

                for (int a = 3; a<=b; a = a+1) {

                    if(a*a+b*b==c*c)
                        System.out.println(a + " " + b + " " + c);
                }
            }
        }
		
		// ----------------- write your code ABOVE this line only ---------
    }
}
