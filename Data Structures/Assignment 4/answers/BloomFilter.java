import java.io.*;

public class BloomFilter {

    private int[][] hash;
    public int[] BloomFilter;

    public  BloomFilter(String m1,String hash_functions)  {
        if(!BTreeNode.IsNumber(m1))
            try { throw new Exception("illigal input");//checking if the string is represent number
            } catch (Exception e) { e.printStackTrace(); }


        BloomFilter = new int[Integer.parseInt(m1)]; //empty bloomfilter = initialize only with 0's (at java)
        try { updateHashFunctions(hash_functions); //external function that will help us update the table of the hash functions
        } catch (FileNotFoundException e) { e.printStackTrace(); }
    }

    public void updateHashFunctions(String hash_functions) throws FileNotFoundException {

        try { hash = new int[countNumOfLines(hash_functions)][2]; //initialize the table of a and b of the hash functions
        } catch (Exception e) { e.printStackTrace(); }

        File file = new File(hash_functions); //the file we will take from the a and b of the hash functions
        BufferedReader br = null; //the tool the will help us to read the text

        br = new BufferedReader(new FileReader(file));


        for (int i = 0; i < this.hash.length; i++) { //running on all over the txt lines

            String function = null; //the i line of the text
            try { function = br.readLine();
            } catch (IOException e) { e.printStackTrace(); }

            int indexOfSpace=0;//the index of the char '_'

            while (function.charAt(indexOfSpace)!='_') indexOfSpace++;//finding the index of '_'

            String str_ai = function.substring(0, indexOfSpace); //the a of the i function
            String str_bi = function.substring(indexOfSpace+1); //the b of the i function

            hash[i][0] = Integer.parseInt(str_ai);//the cell of the i's cell for ai
            hash[i][1] = Integer.parseInt(str_bi);//the cell of the i's cell for ai
        }
    }

    public int countNumOfLines (String str)throws Exception{

        File file = new File(str); //the file we will take from the a and b of the hash functions
        BufferedReader br = new BufferedReader(new FileReader(file)); //the tool the will help us to read the text

        int output=0;

        while ((br.readLine()) != null) output++; //counting the number of lines of File

        return output;
    }

    public void updateTable(String bad_passwords){

        File file = new File(bad_passwords); //the file we will take from the bad passwords
        BufferedReader br = null; //the tool the will help us to read the text

        try { br = new BufferedReader(new FileReader(file));
        } catch (FileNotFoundException e) { e.printStackTrace(); }

        String password = null;
        try { password = br.readLine();
        } catch (IOException e) { e.printStackTrace(); }

        while (password != null) {

            int k = Hornor(password); //coding our password by Hornor's rule

            for (int i = 0; i < hash.length; i++) //putting 1's each place a hash function will tell us to
                BloomFilter[((hash[i][0] * k + hash[i][1]) % 15486907)%this.BloomFilter.length] = 1; //((a*k+b)mod p)mod m1

            try { password=br.readLine();
            } catch (IOException e) { e.printStackTrace(); }
        }
    }

    public  String getFalsePositivePercentage(HashTable H, String requested_passwords)  {

        int numOfBadByBloomfilter=0; //number of passwords are bad by the bloomfilter
        int numOfBad=0; //number of passwords are bad
        int numOfGood=0; //number of passwords are good

        File file = new File(requested_passwords); //the file we will take from the requested passwords
        BufferedReader br = null; //the tool the will help us to read the text

        try { br = new BufferedReader(new FileReader(file));
        } catch (FileNotFoundException e) { e.printStackTrace(); }

        String password = null; //we will check each password

        try { password = br.readLine();
        } catch (IOException e) { e.printStackTrace(); }

        while (password!=null) {

            try { if (checkAtTheBloomfilter(password)) numOfBadByBloomfilter++; //external function will help us to check if "password" is bad by the bloomfilter
            } catch (Exception e) { e.printStackTrace(); }

            try { if(H.checkAtTheHashTable(password)) numOfBad++; //external function will help us to check if "password" is bad=belongs to the hash table

                else numOfGood++; } catch (Exception e) { e.printStackTrace(); }

            try { password=br.readLine(); //next password
            } catch (IOException e) { e.printStackTrace(); }
        }
        int falsePositive=numOfBadByBloomfilter-numOfBad; //number of passwords are bad by the bloomfilter, but actually good
        Double precentageOfError=(double)falsePositive/numOfGood;

        return precentageOfError.toString();
    }

    public String getRejectedPasswordsAmount(String requested_passwords)  {

         Integer counter=0;

        File file = new File(requested_passwords); //the file we will take from the requested passwords
        BufferedReader br = null; //the tool the will help us to read the text

        try { br = new BufferedReader(new FileReader(file));
        } catch (FileNotFoundException e) {
            e.printStackTrace(); }

        String password = null;

        try { password = br.readLine();
        } catch (IOException e) { e.printStackTrace(); }

        while (password!=null) {

            try { if (checkAtTheBloomfilter(password)) //external function will help us to check if "password" is bad by the bloomfilter
                    counter++;
            } catch (Exception e) { e.printStackTrace(); }

            try { password=br.readLine(); //next password
            } catch (IOException e) { e.printStackTrace(); }
        }
     return counter.toString();
    }

    public boolean checkAtTheBloomfilter(String password)throws Exception {

        int k = Hornor(password); //coding by Hornor's rule

        for (int i = 0; i < hash.length; i++) {

            int index = (((hash[i][0] * k + hash[i][1]) % 15486907) % (this.BloomFilter.length)); //((a*k+b)mod p)mod m1

            if (this.BloomFilter[index] == 0)
                return false; //if we found 0 = password is good by bloomfilter
        }
            return true; //we found only 1's, password is bad by bloomfilter
    }

    public static int Hornor(String password){
        long k = password.charAt(0);
        for (int i = 1; i < password.length(); i++)
            k = (password.charAt(i) + 256 * k) % 15486907;
        return (int)k;
    }

}