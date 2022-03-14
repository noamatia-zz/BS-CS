import java.io.*;

public class BTree {

    private int tVal;
    private BTreeNode root;

    public BTree (String tVal)  {

        //build new tree, update the fields
        if(!BTreeNode.IsNumber(tVal))
            try { throw new Exception("illigal input");//checking if the string is represent number
            } catch (Exception e) { e.printStackTrace(); }
        this.tVal=toint(tVal);
        this.root=new BTreeNode(this.tVal);
    }

    public NodeAndIndex search (String k){

        //return BtreeNode that has the key

        return BTreeNode.search(this.root, k);
    }

    public void insert(String k){

        BTreeNode r = this.root;

        if(r.getNumOfKeys()==(2*r.tVal-1)) {
            BTreeNode s = new BTreeNode(r.tVal);
            this.setRoot(s);
            s.isNotALeaf();
            s.setNumOfKeys(0);
            s.setChildren(1, r);
            BTreeNode.splitChild(s, 1);
            BTreeNode.insertNonFull(s, k);
        }
        else BTreeNode.insertNonFull(r, k);
    }

    public static int toint(String s){

        //external function helping us to convert string to int

        int output = 0;
        int base = 1;
        for (int i = s.length(); i > 0; i--) {
            output = output + base * (int) (s.charAt(i-1) - '0');
            base = base * 10;
        }
        return output;
    }

    public BTreeNode getRoot(){return this.root;}//return the root

    public void setRoot(BTreeNode x){this.root=x;}//set the root

    public void createFullTree(String bad_passwords){

        File file = new File(bad_passwords); //the file we will take from the a and b of the hash functions
        BufferedReader br = null; //the tool the will help us to read the text

        try { br = new BufferedReader(new FileReader(file));
        } catch (FileNotFoundException e) { e.printStackTrace(); }

        String password = null;

        try { password = br.readLine();
        } catch (IOException e) { e.printStackTrace(); }

        while (password!=null){
            this.insert(password);//insert the new password to the the tree

            try { password=br.readLine();
            } catch (IOException e) { e.printStackTrace(); }
        }
    }

    public String toString(){

        //build String that represent the tree

        String treeLayout=new String("");
        treeLayout=BTreeNode.toStringWithD(this.root, treeLayout, 0);
        treeLayout=treeLayout.substring(0,treeLayout.length()-1);//deleting the last char = ","
        return treeLayout;
    }

    public String getSearchTime(String requested_passwords){

        File file = new File(requested_passwords); //the file we will take from the a and b of the hash functions
        BufferedReader br = null; //the tool the will help us to read the text

        try { br = new BufferedReader(new FileReader(file));
        } catch (FileNotFoundException e) { e.printStackTrace(); }

        long startTime=System.nanoTime();//initialize the start time

        String password= null;

        try { password = br.readLine();
        } catch (IOException e) { e.printStackTrace(); }

        while (password!=null) {

        NodeAndIndex n=search(password);//searching the word in the tree
            try { password=br.readLine();
            } catch (IOException e) { e.printStackTrace(); }
        }

        long endTime=System.nanoTime();//stop the time run

        Double total=(double)(endTime-startTime)/1000000;//change nano second to milli second

        String totalStr=total.toString();

        if (totalStr.length()<6) {//in case we have number with less than 6 digits
            for (int i = totalStr.length(); i <= 5; i++)
                totalStr = totalStr + '0';
            return totalStr; }

        else return totalStr.substring(0,6);//cutting the digits that unnecessary
    }

    public void deleteKeysFromTree (String delete_keys) {

        //finding the key if exist and delete him

        File file = new File(delete_keys); //the file we will take from the a and b of the hash functions
        BufferedReader br = null; //the tool the will help us to read the text

        try { br = new BufferedReader(new FileReader(file));
        } catch (FileNotFoundException e) { e.printStackTrace(); }

        String passwordToDelete = null;

        try { passwordToDelete = BTreeNode.capitalsConvert(br.readLine());
        } catch (IOException e) { e.printStackTrace(); }

        while (passwordToDelete!=null){

            BTreeNode.deleteKeysFromTree(this.root, passwordToDelete);

            try { passwordToDelete=br.readLine();
            } catch (IOException e) { e.printStackTrace(); }
        }
    }
}
