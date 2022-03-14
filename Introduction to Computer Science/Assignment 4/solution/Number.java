import java.util.Iterator;

public class Number implements Comparable<Number> {
    private static final int BASE = 2;
    private static final Number ZERO = new Number();
    private static final Number ONE = new Number(1);
    private List<Bit> list;

    /**
     * Constructs a new Number defaulted to the value zero.
     */
    public Number() {
        list = new LinkedList<Bit>();
        list.add(new Bit(false));
    }

    /**
     * Constructs a new Number from an int.
     *
     * @param number an int representing a decimal number
     */
    public Number(int number) {  // assignment #1
        if (number < 0) throw new IllegalArgumentException("Invalid input: a negative number"); //only positive values!
        list = new LinkedList<Bit>();
        if (number == 0) list.add(new Bit(false)); //like the first constructor
        while (number > 0) {
            int tmp = number % 2;
            if (tmp == 1) list.add(new Bit(true));
            else list.add(new Bit(false));
            number = number / 2;
            //the formula to convert decimal number to binary number = divide by 2 until zero and keep the remainers
        }
    }

    /**
     * Constructs a new Number from a String.
     *
     * @param s a String (possibly) representing a decimal number.
     */
    public Number(String s) {    // assignment #2
        list = new LinkedList<Bit>();
        int value = 0;
        int base = 1;
        if (s.length() == 0)
            throw new IllegalArgumentException("Invalid input: not a number on base 10"); //empty string not accepted
        if (s.length() > 1 & s.charAt(0) == '0')
            throw new IllegalArgumentException("Invalid input: not a number on base 10"); //first char can't be zero!
        for (int i = s.length() - 1; i >= 0; i = i - 1) {
            if (!(s.charAt(i) >= '0' & s.charAt(i) <= '9'))
                throw new IllegalArgumentException("Invalid input: not a number on base 10"); //only 0-9 digits
            value = base * (s.charAt(i) - '0') + value;
            base = base * 10;
        } //convert string to int
        if (value == 0) list.add(new Bit(false)); //like the first constructor
        while (value > 0) {
            int tmp = value % 2;
            if (tmp == 1) list.add(new Bit(true));
            else list.add(new Bit(false));
            value = value / 2;
        }//the formula to convert decimal number to binary number
    }

    /**
     * Constructs a new Number which is a deep copy of the provided Number.
     *
     * @param number a Number to be copied
     */
    public Number(Number number) { // assignment #3
        list = new LinkedList<Bit>();
        for (int i = 0; i <= number.list.size() - 1; i = i + 1) {
            list.add(number.list.get(i));
        }
    }

    /**
     * Checks if this Number is zero.
     *
     * @return true if and only if this object representing the number zero.
     */
    public boolean isZero() { // assignment #4
        boolean output;
        if (this.list.size() == 1 & this.list.get(0).isZero()) output = true;
        else output = false;
        return output;
    }


    /**
     * Returns an iterator over the Bit objects in the representation of this number,
     * which iterates over the Bit objects from LSB (first) to MSB (last).
     *
     * @return a LSB-first iterator over the Bit objects in the representation of this number.
     */
    public Iterator<Bit> bitIterator() { // assignment #5
        return list.iterator();
    }


    /**
     * Adds 1 to the number
     */
    public void increment() { // assignment #6
        boolean changed = false; //if Number changed once it enough
        boolean changed2 = false;
        int Ind;
        if (this.list.size() == 1 & this.list.get(0).isOne()) { //special case when Number = 1; we just have to add zero
            this.list.add(0, new Bit(false));
            changed = true;
        }
        for (int i = 0; i < this.list.size() & !changed; i = i + 1) { //the first 0 we catch supposed to become 1
            if (this.list.get(i).isZero()) {
                this.list.set(i, new Bit(true));
                changed = true;
                for (int j = 0; j < i; j = j + 1) { //all the digits before the first zero we catched and changed to 1 suposed to become zero!
                    this.list.set(j, new Bit(false));
                }
            }
        }

        if (!changed) { //it means all the digits are 1 and number isn't 1; we have to change all the digits without the first one to zero and add one more zero
            for (int i = 0; i < this.list.size() - 1; i = i + 1) {
                this.list.set(i, new Bit(false));
            }
            this.list.add(0, new Bit(false));
        }
    }


