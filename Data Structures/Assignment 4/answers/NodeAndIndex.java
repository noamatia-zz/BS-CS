public class NodeAndIndex {

    BTreeNode node;
    int Index;

    public NodeAndIndex(BTreeNode node, int Index){
        this.node=node;
        this.Index=Index;
    }

    public BTreeNode getNode(){
        return this.node;
    }

    public int getIndex(){
        return this.Index;
    }
}
