# %%
import sqlite3
import numpy as np
import pandas as pd

# %% [markdown]
# ## Setup dbase in RAM

# %%
con = sqlite3.connect(':memory:')
cur = con.cursor()


# %%
sql_dump = open(r"D:\py_ml\ds_tests\SQL\company_1\task_solution\db_sql", "r")
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
# ## Check DB (get list of tables)

# %%
pd.read_sql_query(
    """ SELECT name
        FROM sqlite_master
        WHERE type ='table'
        AND name NOT LIKE 'sqlite_%'; """,
    con)

# %% [markdown]
# ## Run queries in SQL
# a. Напишите запрос,который выводит название позиций(без повторений), хотя бы один представитель которой получает зарплату в промежутке 400-600

# %%
pd.read_sql_query(
    """ SELECT DISTINCT(POSITION)
        FROM job
        WHERE SALARY BETWEEN 400 AND 600; """,
    con)

# %% [markdown]
# b. Напишите запрос, который выполняет вывод списка офисов, расположенных в SEBEWAING и ELECTRON, количество рабочих и средней зарплаты рабочих в каждом офисе

# %%
pd.read_sql_query(
    """ SELECT OFFICE, count(WORKER_ID), avg(SALARY) as MEAN_SALARY
        FROM job
        WHERE OFFICE_CITY IN ("SEBEWAING", "ELECTRON")
        GROUP BY OFFICE; """,
    con)

# %% [markdown]
# c. Напишите запрос, который выводит название профессий (без повторений), все представители которой получают зарплату в промежутке 400-700

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
# d. Напишите запрос, который выводит среднюю зарплату работников, которые старше 30 лет, группируя по полу и возрасту, но при выводе увеличивающий данные о величине зарплаты на 20%

# %%
pd.read_sql_query(
    """ SELECT  substr(date(),1,4) - 19||substr(DOB,8,2) AS AGE,
                GENDER,
                AVG(SALARY) * 1.2 AS AVG_SALARY_UP
        FROM workers t1
        INNER JOIN job t2
        ON t1.WORKER_ID = t2.WORKER_ID
        WHERE AGE > 30
        GROUP BY AGE, GENDER; """,
    con)

# %% [markdown]
# e. Напишите запрос, который выведет накопленную зарплату по месяцам для Николы Теслы начиная с его приему на работу до сегодняшнего дня.

# %%
pd.read_sql_query("""
WITH RECURSIVE dates AS
  (SELECT min(CASE substr(FROM_DATE, 4, 3)
                  WHEN 'Jan' THEN 20||substr(FROM_DATE, 8, 2)||'-01'
                  WHEN 'Feb' THEN 20||substr(FROM_DATE, 8, 2)||'-02'
                  WHEN 'Mar' THEN 20||substr(FROM_DATE, 8, 2)||'-03'
                  WHEN 'Apr' THEN 20||substr(FROM_DATE, 8, 2)||'-04'
                  WHEN 'May' THEN 20||substr(FROM_DATE, 8, 2)||'-05'
                  WHEN 'Jun' THEN 20||substr(FROM_DATE, 8, 2)||'-06'
                  WHEN 'Jul' THEN 20||substr(FROM_DATE, 8, 2)||'-07'
                  WHEN 'Aug' THEN 20||substr(FROM_DATE, 8, 2)||'-08'
                  WHEN 'Sep' THEN 20||substr(FROM_DATE, 8, 2)||'-09'
                  WHEN 'Oct' THEN 20||substr(FROM_DATE, 8, 2)||'-10'
                  WHEN 'Nov' THEN 20||substr(FROM_DATE, 8, 2)||'-11'
                  WHEN 'Dec' THEN 20||substr(FROM_DATE, 8, 2)||'-12'
              END) AS year_month
   FROM job
   UNION ALL SELECT strftime('%Y-%m', date(year_month||'-01', '+1 month'))
   FROM dates
   WHERE year_month < date('now', '-1 month'))
SELECT year_month,
       SUM(SALARY) OVER (ROWS UNBOUNDED PRECEDING) AS CUM_SALARY
FROM
  (SELECT year_month,
          SALARY
   FROM dates
   INNER JOIN
     (SELECT SALARY,
             CASE substr(FROM_DATE, 4, 3)
                 WHEN 'Jan' THEN 20||substr(FROM_DATE, 8, 2)||'-01'
                 WHEN 'Feb' THEN 20||substr(FROM_DATE, 8, 2)||'-02'
                 WHEN 'Mar' THEN 20||substr(FROM_DATE, 8, 2)||'-03'
                 WHEN 'Apr' THEN 20||substr(FROM_DATE, 8, 2)||'-04'
                 WHEN 'May' THEN 20||substr(FROM_DATE, 8, 2)||'-05'
                 WHEN 'Jun' THEN 20||substr(FROM_DATE, 8, 2)||'-06'
                 WHEN 'Jul' THEN 20||substr(FROM_DATE, 8, 2)||'-07'
                 WHEN 'Aug' THEN 20||substr(FROM_DATE, 8, 2)||'-08'
                 WHEN 'Sep' THEN 20||substr(FROM_DATE, 8, 2)||'-09'
                 WHEN 'Oct' THEN 20||substr(FROM_DATE, 8, 2)||'-10'
                 WHEN 'Nov' THEN 20||substr(FROM_DATE, 8, 2)||'-11'
                 WHEN 'Dec' THEN 20||substr(FROM_DATE, 8, 2)||'-12'
             END AS start_date
      FROM job t1
      INNER JOIN workers t2 ON t1.WORKER_ID = t2.WORKER_ID
      WHERE FIRST_NAME = 'NIKOLA'
        AND LAST_NAME = 'TESLA') t3 ON t3.start_date <= dates.year_month);
        """, con)