    /**
     * Checks if a provided String represent a legal decimal number.
     *
     * @param s a String that possibly represents a decimal number, whose legality to be checked.
     * @return true if and only if the provided String is a legal decimal number
     */
    public static boolean isLegal(String s) { // assignment #7
        boolean output = true;
        if (s.length() == 0) output = false; //empty string is invalid
        else {
            if (s.length() > 1 & s.charAt(0) == '0') output = false; //first char 0 is invalid
            for (int i = s.length() - 1; i >= 0 & output; i = i - 1) { //only chars 0-9
                if (!(s.charAt(i) >= '0' & s.charAt(i) <= '9'))
                    output = false;

            }
        }
        return output;
    }


    /**
     * Compares the specified object with this Number for equality.
     * Returns true if and only if the specified object is also a
     * Number (object) which represents the same number.
     *
     * @param obj he object to be compared for equality with this Number
     * @return true if and only if the specified object is equal to this object
     */
    public boolean equals(Object obj) { // assignment #8
        boolean output = true;
        if (!(obj instanceof Number)) output = false; //inputs can be objects; only Numbers allowed!
        else {
            if (((Number) obj).list.size() != this.list.size())
                output = false; //before we run on the digits, only numbers with the same size can be equal
            else {
                for (int i = 0; i < this.list.size() & output; i = i + 1) //let's compare the Bits of both Numbers one by one
                    if (!this.list.get(i).equals(((Number) obj).list.get(i))) {
                        output = false;
                    }
            }
        }
        return output;
    }


    /**
     * Returns a string representation of this Number
     * as a binary number.
     *
     * @return a string representation of this Number
     */
    public String toString() { // assignment #9
        Iterator<Bit> iter = this.bitIterator();
        String str = "";
        String output = "";
        while (iter.hasNext()) { //getting the reversed binary number
            str = str + iter.next();
        }
        for (int i = str.length() - 1; i >= 0; i = i - 1) { //reverse to get the original binary number
            output = output + str.charAt(i);
        }
        return output;
    }


    /**
     * Compares the two provided numbers, and returns true if
     * the first parameter is less than or equal to the second
     * parameter, as numbers.
     *
     * @param num1 the first number to compare
     * @param num2 the second number to compare
     * @return true if and only if the first number is less than
     * or equal to the second parameter, as numbers.
     */
    public static boolean lessEq(Number num1, Number num2) { // assignment #10

        if (num1 == null | num2 == null) throw new IllegalArgumentException("Invalid input");

        boolean output = true;

        Iterator<Bit> iter1 = num1.bitIterator();
        Iterator<Bit> iter2 = num2.bitIterator();

        Bit a = new Bit();
        Bit b = new Bit();

        while (iter1.hasNext() & iter2.hasNext()) { //we don't have to run on all the Bits of both Numbers.
            a = iter1.next();
            b = iter2.next();
            if (!(a.equals(b))) //if the value on the same index is equal, it doesnt affect the output
                output = a.lessThan(b); //the out put is determined by the last not equal value
        }
        if (iter1.hasNext()) output = false; //num1 is longer so of course bigger
        else {
            if (iter2.hasNext()) output = true; //num2 is longer so of course bigger
        }
        return output;
    }


