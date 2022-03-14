/*---------------------------------------
 Genuine author: <name>, I.D.: <id number>
 Date: xx-xx-2018 
---------------------------------------*/
public interface Stack<T> {
	
	//Returns true iff this stack is empty.
	public boolean isEmpty();
	
	//Removes the object at the top of this stack and returns that object.
	public T pop();
	
	//Pushes an item onto the top of this stack.
	public void push(T element);

}
