// You may not change or erase any of the lines and comments 
// in this file. You may only add lines in the designated 
// area.

import java.util.Scanner;

public class Task5 {


    public static void main(String[] args){


        // ----------------- "A": write your code BELOW this line only --------
        // your code here (add lines)
        Scanner sc = new Scanner(System.in);

        int a = sc.nextInt();
        int b = sc.nextInt();
        int c = sc.nextInt();
        int d = sc.nextInt();
        int e = sc.nextInt();
        int n = 0; //n is a temporary variable [a=b,b=a]=>[a=b,b=b]

        if(a>b){
            n=a;
            a=b;
            b=n;
        }
        if(a>c) {
            n = a;
            a = c;
            c = n;
        }
        if(a>d) {
            n = a;
            a = d;
            d = n;
        }
        if(a>e) {
            n = a;
            a = e;
            e = n;
        }
        if(e<d) {
            n = e;
            e = d;
            d = n;
        }
        if(e<c) {
            n = e;
            e = c;
            c = n;
        }
        if(e<b) {
            n = e;
            e = b;
            b = n;
        }

        System.out.println(a);
        System.out.println(e);

        // ----------------- "B" write your code ABOVE this line only ---------



    } // end of main
} //end of class Task5
