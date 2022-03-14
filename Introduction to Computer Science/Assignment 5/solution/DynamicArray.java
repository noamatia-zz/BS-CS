/*---------------------------------------
 Genuine author: <name>, I.D.: <id number>
 Date: xx-xx-2018 
---------------------------------------*/
import java.util.NoSuchElementException;
import java.util.Iterator;

public class DynamicArray <T> implements List<T>{
	// -------------------- constants --------------------
	private static final int DEFAULT_CAPACITY = 16;
	// -------------------- fields --------------------
	private Object[] data;
	private int size;
	private int incrementSize;

	// -------------------- constructors --------------------
	//constructs an empty DynamicIntArray with specified initial capacity
	public DynamicArray(int initialCapacity){
	    if (initialCapacity <= 0)
	    	throw new IllegalArgumentException("non-positive initial capacity");
	    
	    data = new Object[initialCapacity];
	    incrementSize = initialCapacity;
	    size = 0;
	}
	
	//constructs an empty DynamicArray
	public DynamicArray(){
		this(DEFAULT_CAPACITY);  
	}
		
	// -------------------- methods -------------------- 
	
	//Return the number of elements in this array
	public int size(){
		return size;
	}
	
	//Appends the specified element to the end of this array
	public boolean add(T element){
		if (element == null)
			throw new IllegalArgumentException();
		data[size] = element;
		size = size+1;
		ensureCapacity();
		return true;
	}

	// ensures that data has the capacity to hold additional elements
	// data is reallocated in case it doesn't 
	private void ensureCapacity(){
		if (size() >= data.length){			
			Object[] newData = new Object[data.length + incrementSize];
			for(int i=0; i<data.length; i=i+1)
				newData[i] = data[i];        
			data = newData;
		}
	}
	
	//Returns the element at the specified position in this array.
	public T get(int index){
		if (!rangeCheck(index))
			 throw new IndexOutOfBoundsException("Index: " + index + ", Size: " + size);
		
		return (T) data[index];
	}

	// returns true iff the given index is in range
	private boolean rangeCheck(int index) {
		if(index < 0 || index >= size())
			return false;
		return true;
	        
	}
	
	//Replaces the element at the specified position in this array with the specified element
	public T set(int index, T element){
		if (element == null)
			throw new IllegalArgumentException();
		if(!rangeCheck(index))
			throw new IndexOutOfBoundsException("Index: " + index + ", Size: " + size());
		
		T prev = (T) data[index];
		data[index] = element;
		return prev;
	}

	//Removes the element at the specified position in this array
	public T remove(int index){
		if(!rangeCheck(index))
			throw new IndexOutOfBoundsException("Index: " + index + ", Size: " + size());
		T tmp = (T) data[index];
		for (int i = index; i < size()-1; i = i + 1)
			data[i] = data[i+1];
		size = size - 1;
		return tmp;
	}
		
	//Inserts the specified element at the specified position in this array
	public void add(int index, T element){
		if (element == null)
			throw new IllegalArgumentException();
		if(!rangeCheck(index))
			throw new IndexOutOfBoundsException("Index: " + index + ", Size: " + size());
		
		for (int i = size(); i >= index + 1; i = i - 1){
			data[i] = data[i-1];  }
		data[index] = element;
		size = size + 1;
		ensureCapacity();
	}

	//Indicates whether other dynamic array is "equal to" this (logically)
	public boolean equals(Object other) {
		boolean isEqual = true;
		if (! (other instanceof DynamicArray<?>))
			isEqual = false;
		else if (((DynamicArray<?>) other).size() != size())
			isEqual = false;
		else {
			for (int i = 0; i < size() & isEqual; i = i + 1)
				if(!get(i).equals(((DynamicArray<?>)other).get(i)))
					isEqual = false;
		}
		return isEqual;
	}

	//Returns a String representing this object
	public String toString() {
		String output = "<";
		for (int i = 0; i < size(); i = i + 1) {
			output = output + get(i).toString();
			if (i < size() - 1) 
				output = output + ", ";
		}
		output = output + ">";
		return output;
	}
	
	//Removes the first occurrence of the specified element from this array, if it is present
	public boolean remove(T element) {
		boolean removed = false;
		for(int i = 0; i<size() & !removed; i = i + 1)
			if(get(i).equals(element)){
				while(i < size()){
					data[i] = data[i+1];
					i = i + 1;
				}
				size = size - 1;
				removed = true;
			} 
		return removed;
	}

	//Returns true if this array contains no elements.
	public boolean isEmpty() {
		return size() == 0;
	}

	//Returns true if this array contains the specified element.
	public boolean contains(T element) {
		boolean found = false;
		for(int i = 0; i<size() & !found; i = i+1)
			if(get(i).equals(element))
				found = true;
		return found;
	}
	//Returns an iterator over elements of type T
	public Iterator<T> iterator(){
		return new DynamicArrayIterator<T>(this);
	}

}