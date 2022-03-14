// You may not change or erase any of the lines and comments 
// in this file. You may only add lines.

import java.util.Scanner;

public class Task6 {


    public static void main(String[] args){


            // ----------------- write any code BELOW this line only --------
            // your code here (add lines)
		boolean test = true;
        int a = 0;
        int b = 0;
        int c = 0;
        int d = 0;
        int e = 0;
        for (int A=0; A<=1; A=A+1){
            for (int B=0; B<=1; B=B+1){
                for (int C=0; C<=1; C=C+1){
                    for (int D=0; D<=1; D=D+1){
                        for (int E=0; E<=1; E=E+1){
                            a=A;
                            b=B;
                            c=C;
                            d=D;
                            e=E;
                            //Intermediate variables so the conditional switch will not affect the "for loops"
            // ----------------- write any code ABOVE this line only ---------




            // -----------------  copy here the code from Task 5 that is between
            // -----------------  the comments "A" and "B"
            // code from Task 5 here
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
            // -----------------  end of copied code from Task 5




            // ----------------- write any code BELOW this line only --------
            // your code here (add lines)
			 if ((e<a)|(e<b)|(e<c)|(e<d)|(b<a)|(c<a)|(d<a)){
                                a=2;
                                b=2;
                                c=2;
                                d=2;
                                e=2;
                                System.out.println(a + " " + b + " " + c + " " + d + " " + e);
                                test=false;
                            }
                        }
                    }
                }
            }
        }
        if (test==true)
            System.out.println("verified");
            // ----------------- write any code ABOVE this line only ---------

    } // end of main
} //end of class Task6

