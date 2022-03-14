import java.util.Iterator;

public class NumberTester
{
    public static void main(String[] args)
    {
        System.out.println("testNumber() = " + testNumber());
        System.out.println("testIsZero() = " + testIsZero());
        System.out.println("testBitIterator() = " + testBitIterator());
        System.out.println("testIncrement() = " + testIncrement());
        System.out.println("testIsLegal() = " + testIsLegal());
        System.out.println("testEquals() = " + testEquals());
        System.out.println("testToString() = " + testToString());
        System.out.println("testLessEq() = " + testLessEq());
        System.out.println("testLessThan() = " + testLessThan());
        System.out.println("testCompareTo() = " + testCompareTo());
        System.out.println("testAdd() = " + testAdd());
        System.out.println("testMultiply() = " + testMultiply());
    }


    public static boolean testNumber(){
        //we would like to check all the constructors can get the value "0" and big numbers

        Number n2=new Number(0);
        Number n3=new Number("0");
        Number n4=new Number(10);
        Number n5=new Number("20");
        Number n6=new Number(1587546);
        Number n7=new Number("589");
        Number n8=new Number(n7);
        //convert all the Numbers to Strings and compare them to the desirable Strings
        return (n2.toString().equals("0") & n3.toString().equals("0") & n4.toString().equals("1010") & n5.toString().equals("10100") & n6.toString().equals("110000011100101011010") & n7.toString().equals("1001001101") & n8.toString().equals("1001001101"));
    }


    public static boolean testIsZero(){
        Number n2=new Number();
        Number n3=new Number(1);
        Number n4=new Number(10);
        return (n2.isZero() & !n3.isZero() & !n4.isZero());
    }

    public static boolean testBitIterator(){
        Number n = new Number(11);
        Iterator<Bit> iter = n.bitIterator();
        // n is 1011 = we would like to check if the iterator is accurate and stops on the right point
        return (iter.hasNext() & iter.next().isOne() & iter.hasNext() & iter.next().isOne() & iter.hasNext() & iter.next().isZero() & iter.hasNext() & iter.next().isOne() & !iter.hasNext());
    }


    public static boolean testIncrement(){
       Number n1 = new Number();
       n1.increment();
       Number n2 = new Number(1);
       n2.increment();
       Number n3 = new Number(7);
       n3.increment();
       Number n4 = new Number(15);
       n4.increment();
       Number n5 = new Number(177);
       n5.increment();

       return (n1.toString().equals("1") & n2.toString().equals("10") & n3.toString().equals("1000") & n4.toString().equals("10000") & n5.toString().equals("10110010"));
    }


    public static boolean testIsLegal(){
       String str1 = "";
       String str2 = "-55";
       String str3  = "07895";
       String str4 = "&56$";
       String str5 = "0";

       return (!Number.isLegal(str1) & !Number.isLegal(str2) & !Number.isLegal(str3) & !Number.isLegal(str4) & Number.isLegal(str5));
    }


    public static boolean testEquals(){
        Number n1 = new Number();
        Number n2 = new Number(0);
        Number n3 = new Number("0");
        Number n4 = new Number(7);
        Number n5 = new Number(8);

        return (n1.equals(n1) & n1.equals(n2) & n1.equals(n3) & n2.equals(n3) & n3.equals(n2) & !n1.equals(n4) & !n4.equals(n5));
    }

    public static boolean testToString(){
        Number n1 = new Number();
        Number n2 = new Number(8);
        Number n3 = new Number(777);

        return (n1.toString().equals("0") & n2.toString().equals("1000") & n3.toString().equals("1100001001"));
    }


    public static boolean testLessEq(){
        Number n1 = new Number(3);
        Number n2 = new Number(3);
        Number n3 = new Number(14);
        Number n4 = new Number(3);
        Number n5 = new Number();

        return (Number.lessEq(n1, n2) &
                Number.lessEq(n2, n3) &
                !Number.lessEq(n3, n4) &
                Number.lessEq(n5, n3) &
                !Number.lessEq(n3, n5));
    }


    public static boolean testLessThan(){
        Number n1 = new Number(3);
        Number n2 = new Number(3);
        Number n3 = new Number(14);
        Number n4 = new Number(3);
        Number n5 = new Number();

        return (!Number.lessThan(n1, n2) &
                Number.lessThan(n2, n3) &
                !Number.lessThan(n3, n4) &
                Number.lessThan(n5, n3) &
                !Number.lessThan(n3, n5));
    }


    public static boolean testCompareTo(){
        Number n1 = new Number(3);
        Number n2 = new Number(3);
        Number n3 = new Number(7);
        Number n4 = new Number(5);

        return (n1.compareTo(n2)==0 & n2.compareTo(n3)<0 & n3.compareTo(n4)>0);
    }


    public static boolean testAdd(){
        Number n1 = new Number(0);
        Number n2 = new Number(0);
        Number n3 = new Number(5);
        Number n4 = new Number(7);
        Number n5 = new Number(127);
        Number n6 = new Number(789);

        return (Number.add(n1, n2).toString().equals("0") &
                Number.add(n1, n3).toString().equals("101") &
                Number.add(n3, n4).toString().equals("1100") &
                Number.add(n5, n6).toString().equals("1110010100"));
    }

    public static boolean testMultiply(){
        Number n1 = new Number(0);
        Number n2 = new Number(0);
        Number n3 = new Number(5);
        Number n4 = new Number(7);
        Number n5 = new Number(127);
        Number n6 = new Number(789);

        return (Number.multiply(n1, n2).toString().equals("0") &
                Number.multiply(n1, n3).toString().equals("0") &
                Number.multiply(n3, n4).toString().equals("100011") &
                Number.multiply(n5, n6).toString().equals("11000011101101011"));
    }
}
