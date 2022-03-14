import java.util.Scanner;

public class Task4b {

    public static void main(String[] args) {

        // ----------------- write your code BELOW this line only --------
        // your code here (add lines)
        Scanner sc = new Scanner(System.in);

        int a = sc.nextInt();
        int b = sc.nextInt();
        int c = sc.nextInt();
        int m = a; //gcd(a,b)

        while (!(a%m==0 & b%m==0)) {
            m = m-1;
        }
        int t = a*b/m; //lcm(a,b)
        int n = c; //gcd (t,c)
		
        while (!(t%n==0 & c%n==0)) {
            n = n-1;
        }
        int s = (t*c)/n; //lcm(t,c) [lcm(a,b,c)=lcm(lcm(a,b),c)

        System.out.println(s);
        // ----------------- write your code ABOVE this line only ---------
    }
}