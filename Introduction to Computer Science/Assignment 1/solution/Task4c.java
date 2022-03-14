import java.util.Scanner;

public class Task4c {

    public static void main(String[] args) {

        // ----------------- write your code BELOW this line only --------
        // your code here (add lines)
        Scanner sc = new Scanner(System.in);

        int a = sc.nextInt();
        int b = sc.nextInt();
        int c = sc.nextInt();
        int d = sc.nextInt();
        int e = sc.nextInt();
        int f = sc.nextInt();

        if(((a*d*f)+(c*b*f)+(e*b*d))==(b*d*f))//(a/b)+(c/d)+(e/f)=((a*d*f)+(c*b*f)+(e*b*d))/(b*f*f)
            System.out.println("yes");
        else{
            System.out.println("no");
        }

        // ----------------- write your code ABOVE this line only ---------

    }
}
