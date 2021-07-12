import sqlite3
import sys
import os
import printdb

def main(args):

    conn = sqlite3.connect('moncafe.db')

    input_file_name = args[1]

    cur = conn.cursor()

    with open(input_file_name) as input_file:
        for line in input_file:
            line = line.strip('\n')
            parameters = line.split(',')

            if int(parameters[1].strip()) > 0:
                cur.execute("INSERT INTO Activities(product_id, quantity, activator_id, date)" "VALUES (?, ?, ?, ?)",
                            (parameters[0].strip(), parameters[1].strip(), parameters[2].strip(), parameters[3].strip()))
                sql_update_query = "UPDATE Products SET quantity=quantity+? WHERE id=?"
                data = (parameters[1].strip(), parameters[0].strip())
                cur.execute(sql_update_query, data)

            if int(parameters[1].strip()) < 0:
                cur.execute("SELECT quantity FROM Products WHERE id=?", ((int(parameters[0].strip()),)))
                currentQuantity = cur.fetchone()
                currentQuantity = currentQuantity[0]
                if (currentQuantity+int(parameters[1].strip()))>=0:
                    cur.execute("INSERT INTO Activities(product_id, quantity, activator_id, date)" "VALUES (?, ?, ?, ?)",
                        (parameters[0].strip(), parameters[1].strip(), parameters[2].strip(), parameters[3].strip()))
                    sql_update_query = "UPDATE Products SET quantity=quantity+? WHERE id=?"
                    data = (parameters[1].strip(), parameters[0].strip())
                    cur.execute(sql_update_query, data)


    conn.commit()
    conn.close()
    printdb.__main__()
if __name__ == '__main__':
    main(sys.argv)
