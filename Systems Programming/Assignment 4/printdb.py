import sqlite3
import sys
import os


def __main__():

    conn = sqlite3.connect('moncafe.db')
    cur = conn.cursor()

    cur.execute("SELECT * FROM Activities ORDER BY date ASC")
    activities_list = cur.fetchall()
    print('Activities')
    for activity in activities_list:
        print(activity)

    cur.execute("SELECT * FROM Coffee_stands ORDER BY id ASC")
    stands_list = cur.fetchall()
    print('Coffee stands')
    for stand in stands_list:
        print(stand)

    cur.execute("SELECT * FROM Employees ORDER BY id ASC")
    employee_list = cur.fetchall()
    print('Employees')
    for employee in employee_list:
        print(employee)

    cur.execute("SELECT * FROM Products ORDER BY id ASC")
    product_list = cur.fetchall()
    print('Products')
    for product in product_list:
        print(product)

    cur.execute("SELECT * FROM Suppliers ORDER BY id ASC")
    supplier_list = cur.fetchall()
    print('Suppliers')
    for supplier in supplier_list:
        print(supplier)

    cur.execute("""SELECT Activities.activator_id, Activities.quantity, Products.price
                    FROM Activities INNER JOIN
                    Products ON
                    Activities.product_id=Products.id""")
    sales_list = cur.fetchall()

    cur.execute("""SELECT Employees.id, Employees.name, Employees.salary, Coffee_stands.location 
                    FROM Employees LEFT OUTER JOIN 
                    Coffee_stands ON 
                    Employees.coffee_stand=Coffee_stands.id
                    ORDER BY Employees.name ASC""")
    report_list = cur.fetchall()

    print('Employees report')
    sum=0
    for report in report_list:
        for sale in sales_list:
            if report[0]==sale[0]:
                sum = sum + (sale[1] * sale[2]*(-1))
        finalReport=(report[1], report[2], report[3], sum)
        print(finalReport)
        sum=0

    cur.execute("""SELECT Activities.date, Products.description, Activities.quantity, Employees.name, Suppliers.name
                    FROM Activities
                    INNER JOIN Products ON Activities.product_id=Products.id
                    LEFT OUTER JOIN Employees ON Activities.activator_id=Employees.id
                    LEFT OUTER JOIN Suppliers ON Activities.activator_id=Suppliers.id
                    ORDER BY Activities.date ASC""")
    activityToPrint_list = cur.fetchall()
    if len(activityToPrint_list)>0:
        print('Activities')
        for activityToPrint in activityToPrint_list:
            print(activityToPrint)


    conn.commit()
    conn.close()

if __name__ == '__main__':
    __main__()
