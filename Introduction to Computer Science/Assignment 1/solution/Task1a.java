import java.util.Scanner;

public class Task1a {
	
	public static void main(String[] args) {

            // ----------------- write your code BELOW this line only --------
			// your code here (add lines)
        Scanner sc = new Scanner (System.in);
        int a = sc.nextInt();
        int b = sc.nextInt();
        int c = sc.nextInt();
            if((0<a) & (a<=b) & (b<=c) & (a*a)+(b*b)==c*c)
                          System.out.println("yes");
            else{
                          System.out.println("no");
                }
            // ----------------- write your code ABOVE this line only ---------
		
	}
}
