# %%
import sqlite3
import pandas as pd

# %%
con = sqlite3.connect(':memory:')
cur = con.cursor()

# %%
sql_dump = open(r"db_sql\db_dmp.sql","r")
sql_statements = (sql_dump
                    .read()
                    .split(";"))
                
for st in sql_statements:
    try:
        cur.execute(st)
    except sqlite3.Error as e:
        print(e)              

# %%
pd.read_sql_query(
    """ SELECT name
        FROM sqlite_master 
        WHERE type ='table'
        AND name NOT LIKE 'sqlite_%';
    """, con)
    
# %%