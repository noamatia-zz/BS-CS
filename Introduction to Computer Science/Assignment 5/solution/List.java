/*---------------------------------------
 Genuine author: <name>, I.D.: <id number>
 Date: xx-xx-2018 
---------------------------------------*/
public interface List <T> extends Iterable<T>{
	
		//Returns the number of elements in this list
        public int size();
        
        //Appends the specified element to the end of this list
        public boolean add(T element);
        
        //Inserts the specified element at the specified position in this list
        public void add(int index, T element);
        
        //Replaces the element at the specified position in this list with the specified element
        public T set(int index, T element);
        
        //Returns the element at the specified position in this list
        public T get(int index);
        
        //Removes the first occurrence of the specified element from this list, if it is present
        public boolean remove(T element);
        
        //Removes the element at position i and returns it
        public T remove(int index);
        
        //Returns true if this list contains the specified element
        public boolean contains(T element);
        
        //Returns true if this list contains no elements
        public boolean isEmpty();
}
