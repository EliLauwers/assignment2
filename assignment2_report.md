Assignment2 - Eli Lauwers
================

# 1 Interpretation of advanced SQL

## 1.1 Consider the folowing `SELECT`-query

``` sql
SELECT DISTINCT license_plate
FROM registration r1
WHERE NOT EXISTS(SELECT 1
FROM registration r2
WHERE r1.email != r2.email
AND r1.license_plate = r2.license_plate)
```

<div class="knitsql-table">

| license\_plate |
|:---------------|
| 1-CTD-882      |
| 1-GIF-292      |
| 1-ILX-716      |
| 1-PMQ-963      |
| 1-TZH-641      |

5 records

</div>

**Question**: Describe, in your own words, what this SELECT-query
achieves. You should not give the result table of this query or explain
this query in technical terms (i.e. we do not expect a literal
translation of the operations that are performed in the query), but
explain what the semantical outcome is of this query when executed on
data that is stored in the rollsrobin database. Provide your answer in a
short report.

**Argumentation**: When interpreting SQL-queries with subqueries, I
always try to interpret the subquery first. In this case however, the
subquery uses the `registration r1` as provided in the subquery.

The subquery returns all registrations where different `email` adresses
where used on the same `license_plate`. In other words, it returns a
**subtable** with cars that have been rented by multiple different
people. In the outer query, all `registrations` are checked against that
subtable. By using a `NOT EXISTS` clause, the resulting table consists
of all registrations where a car was rented by only one person. It can
however be that the car in question was rented multiple times.

Lastly, the `SELECT DISTINCT license_plate` states that we will extract
every distinct license\_plate. So in other words: from all cars that are
rented by only one person, get the license plates.

In summary, the full query returns all `lincense_plates` from cars that
were indeed rented, but only rented by one person.

**Check**: To check my working hypothesis, I will create an SQL query
that will result in a subset of license\_plates from cars that were
rented by one distinct person (cf. my working hypothesis). The resulting
table shows the exact same subset of `license_plates` which validates -
or provides extra evidence - for the hypothesis.

``` sql
/* Get all license plates for cars that were only rented by the same person */
SELECT r1.license_plate, 
/* Count number of distinct renters */
COUNT(DISTINCT r1.email) as number_of_distinct_renters
FROM registration r1
GROUP BY r1.license_plate
/* Only return rows where there is one distinct renter */
HAVING COUNT(DISTINCT r1.email) = 1
```

<div class="knitsql-table">

| license\_plate | number\_of\_distinct\_renters |
|:---------------|------------------------------:|
| 1-CTD-882      |                             1 |
| 1-GIF-292      |                             1 |
| 1-ILX-716      |                             1 |
| 1-PMQ-963      |                             1 |
| 1-TZH-641      |                             1 |

5 records

</div>

**Answer**: The query returns all `lincense_plates` from cars that were
rented by only one distinct person.

## 1.2 Rewrite

**Question**: Rewrite the following SELECT-query such that it does not
use aggregation functions, grouping and having. However, it is important
that the result table retrieved by your query equals exactly the result
table retrieved by the original query, so try to understand the original
query first. Add a file with the name
studentcode\_firstname\_lastname\_1\_2.sql, in which you substitute
‘studentcode’, ‘firstname’ and ‘lastname’ by resp. your studentcode,
firstname and lastname, to the .zip file containing the rewritten
SELECT-query.

``` sql
SELECT DISTINCT r.email 
FROM registration r
INNER JOIN car c USING (license_plate)
GROUP BY r.email
HAVING COUNT(DISTINCT c.enterprisenumber) = 1;
```

<div class="knitsql-table">

| email                         |
|:------------------------------|
| <aarya-deakes@gmail.com>      |
| <abencrew@yahoo.com>          |
| <abrielle.baversor@gmail.com> |
| <aiyahuyche@gmail.com>        |
| <akif@fetherby.nl>            |
| <alanna.hazell@yahoo.com>     |
| <alexis_ahearne@yahoo.com>    |
| <alica-giacomo@hotmail.com>   |
| <ameira-corby@msn.be>         |
| <aneesh-nanni@outlook.com>    |

Displaying records 1 - 10

</div>

**Argumentation**: Interpretation of the code is as follows: ‘Return all
distinct email adressess of people who have rented cars at only one
distinct enterprise(number)’. So I’ll create some SQL code doing the
exact same thing.

