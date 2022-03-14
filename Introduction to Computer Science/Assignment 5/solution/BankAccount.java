/*---------------------------------------
 Genuine author: <name>, I.D.: <id number>
 Date: xx-xx-2018 
---------------------------------------*/

/**
 * This class represents a bank account,
 * it has name, number and balance and supports operations like deposit and withdraw.
 *
 * @author <My name here>
 */

public class BankAccount {

    private String name;
    private int accountNumber;
    private int balance;

    public BankAccount(String name, int accountNumber, int balance) {
        if (name == null || name.length() == 0) {
            throw new IllegalArgumentException();
        }
        if (accountNumber <= 0) {
            throw new IllegalArgumentException();
        }
        this.name = name;
        this.accountNumber = accountNumber;
        this.balance = balance;
    }

    /**
     * A getter of the field name.
     *
     * @return returns the field name..
     */
    public String getName() {
        return name;
    }

    /**
     * A getter of the field balance.
     *
     * @return returns the field balance..
     */
    public int getBalance() {
        return balance;
    }

    /**
     * A getter of the field accountNumbername.
     *
     * @return returns the field accountNumber..
     */
    public int getAccountNumber() {
        return accountNumber;
    }

    /**
     * toString method of the following format: "Name: "+name+", AccountNumber: "+accountNumber.
     *
     * @return returns a String with the current state.
     */
    public String toString() {
        return "Name: " + name + ", AccountNumber: " + accountNumber;

        //use the following string to easily test your answers
        //return ""+accountNumber;
    }

    /**
     * This method deposit money into the bank account by increasing the balance.
     *
     * @param amount The amount of money to deposit.
     * @return true if amount >= 0 else if amount is negative return false without changing the balance.
     */
    public boolean depositMoney(int amount) {
        boolean output;
        if (amount<0) output=false;
        else {balance = balance + amount;
              output = true;
             }

        return output;
    }

    /**
     * This method withdraw money from the bank account by deceasing the balance.
     *
     * @param amount The amount of money to withdraw.
     * @return true if amount >= 0 and by decreasing balance it doesn't turns negative, else if amount is negative or
     * if balance < 0 after the withdraw return false without changing the balance.
     */
    //Complete the following method
    public boolean withdrawMoney(int amount) {
        boolean output;
        if (amount<0) output=false;
        else {
            if ((balance - amount) < 0) output = false;
            else {
                balance = balance - amount;
                output = true;
            }
        }

        return output;
    }
}
