import java.util.Scanner;

public class Task2b {

    public static void main(String[] args) {

        // ----------------- write your code BELOW this line only --------
		// your code here (add lines)

        Scanner sc = new Scanner(System.in);

        int n = sc.nextInt(); //assume n is a non-negative integer
        int k = sc.nextInt(); //assume k is a non-negative integer and k>1
        int t = 1;

        if (n % k == 0)

           System.out.println("0"); //n%k=0 ==> n!%k=0

        else {

            if (n == 0)

                System.out.println("1"); //n=0 ==> n!=1 ==> n!%k=1

            else {

                while (n >= 1) { //n is a non-negative integer. We "run" from n to 1 (*)

                    if (n % k != 0) { //if [n, n-1, n-2 ... 1]%k=0 ==> It does not affect the remainder of the division

                        if (t > k) { //n*(n-1)*(n-2)*...*1 has to be bigger than k!

                            t = t % k;
                        }

                        t = t * n; //n!%k = n%k*(n-1)%k*(n-2)%k*...*1%k = r1*r2*...*rn , as long as r != 0
                        n = n - 1; //(*)

                    }
                }

                System.out.println(t % k);

            }
        }
        // ----------------- write your code ABOVE this line only ---------
    }
}