``` sql
/* 
  Get all distinct email adresses of people who 
  have rented cars at only enterprise(number)
  
  This documentation starts at the inner queries and moves from inner
  to outer queries.
  
  r1 and r2 are identical to each other.
  Both are tables where every registration is linked to the 
  enterprisenumbers given the cars licenseplate

  Next, inner join r1 with r2 on identical emails but different enterpises.
  The resulting table are pairs of registrations from one person at distinct
  enterprises.
  
  from the paired table, only distinct email adresses are selected. 
  These email adresses are all people who have registrations for cars
  from different enterprises.
  
  The outer query is rather simple. It returns every distinct emailadress that 
  is not present in the inner query table. As such, it results in a table 
  consisting of all registrations of all people who have rented at only one
  distinct enterprise
*/

SELECT DISTINCT r.email 
FROM registration r
WHERE r.email NOT IN (
  SELECT DISTINCT r1.email
  FROM (
    SELECT *
    FROM registration r
    INNER JOIN car c USING(license_plate)
  ) r1
  INNER JOIN (
    SELECT *
    FROM registration r
    INNER JOIN car c USING(license_plate)
  ) r2 ON 
  r1.email = r2.email AND 
  r1.enterprisenumber != r2.enterprisenumber
)
    
```

<div class="knitsql-table">

| email                          |
|:-------------------------------|
| <millie-janefalkinder@mail.be> |
| <umer@vassano.com>             |
| <dwaynedauber@yahoo.com>       |
| <ileana.ebertz@gmail.com>      |
| <sruthi-mcmichan@outlook.com>  |
| <brandan-siret@outlook.com>    |
| <davi@maidstone.nl>            |
| <yechiel@sink.com>             |
| <maria.colthurst@gmail.com>    |
| <marlowe.camacke@gmail.com>    |

Displaying records 1 - 10

</div>

## 1.3 Consider the following task for which a SELECT-query should be written.

**Question**: Give a list of email addresses of all persons (one or
multiple) who registered a car for the longest rental period present in
the database. Here, the length of a rental period is based on the number
of days from period\_begin until period\_end (boundaries inclusive).

Only persons who started this (longest) rental period the earliest
(based on period\_begin) of all people renting for the longest period
should be returned by your query. In the result table, only one column
email of datatype varchar is expected.

In order to illustrate this task, consider the example data given in
Table 1. Given these data, the query should return only one email
address, i.e. ‘<person1@%22ugent.be>’. The reason for this is that both
person 1 and person 3 had the longest rental period in the database
(i.e. 12 days), but the begin date of this rental period of person 1
(i.e. 2018-06-12) was earlier than the begin date of this rental period
of person 3 (i.e. 2020-02-14).

|     **email**      | **period\_begin** | **period\_end** | **\# days** |
|:------------------:|:-----------------:|:---------------:|:-----------:|
| <person1@ugent.be> |    2018-06-12     |   2018-06-23    |     12      |
| <person1@ugent.be> |    2017-06-27     |   2017-06-28    |      2      |
| <person2@ugent.be> |    2018-05-03     |   2018-05-04    |      2      |
| <person2@ugent.be> |    2019-12-15     |   2020-12-19    |      5      |
| <person3@ugent.be> |    2020-02-14     |   2020-02-25    |     12      |

Now have a look at the following SELECT-query.

``` sql
/* 
  Get all distinct email adresses of people who 
  have rented cars at only enterprise(number)
  
  This documentation starts at the inner queries and moves from inner
  to outer queries.
  
  r1 and r2 are identical to each other.
  Both are tables where every registration is linked to the 
  enterprisenumbers given the cars licenseplate

  Next, inner join r1 with r2 on identical emails but different enterpises.
  The resulting table are pairs of registrations from one person at distinct
  enterprises.
  
  from the paired table, only distinct email adresses are selected. 
  These email adresses are all people who have registrations for cars
  from different enterprises.
  
  The outer query is rather simple. It returns every distinct emailadress that 
  is not present in the inner query table. As such, it results in a table 
  consisting of all registrations of all people who have rented at only one
  distinct enterprise
*/

SELECT DISTINCT r.email 
FROM registration r
WHERE r.email NOT IN (
  SELECT DISTINCT r1.email
  FROM (
    SELECT *
    FROM registration r
    INNER JOIN car c USING(license_plate)
  ) r1
  INNER JOIN (
    SELECT *
    FROM registration r
    INNER JOIN car c USING(license_plate)
  ) r2 ON 
  r1.email = r2.email AND 
  r1.enterprisenumber != r2.enterprisenumber
)
    
```

<div class="knitsql-table">

