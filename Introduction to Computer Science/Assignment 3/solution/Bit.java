
public class Bit {

    //fields
    private boolean value;

    //constructors

    public Bit(boolean value) {
        if(value) this.value=true;
        else this.value=false;
	}

	//methods

    public String toString() {
        String s;
        if (this.value==true) s="1";
        else s="0";

		return s; //replace with relevant return statement
    }

    public boolean isOne() {
        boolean output;
        if (this.value==true) output=true;
        else output=false;

		return output; //replace with relevant return statement
    }

    public boolean lessThan(Bit digit) {
        boolean output;
        if(digit.isOne() & this.value==false ) output=true;
        else output =false;
        return output; //replace with relevant return statement
	}

    public boolean lessEq(Bit digit) {
        boolean output;
        if(lessThan(digit) | (digit.isOne() & this.value==true) | (!digit.isOne() & this.value==false)) output=true;
        else output=false;
        return output; //replace with relevant return statement
	}

   public static Bit fullAdderSum(Bit A, Bit B, Bit Cin) {
        Bit output;
        if((A.isOne()&B.isOne()&Cin.isOne())| (!A.isOne()&!B.isOne()&Cin.isOne()) | (!A.isOne()&B.isOne()&!Cin.isOne()) | (A.isOne()&!B.isOne()&!Cin.isOne()))
            output = new Bit(true);
        else output = new Bit(false);
       return output; //replace with relevant return statement
   }
   public static Bit fullAdderCarry(Bit A, Bit B, Bit Cin) {
       Bit output;
       if((A.isOne()&B.isOne()&Cin.isOne())| (!A.isOne()&B.isOne()&Cin.isOne()) | (A.isOne()&B.isOne()&!Cin.isOne()) | (A.isOne()&!B.isOne()&Cin.isOne()))
           output = new Bit(true);
       else output = new Bit(false);
       return output; //replace with relevant return statement
   }
}
