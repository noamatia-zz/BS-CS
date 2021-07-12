import sqlite3
import sys
import os
import printdb


def main(args):

    conn = sqlite3.connect('moncafe.db')

    conn.executescript("""
    
        DROP TABLE IF EXISTS Employees;
        DROP TABLE IF EXISTS Suppliers;
        DROP TABLE IF EXISTS Products;
        DROP TABLE IF EXISTS Coffee_stands;
        DROP TABLE IF EXISTS Activities;
        
        CREATE TABLE Employees (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            salary REAL NOT NULL,
            coffee_stand INTEGER REFERENCES Coffee_stand(id)
        );

        CREATE TABLE Suppliers (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            contact_information TEXT    
        );

        CREATE TABLE Products (
           id INTEGER PRIMARY KEY,
           description TEXT NOT NULL,
           price REAL NOT NULL,
           quantity INTEGER NOT NULL
        );

        CREATE TABLE Coffee_stands(
            id INTEGER PRIMARY KEY,
            location TEXT NOT NULL,
            number_of_employees INTEGER
        );
        
         CREATE TABLE Activities (
            product_id INTEGER INTEGER REFERENCES Product(id),
            quantity INTEGER NOT NULL,
            activator_id INTEGER NOT NULL,
            date DATE NOT NULL
        ); 
    """)

    input_file_name = args[1]

    cur = conn.cursor()

    with open(input_file_name) as input_file:
        for line in input_file:
            line = line.strip('\n')
            parameters = line.split(',')

            if parameters[0].strip() == 'C':
                cur.execute("INSERT INTO Coffee_stands(id, location, number_of_employees)" "VALUES (?, ?, ?)",
                            (parameters[1].strip(), parameters[2].strip(), parameters[3].strip()))

            if parameters[0].strip() == 'S':
                cur.execute("INSERT INTO Suppliers(id, name, contact_information)" "VALUES (?, ?, ?)",
                            (parameters[1].strip(), parameters[2].strip(), parameters[3].strip()))

            if parameters[0].strip() == 'E':
                cur.execute("INSERT INTO Employees(id, name, salary, coffee_stand)" "VALUES (?, ?, ?, ?)",
                            (parameters[1].strip(), parameters[2].strip(), parameters[3].strip(), parameters[4].strip()))

            if parameters[0].strip() == 'P':
                cur.execute("INSERT INTO Products(id, description, price, quantity)" "VALUES (?, ?, ?, ?)",
                            (parameters[1].strip(), parameters[2].strip(), parameters[3].strip(), 0))

    conn.commit()
    conn.close()
    printdb.__main__()

if __name__ == '__main__':
    main(sys.argv)
