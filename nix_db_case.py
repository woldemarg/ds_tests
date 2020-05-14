# %%
import sqlite3
import pandas as pd

# %% [markdown]
# ## Setup dbase in RAM

# %%
con = sqlite3.connect(':memory:')
cur = con.cursor()

# %%
sql_dump = open(r"db_sql\db_dmp.sql","r")
sql_statements = (sql_dump
                    .read()
                    .split(";"))
sql_dump.close()
                
for st in sql_statements:
    try:
        cur.execute(st)
    except sqlite3.Error as e:
        print(e)              

# %% [markdown]
# ## Check DB (via list of tables)

# %%
pd.read_sql_query(
    """ SELECT name
        FROM sqlite_master 
        WHERE type ='table'
        AND name NOT LIKE 'sqlite_%'; """,
        con)

# %% [markdown]
# ## Run queries
# a. Напишите запрос, который выводит название позиций (без повторений),
# хотя бы один представитель которой получает зарплату в промежутке 400-600

# %%
pd.read_sql_query(
    """ SELECT DISTINCT(POSITION)
        FROM job
        WHERE SALARY BETWEEN 400 AND 600; """,
        con)

# %% [markdown]
# b. Напишите запрос, который выполняет вывод списка офисов,
# расположенных в SEBEWAING и ELECTRON, количество рабочих и
# средней зарплаты рабочих в каждом офисе

# %%
pd.read_sql_query(
    """ SELECT OFFICE, count(WORKER_ID), avg(SALARY) as MEAN_SALARY
        FROM job
        WHERE OFFICE_CITY IN ("SEBEWAING", "ELECTRON")
        GROUP BY OFFICE; """,
        con)

# %% [markdown]
# c. Напишите запрос, который выводит название профессий (без повторений),
# все представители которой получают зарплату в промежутке 400-700

# %%
pd.read_sql_query(
    """ SELECT DISTINCT(POSITION)
        FROM job
        WHERE POSITION NOT IN
            (SELECT POSITION
            FROM job
            WHERE SALARY NOT BETWEEN 400 AND 700); """,
        con)

# %% [markdown]
# d. Напишите запрос, который выводит среднюю зарплату работников,
# которые старше 30 лет, группируя по полу и возрасту,
# но при выводе увеличивающий данные о величине зарплаты на 20%

# %%
pd.read_sql_query(
    """ SELECT  substr(date(),1,4) - 19||substr(DOB,8,2) AS AGE,
                GENDER,
                AVG(SALARY) * 1.2 AS AVG_SALARY
        FROM workers t1
        INNER JOIN job t2
        ON t1.WORKER_ID = t2.WORKER_ID
        WHERE AGE > 30
        GROUP BY AGE, GENDER; """,
        con)

# %%