# %% [markdown]
# f. Напишите запрос, который выведет накопленную зарплату по месяцам, разбитую по позициям, за 2014 год

# %%
pd.read_sql_query("""
WITH RECURSIVE dates AS
  (SELECT '2014-01' AS year_month
   UNION ALL SELECT strftime('%Y-%m', date(year_month||'-01', '+1 month'))
   FROM dates
   WHERE year_month < date('2014-12-01', '-1 month'))
SELECT POSITION,
       SUM(CASE
               WHEN year_month = '2014-01' THEN CUM_SALARY
           END) AS '2014-01',
       SUM(CASE
               WHEN year_month = '2014-02' THEN CUM_SALARY
           END) AS '2014-02',
       SUM(CASE
               WHEN year_month = '2014-03' THEN CUM_SALARY
           END) AS '2014-03',
       SUM(CASE
               WHEN year_month = '2014-04' THEN CUM_SALARY
           END) AS '2014-04',
       SUM(CASE
               WHEN year_month = '2014-05' THEN CUM_SALARY
           END) AS '2014-05',
       SUM(CASE
               WHEN year_month = '2014-06' THEN CUM_SALARY
           END) AS '2014-06',
       SUM(CASE
               WHEN year_month = '2014-07' THEN CUM_SALARY
           END) AS '2014-07',
       SUM(CASE
               WHEN year_month = '2014-08' THEN CUM_SALARY
           END) AS '2014-08',
       SUM(CASE
               WHEN year_month = '2014-09' THEN CUM_SALARY
           END) AS '2014-09',
       SUM(CASE
               WHEN year_month = '2014-10' THEN CUM_SALARY
           END) AS '2014-10',
       SUM(CASE
               WHEN year_month = '2014-11' THEN CUM_SALARY
           END) AS '2014-11',
       SUM(CASE
               WHEN year_month = '2014-12' THEN CUM_SALARY
           END) AS '2014-12'
FROM
  (SELECT year_month,
          POSITION,
          SUM(SUM_SALARY) OVER (PARTITION BY POSITION
                                ORDER BY year_month) AS CUM_SALARY
   FROM
     (SELECT year_month,
             POSITION,
             SUM_SALARY
      FROM dates
      INNER JOIN
        (SELECT POSITION,
                SUM(SALARY) AS SUM_SALARY,
                '2014-01' AS mon
         FROM job
         GROUP BY POSITION) t1 ON dates.year_month >= t1.mon))
GROUP BY POSITION;
      """, con)

# %% [markdown]
# ## Same queries in pandas

# %%
job = pd.read_sql_query("SELECT * FROM job", con)
workers = pd.read_sql_query("SELECT * FROM workers", con)
con.close()

# %% [markdown]
# task A

# %%
job.loc[(job["SALARY"] >= 400) & (job["SALARY"] <= 600), "POSITION"].unique()

# %% [markdown]
# task B

# %%
(job[job["OFFICE_CITY"].isin(["SEBEWAING", "ELECTRON"])]
 .groupby("OFFICE")
 .agg({"WORKER_ID": "count", "SALARY": "mean"}))

# %% [markdown]
# task C

# %%
(job
 .groupby("POSITION")
 .filter(lambda g: all((g["SALARY"] <= 700) & (g["SALARY"] >= 400)))["POSITION"]
 .unique())

# %% [markdown]
# task D

# %%
workers_new = (workers
               .assign(AGE=(pd.to_datetime("today") -
                            pd.to_datetime(workers["DOB"], format="%d-%b-%y")) //
                       np.timedelta64(1, "Y")))

workers_merged = pd.merge(workers_new, job, on="WORKER_ID")

(workers_merged
 .query("AGE > 30")
 .groupby(["GENDER", "AGE"])
 .agg(SALARY=pd.NamedAgg(column="SALARY", aggfunc=(lambda x: np.mean(x) * 1.2))))

# %% [markdown]
# task E

# %%
d_range = (pd.Series(pd.date_range(start=min(pd.to_datetime(job["FROM_DATE"],
                                                            format="%d-%b-%y")),
                                   end=pd.to_datetime("2020-06-01"),
                                   freq="M"))
           .to_frame(name="range")
           .set_index("range"))


job_filtered = (job
                .loc[job["WORKER_ID"] == workers
                     .loc[(workers["FIRST_NAME"] == "NIKOLA") &
                          (workers["LAST_NAME"] == "TESLA"), "WORKER_ID"]
                     .values[0],
                     ["SALARY", "FROM_DATE"]]
                .assign(FROM_DATE=pd.to_datetime(job["FROM_DATE"],
                                                 format="%d-%b-%y"))
                .set_index("FROM_DATE"))


(pd.merge_asof(d_range,
               job_filtered,
               left_index=True,
               right_index=True)
 .dropna(axis=0)
 .cumsum())

# %% [markdown]
# task F

# %%
m_index = (pd.MultiIndex
             .from_product([sorted(list(job["POSITION"]
                                        .unique())),
                            list(pd.date_range(start=pd.to_datetime("2014-01-01"),
                                               end=pd.to_datetime(
                                "2014-12-31"),
                                freq="M").strftime("%Y-%m"))]))
s_array = (job
           .groupby("POSITION")["SALARY"]
           .sum()
           .repeat(12)
           .to_numpy())

(pd.Series(s_array, index=m_index)
 .unstack(level=-1)
 .cumsum(axis=1))
