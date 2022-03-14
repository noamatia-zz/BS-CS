import java.util.Scanner;

public class Task4a {

    public static void main(String[] args) {

        // ----------------- write your code BELOW this line only --------
        // your code here (add lines)
        Scanner sc = new Scanner(System.in);

        int a = sc.nextInt();
        int b = sc.nextInt();
        int c = sc.nextInt();
        int m = a; //gcd(a,b)
        int n = m; //gcd (m,c) [gcd(a,b,c)=gcd(gcd(a,b),c)]

        while (!(a%m==0 & b%m==0)) {
            m = m-1;
        }

        while (!(m%n==0 & c%n==0)) {
            n = n-1;
        }

        System.out.println(n);
        // ----------------- write your code ABOVE this line only ---------

    }
}

