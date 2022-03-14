public class Bit {

    private boolean value;

    public Bit() {
        this.value = false;
    }

    public Bit(boolean value) {
        this.value = value;
    }

    public boolean getValue() {
        return value;
    }

    public void setValue(boolean value) {
        this.value = value;
    }

    public static Bit fullAdderSum(Bit A, Bit B, Bit Cin){
        if(A == null | B == null | Cin == null)
            throw new NullPointerException();
        boolean a = A.value;
        boolean b = B.value;
        boolean cIn = Cin.value;
        return new Bit((a^b)^cIn);

        /*A     B   Cin S
          0 	0 	0 	0
          0 	0 	1 	1
          0 	1 	0 	1
          0 	1 	1 	0
          1 	0 	0 	1
          1 	0 	1 	0
          1 	1 	0 	0
          1 	1 	1 	1 */
    }

    public static Bit fullAdderCarry(Bit A, Bit B, Bit Cin) {
        if(A == null | B == null | Cin == null)
            throw new NullPointerException();
        boolean a = A.value;
        boolean b = B.value;
        boolean cIn = Cin.value;
        return new Bit(((a^b) & cIn) | (a & b));

        /*A     B   Cin Cout
          0 	0 	0 	0
          0 	0 	1 	0
          0 	1 	0 	0
          0 	1 	1 	1
          1 	0 	0 	0
          1 	0 	1 	1
          1 	1 	0 	1
          1 	1 	1 	1 	 */
    }

    public boolean isOne() {
        return value;
    }

    public boolean isZero() {
        return ! value;
    }

    public boolean lessThan(Bit digit) {
        if(digit == null)
            throw new NullPointerException();
        return (!value) & digit.value;
        /*A     B   A<B
          0 	0 	0
          0 	1 	1
          1 	0 	0
          1 	1 	0
       */
    }

    public boolean lessEq(Bit digit){
        if(digit == null)
            throw new NullPointerException();
        return (!value) | (digit.value);
        /*A     B   A<B
          0 	0 	1
          0 	1 	1
          1 	0 	0
          1 	1 	1
       */
    }

    @Override
    public String toString() {
        return ""+toInt();
    }

    public int toInt() {
        int intValue;
        if (value)
            intValue = 1;
        else
            intValue = 0;
        return intValue;
    }

    @Override
    public boolean equals(Object obj) {
        boolean isEqual;
        if (! (obj instanceof Bit))
            isEqual = false;
        else
            isEqual = value == ((Bit) obj).value;
        return isEqual;
    }
}