| email                          |
|:-------------------------------|
| <millie-janefalkinder@mail.be> |
| <umer@vassano.com>             |
| <dwaynedauber@yahoo.com>       |
| <ileana.ebertz@gmail.com>      |
| <sruthi-mcmichan@outlook.com>  |
| <brandan-siret@outlook.com>    |
| <davi@maidstone.nl>            |
| <yechiel@sink.com>             |
| <maria.colthurst@gmail.com>    |
| <marlowe.camacke@gmail.com>    |

Displaying records 1 - 10

</div>

Does this query solve the task that was described above in all possible
situations? If not, explain in your own words what is wrong with the
query and how you can solve this. Provide your answer in a short report.

**Argumentation**: The problem lies in the `AND` clause. Right now, the
resuting table consists of all rows where the renting period was the
longest **and** where the begin date of the rental period comes before
all other dates. The only time the query will work is if the longest
rental period belongs to the rental period which also started before all
other registrations. Running this query on the testset won’t work
probably. Also, the fourth row states that `person2@ugent.be` only
rented 5 days, when the rental dates are nearly a year apart. Seems like
a little mistake.

I would advise altering the query by integrating a subquery.

-   in the subquery, select all rows with the maximum renting period
-   in the outer query, return the earliest starter from the subquery.

``` sql
SELECT DISTINCT tmp.email
FROM (
  /* Subquery: get the rows with maximum rental period */
    SELECT *
    FROM registration r
  WHERE r.period_end - r.period_begin >= ALL(
    SELECT r.period_end - r.period_begin FROM registration r
  )
) tmp
WHERE tmp.period_begin <= ALL(
  /* Subquery: get the rows with maximum rental period */
    SELECT r.period_begin
  FROM registration r
  WHERE r.period_end - r.period_begin >= ALL(
    SELECT r.period_end - r.period_begin FROM registration r
  )
)
```

<div class="knitsql-table">

| email                       |
|:----------------------------|
| <dita-kopf@mail.be>         |
| <ruqiya.peirson@msn.be>     |
| <tahmeedfranken@telenet.be> |

3 records

</div>

# 2 Advanced SQL

Provide SQL SELECT-queries as solutions to the following exercises
related to the rollsrobin database. Each query should be added to a
separate .sql file with filename
studentcode\_firstname\_lastname\_2\_X.sql in which you substitute
‘studentcode’, ‘firstname’ and ‘lastname’ with your studentcode,
firstname and lastname respectively, and ‘X’ with the number of the
question (1 to 5). Add these .sql files to your final .zip file.

## 2.1 SOME title

Give for each car in the database that was rented (registered) at least
once, the number of nights that passed by between the first time that
the car was rented (based on period\_begin of the first registration,
exclusive) and the last time that the car was rented (based on
period\_begin of the last registration, inclusive). In the result table,
we expect two columns with corresponding datatype: license\_plate
(varchar) and passed\_nights (integer). Example: Table 2 shows a list of
registrations (only the license plate and begin of the registration
period are shown). Given this data, the expected result table is shown
in Table 3.

``` sql
SELECT r.license_plate, 
MIN(r.period_begin), 
MAX(r.period_end),
MAX(r.period_end) - MIN(r.period_begin)+1 days
FROM registration r
WHERE r.license_plate IN (
  /* Get all more than once registered cars */
    SELECT r.license_plate
  FROM registration r
  GROUP BY (license_plate)
  HAVING COUNT(*) > 1
)
GROUP BY r.license_plate
ORDER BY days asc
```

<div class="knitsql-table">

| license\_plate | min        | max        | days |
|:---------------|:-----------|:-----------|-----:|
| 1-PMQ-963      | 2018-04-23 | 2018-04-28 |    6 |
| 1-HLM-435      | 2017-12-06 | 2017-12-20 |   15 |
| 1-ZLX-079      | 2017-08-23 | 2017-10-26 |   65 |
| 1-SYR-442      | 2017-10-10 | 2018-01-08 |   91 |
| 1-SBA-790      | 2018-09-18 | 2018-12-17 |   91 |
| 1-KLM-122      | 2018-02-15 | 2018-05-16 |   91 |
| 1-VBO-366      | 2018-03-20 | 2018-06-18 |   91 |
| 1-VKL-527      | 2017-05-08 | 2017-08-18 |  103 |
| 1-ABD-789      | 2018-01-17 | 2018-05-19 |  123 |
| 1-POI-917      | 2017-06-08 | 2017-11-18 |  164 |

Displaying records 1 - 10

</div>