    /**
     * Compares the two provided numbers, and returns true if
     * the first parameter is strictly less than the second
     * parameter, as numbers.
     *
     * @param num1 the first number to compare
     * @param num2 the second number to compare
     * @return true if and only if the first number is strictly
     * less than the second parameter, as numbers.
     */
    public static boolean lessThan(Number num1, Number num2) { // assignment #11
        boolean output = false; //exactly like lessEq but if they are equals the output will not change to true

        Iterator<Bit> iter1 = num1.bitIterator();
        Iterator<Bit> iter2 = num2.bitIterator();

        Bit a = new Bit();
        Bit b = new Bit();

        while (iter1.hasNext() & iter2.hasNext()) { //we don't have to run on all the Bits of both Numbers.
            a = iter1.next();
            b = iter2.next();
            if (!(a.equals(b))) //if the value on the same index is equal, it doesnt affect the output
                output = a.lessThan(b); //the out put is determined by the last not equal value
        }
        if (iter1.hasNext()) output = false; //num1 is longer so of course bigger
        else {
            if (iter2.hasNext()) output = true; //num2 is longer so of course bigger
        }
        return output;
    }


    /**
     * Compares this object with the specified object for order.  Returns a
     * negative integer, zero, or a positive integer as this object is less
     * than, equal to, or greater than the specified object.
     *
     * @param o the object to be compared.
     * @return a negative integer, zero, or a positive integer as this object
     * is less than, equal to, or greater than the specified object.
     */
    @Override
    public int compareTo(Number o) { // assignment #12
        if (o == null) throw new IllegalArgumentException("Invalid input");
        int output;
        if (lessThan(this, o)) output = -1;
        else {
            if (this.equals(o)) output = 0;
            else output = 1; //if it's not less than and not equals it's bigger!
        }
        return output;
    }


    /**
     * Adds the specified Number objects, and returns their sum.
     *
     * @param num1 the first addend
     * @param num2 the second addend
     * @return the sum of the specified Number objects.
     */
    public static Number add(Number num1, Number num2) { // assignment #13

        if (num1 == null | num2 == null) throw new IllegalArgumentException("Invalid input");

        Iterator<Bit> iter1 = num1.bitIterator();
        Iterator<Bit> iter2 = num2.bitIterator();
        Number output = new Number();
        output.list.remove(new Bit(false)); //we dont need the zero that added by the empty constructor!
        Bit cin = new Bit(false);
        while (iter1.hasNext() & iter2.hasNext()) {
            Bit a = iter1.next();
            Bit b = iter2.next();
            output.list.add(Bit.fullAdderSum(a, b, cin));
            cin = Bit.fullAdderCarry(a, b, cin);

        }

        if (iter1.hasNext()) {
            while (iter1.hasNext()) {
                Bit a = iter1.next();
                output.list.add(Bit.fullAdderSum(a, new Bit(false), cin));
                cin = Bit.fullAdderCarry(a, new Bit(false), cin);
            }
        }
        if (iter2.hasNext()) {
            while (iter2.hasNext()) {
                Bit b = iter2.next();
                output.list.add(Bit.fullAdderSum(new Bit(false), b, cin));
                cin = Bit.fullAdderCarry(new Bit(false), b, cin);
            }
        }
        if (cin.isOne()) output.list.add(cin); // maybe there is still cin and it changes absolutly the output!!!!!


        return output;

    }


    /**
     * Multiply the specified Number objects, and returns their product.
     *
     * @param num1 the first factor
     * @param num2 the second factor
     * @return the product of the specified Number objects.
     */
    public static Number multiply(Number num1, Number num2) { // assignment #14

        if (num1 == null | num2 == null) throw new IllegalArgumentException("Invalid input");

        Number output;
        if (num1.isZero() | num2.isZero()) output= new Number(); //zero multiply everything is zero!
        else {
            output = new Number();

            output.list.remove(new Bit(false)); //we dont need the zero that added by the empty constructor!
            Number variable = new Number(num2);
            Iterator<Bit> iter = num1.bitIterator();

            while (iter.hasNext()) {
                if (iter.next().isOne()) {
                    output = add(output, variable);
                }
                variable.list.add(0, new Bit(false));

            }
        }
        return output;
    }
}

