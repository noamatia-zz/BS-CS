public class BTreeNode {

    private int numOfKeys;
    private String [] Keys;
    private BTreeNode [] Children;
    private boolean isALeaf;
    public static int tVal;

    public BTreeNode (int tVal) {
        this.Keys=new String[2*tVal+1];
        this.Children=new BTreeNode[2*tVal+2];
        this.numOfKeys=0;
        this.isALeaf=true;
        this.tVal=tVal;
    }

    public static NodeAndIndex search (BTreeNode x, String k){

        int i=1;

        String password=capitalsConvert(k); //the btree is not sensitive to capital letters

        while (i<=x.numOfKeys && password.compareTo(x.Keys[i])>0) i++; //next key same node

        if (i<=x.numOfKeys && password.compareTo(x.Keys[i])==0) return new NodeAndIndex(x, i); //we found the key

        else if (x.isALeaf) return null; //we can't go on anymore

        else return search(x.Children[i], password); //recursive call to current key's child
    }

    public static void  splitChild (BTreeNode x, int i){

        BTreeNode y = x.Children[i];
        BTreeNode z = new BTreeNode(tVal);
        z.isALeaf = y.isALeaf;
        z.numOfKeys=tVal-1;

        for (int j=1; j<=tVal-1; j++) z.Keys[j]=y.Keys[j+tVal]; //taking all the right part of y's keys

        if (!y.isALeaf)
            for (int j=1; j<=tVal; j++) z.Children[j]=y.Children[j+tVal]; //taking all the right part of y's children

        for (int j=x.numOfKeys+1; i+1<=j; j--) x.Children[j+1]=x.Children[j]; //getting place on x'children for z

        x.Children[i+1]=z;

        for (int j=x.numOfKeys; i<=j; j--) x.Keys[j+1]=x.Keys[j]; //getting place for the y's key that will get up

        x.Keys[i]=y.Keys[tVal]; //the y's key that will get up
        x.numOfKeys++;//we added one key to x
        y.numOfKeys=tVal-1; //only the first's tval-1 keys of y belongs to the tree now
    }

    public static void insertNonFull (BTreeNode x, String k){

        String password = capitalsConvert(k); //non sensitive to capital letters
        int i=x.numOfKeys;

        if(x.isALeaf){ //we just have to find the index
            while (1<=i && password.compareTo(x.Keys[i])<0){
                x.Keys[i+1]=(x.Keys[i]);
                i--;
            }
            x.Keys[i+1]=password;
            x.numOfKeys++;
        }
        //we have to find the leaf to insert in
        else {
            while (1 <= i && password.compareTo(x.Keys[i]) < 0) i--;

            i++;

            if (x.Children[i].numOfKeys == (2 * x.tVal - 1)) {

                splitChild(x, i); //we have to split before we can move on

                if (password.compareTo(x.Keys[i]) > 0) i++; //because of the split we have to take one more index
            }
            insertNonFull(x.Children[i], password); //recursive call to the child
        }
    }

    public static String capitalsConvert (String password) {

        //convert String to NonCapital string

        String str = "";//initials the NonCapital string

        for (int i = 0; i < password.length(); i++) {
            char a = password.charAt(i);
            if ('A' <= a & a <= 'Z') a = (char) ('a' + (password.charAt(i) - 'A'));//Convert to NonCapital if needed
            str = str + a;//update the NonCapital string
        }

        return str;
    }

    public int getNumOfKeys(){return this.numOfKeys;}//return the number of keys

    public void setNumOfKeys(int n){this.numOfKeys=n;}// update the number of keys

    public void setChildren(int i, BTreeNode x){this.Children[i]=x;}//set new child

    public void isNotALeaf(){this.isALeaf=false;}//update that the node is not a leaf

    public static String toStringWithD(BTreeNode x, String treeLayout, int D) {

        //build String that represent the tree include the depth of each node

        if (!x.isALeaf) {//in case we can make recursion call for the child's
            for (int i = 1; i <= x.numOfKeys; i++) {
                treeLayout=toStringWithD(x.Children[i], treeLayout, D+1);//recursion call for the left child
                treeLayout = treeLayout + x.Keys[i] + "_" + D + ",";//adding the key with the depth to the string
            }

            treeLayout=toStringWithD(x.Children[x.numOfKeys+1], treeLayout, D+1);//the key is the last one, recursion call for the right child

        } else {//the node is a leaf
            for (int i = 1; i <= x.numOfKeys; i++) {
                treeLayout = treeLayout + x.Keys[i] + "_" + D + ",";//adding the keys of the node this the depth to the string
            } }
        return treeLayout;
    }

    public static void deleteKeysFromTree(BTreeNode x, String passwordToDelete){

        NodeAndIndex target = findAndFix(x, passwordToDelete);//searching the node we want delete while "fixing"(preparing for delete) the path to him
        if (target==null) return;//the key is not in the tree

        if (target.node.isALeaf){//the key is in a leaf
            for (int j=target.Index; j<target.node.numOfKeys; j++)
                target.node.Keys[j]=target.node.Keys[j+1];//moving the keys to the left
            target.node.numOfKeys--;}//up date the number of keys

        else if(target.node.Children[target.Index].numOfKeys>=tVal){//the left child has enough keys
            String predecessor= predecessor(target.node.Children[target.Index]);//finding the predecessor
            NodeAndIndex toDelete = findAndFix(target.node, predecessor);//searching the predecessor we want delete while "fixing"(preparing for delete) the path to him
            deleteKeysFromTree(toDelete.node, predecessor);//delete the predecessor
            target.node.Keys[target.Index]=predecessor;}//update the key to be the predecessor

            //equally, the right child has enough keys, tracking the successor and deleting him, while update the key to be the successor

            else if (target.node.Children[target.Index+1].numOfKeys>=tVal){
                String successor =successor(target.node.Children[target.Index+1]);
                NodeAndIndex toDelete=findAndFix(target.node, successor);
                deleteKeysFromTree(toDelete.node, successor);
                target.node.Keys[target.Index]=successor;}

        //both the left and the right child, has not enough child, in this case we merge them

        else { merge(target.node, target.Index, target.node.Children[target.Index], target.node.Children[target.Index + 1]);
               NodeAndIndex newTarget=findAndFix(target.node, passwordToDelete);
               deleteKeysFromTree(newTarget.node, passwordToDelete);}
    }

    public static NodeAndIndex findAndFix(BTreeNode x, String k) {

        //search and return the the node and index of the key, while preparing the path for delete

        int i = 1;

        while (i <= x.numOfKeys && k.compareTo(x.Keys[i]) > 0) i++;

        if (i <= x.numOfKeys && k.compareTo(x.Keys[i]) == 0) return new NodeAndIndex(x, i);//finding the key

        else if (x.isALeaf) return null;//the key is not in the tree

        //in case the node on the path has to much keys

        else { if (i>1 && x.Children[i].numOfKeys==tVal-1 & x.Children[i-1].numOfKeys>tVal-1)
                shiftToRight (x, i-1, x.Children[i-1], x.Children[i]);//"taking" key from left child
            else if (i<=x.numOfKeys && x.Children[i].numOfKeys==tVal-1 & x.Children[i+1].numOfKeys>tVal-1)
                shiftToLeft (x, i, x.Children[i], x.Children[i+1]);//"taking" key from right child
            else if (i>1 && x.Children[i].numOfKeys==tVal-1) {
                merge(x, i - 1, x.Children[i - 1], x.Children[i]);//merge the right and left child(of the left child)
                return findAndFix(x, k);}//we change the location of the key so we search and fix again the path
            else if (x.Children[i].numOfKeys==tVal-1) {
                merge(x, i, x.Children[i], x.Children[i + 1]);//merge the right and left child(of the right child)
                return findAndFix(x, k);//we change the location of the key so we search and fix again the path
            }

        //in case we can continue searching

            return findAndFix(x.Children[i], k);
        }
    }

    public static void shiftToRight(BTreeNode x, int i, BTreeNode leftChild, BTreeNode rightChild){

        //move key from left child to the right child

        for (int j=rightChild.numOfKeys; 1<=j; j--){
            rightChild.Keys[j+1]=rightChild.Keys[j]; }

        for (int j=rightChild.numOfKeys+1; 1<=j; j--){
            rightChild.Children[j+1]=rightChild.Children[j]; }

        rightChild.Keys[1]=x.Keys[i];//adding the parent
        rightChild.Children[1]=leftChild.Children[leftChild.numOfKeys+1];//update the node children list

        x.Keys[i]=leftChild.Keys[leftChild.numOfKeys];//switch the key of the parent to the taken key

        leftChild.numOfKeys--;
        rightChild.numOfKeys++;//update the number of keys after shifting
    }

    public static void shiftToLeft(BTreeNode x, int i, BTreeNode leftChild, BTreeNode rightChild){

        //move key from right child to the left child

        leftChild.Keys[leftChild.numOfKeys+1]=x.Keys[i];//adding the parent
        leftChild.Children[leftChild.numOfKeys+2]=rightChild.Children[1];//adding the key

        x.Keys[i]=rightChild.Keys[1];//switch the key of the parent to the taken key

        for (int j=1; j<rightChild.numOfKeys; j++){
            rightChild.Keys[j]=rightChild.Keys[j+1]; }

        for (int j=1; j<rightChild.numOfKeys+1; j++){
            rightChild.Children[j]=rightChild.Children[j+1]; }

        leftChild.numOfKeys++;
        rightChild.numOfKeys--;//update the number of keys after shifting

    }

    public static void merge(BTreeNode x, int i, BTreeNode leftChild, BTreeNode rightChild) {

        //merging the left and right child with the parent

        if(x.numOfKeys == 1)//in case we marge to the root
            mergeRootHasOneKey(x, i, leftChild, rightChild);

        else{
            leftChild.Keys[tVal] = x.Keys[i];//adding the parent

            for (int j = 1; j <= tVal - 1; j++) {//adding the keys from the right child
                leftChild.Keys[tVal + j] = rightChild.Keys[j];
                leftChild.Children[tVal + j] = rightChild.Children[j];}//update the child list

            for (int j = i; j < x.numOfKeys; j++) {
                x.Keys[j] = x.Keys[j + 1]; }//update the parent key list

            for (int j = i + 1; j <= x.numOfKeys; j++) {
                x.Children[j] = x.Children[j + 1]; }//update the prent children list

            x.numOfKeys--;
            x.Children[i].numOfKeys = 2 * tVal - 1;
        }
    }

    public static void mergeRootHasOneKey(BTreeNode x, int i, BTreeNode leftChild, BTreeNode rightChild) {

        //merge the root with right and left children

        x.Keys[tVal]=x.Keys[1];

        for (int j=1; j<tVal; j++){//update the keys in the root
            x.Keys[j]=leftChild.Keys[j];
            x.Keys[tVal+j]=rightChild.Keys[j]; }

        for (int j=1; j<=tVal; j++){//update the children in the root
            x.Children[j]=leftChild.Children[j];
            x.Children[tVal+j]=rightChild.Children[j]; }

        x.numOfKeys=2*tVal-1;//update number of keys in the root
    }

    public static String predecessor(BTreeNode x){

        //return the key of the predecessor

        if (x.isALeaf) return x.Keys[x.numOfKeys];

        else return predecessor(x.Children[x.numOfKeys+1]);
    }

    public static String successor(BTreeNode x){

        //return the key of the successor

        if (x.isALeaf) return x.Keys[1];

        else return successor(x.Children[1]);
    }

    public static boolean IsNumber(String str){

        //checking if the string represent number

     for(int i=0;i<str.length();i++)
         if((int)str.charAt(i)>'9'|(int)str.charAt(i)<'0')return false;
    return true;
    }
}
