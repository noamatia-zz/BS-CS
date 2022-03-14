import java.io.*;

public class HashTable {

    private HashList[] Table;

    public HashTable(String m2) {
        if(!BTreeNode.IsNumber(m2))

            try { throw new Exception("illigal input");//checking if the string is represent number
            } catch (Exception e) { e.printStackTrace(); }

        Table = new HashList[Integer.parseInt(m2)];
    }

    private void hashFunction(int k) {

        int key = k % this.Table.length; //getting a key by a simple hash function
        HashListElement element = new HashListElement(k, null); //the element of k we want to insert

        if (Table[key] == null) {
            Table[key] = new HashList(element); //the index is empty create new hashlist there
        } else {
            Table[key].insert(element); //the index is not empty, root out k
        }
    }

    public void updateTable(String bad_passwords) {

        File file = new File(bad_passwords); //the file we will take from the bad passwords
        BufferedReader br = null; //the tool the will help us to read the text

        try { br = new BufferedReader(new FileReader(file));
        } catch (FileNotFoundException e) { e.printStackTrace(); }

        String password = null;

        try { password = br.readLine();
        } catch (IOException e) { e.printStackTrace(); }

        while (password != null) {
            int k = BloomFilter.Hornor(password); //coding by Hornor's rule so the password will be same like at the bloomfilter
            hashFunction(k); //put the password on the hashtable

            try { password = br.readLine(); //next password
            } catch (IOException e) { e.printStackTrace(); }
        }
    }

    public boolean checkAtTheHashTable(String password)throws Exception {

            int k = BloomFilter.Hornor(password);

            int index = k % this.Table.length; //the simple hash function

            if(this.Table[index]==null)
                return false; //the cell is empty

            HashListElement element=this.Table[index].GetFirst(); //we have to search by hashelements

            while(element!=null){ //the cell is not empty we have to check element by element

                if(element.getkey()==k)return true; //we found the key on the list
                element=element.getNext(); //try next one
            }
            return false; //we didnt find the key
    }

    public String getSearchTime(String requested_passwords) {

        File file = new File(requested_passwords); //the file we will take from the requested passwords
        BufferedReader br = null; //the tool the will help us to read the text
        try {
            br = new BufferedReader(new FileReader(file));
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        }

        String password= null;
        try {
            password = br.readLine();
        } catch (IOException e) {
            e.printStackTrace();
        }

        long startTime=System.nanoTime();

        while (password!=null) {
            try {
                boolean n=checkAtTheHashTable(password);
            } catch (Exception e) {
                e.printStackTrace();
            }
            try {
                password=br.readLine();//next password
            } catch (IOException e) {
                e.printStackTrace();
            }
        }

        long endTime=System.nanoTime();

        Double total=(double)(endTime-startTime)/1000000; //convert to milliseconds

        String totalStr=total.toString();

        if (totalStr.length()<6) { //ew have to add 0's at the end

            for (int i = totalStr.length(); i <= 5; i++)
                totalStr = totalStr + '0';

            return totalStr;
        }
        else return totalStr.substring(0,6);
    }
}
