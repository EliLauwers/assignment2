Assignment2 - Eli Lauwers
================

# 1 Interpretation of advanced SQL

## 1.1 Consider the folowing `SELECT`-query

``` sql
SELECT DISTINCT license_plate
FROM registration r1
WHERE NOT EXISTS(
  SELECT 1
  FROM registration r2
  WHERE r1.email != r2.email
  AND r1.license_plate = r2.license_plate
)
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
subquery uses the `registration r1` as provided in the outer query.

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
  COUNT(DISTINCT r1.email) number_of_distinct_renters -- Count number of distinct renters
FROM registration r1
GROUP BY r1.license_plate
HAVING COUNT(DISTINCT r1.email) = 1 --Only return rows where there is one distinct renter
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

**Answer**: The query returns all `license_plates` from cars that were
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
  First, the WITH-statement creates one table that can be reused as a distinct table.
  The table itself contains all registrations linked to the corresponding
  owning enterprises. Without the with statement, I would copy paste identical 
  code two times, which does the same thing.

  Next, self join the linked table on identical emails but different enterpises.
  The resulting table are pairs of registrations from one person at distinct
  enterprises.
  
  from the paired table, only distinct email adresses are selected. 
  These email adresses are all people who have registrations for cars
  from different enterprises.
  
  The outer query is rather simple. It returns every distinct emailadress that 
  is not present in the inner query table. As such, it results in a table 
  consisting of all distinct email adresses of all people who have rented at only one
  distinct enterprise
*/


WITH linked as (
    SELECT *    
    FROM registration r    
    INNER JOIN car c USING(license_plate)
)   
SELECT DISTINCT r.email  
FROM registration r 
WHERE r.email NOT IN (
  /* All email adresses of people who have registrations at different enterprises */
    SELECT DISTINCT l1.email
    FROM linked l1 -- link a registration to a cars owning enterprise
    INNER JOIN linked l2 ON l1.email = l2.email 
    AND l1.enterprisenumber != l2.enterprisenumber 
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

Now have a look at the following SELECT-query.

``` sql
SELECT DISTINCT email 
FROM registration 
INNER JOIN person USING (email)
WHERE period_end - period_begin >= ALL (
    SELECT period_end - period_begin FROM registration
  )
AND period_begin <= ALL (SELECT period_begin FROM registration);
```

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
/*
  From the people who rented a car for the longest time in the db, 
  Get the email adres of the person(s) who started their rental on the
  earliest date
  
  First, get all rentals that where the longest in the database
  Then, find the earliest date in that subtable
  
*/

WITH max_rentals as (
    SELECT *
  FROM registration r
  WHERE r.period_end - r.period_begin >= ALL(
    SELECT r.period_end - r.period_begin FROM registration r
  )
)

SELECT DISTINCT mr.email
FROM max_rentals mr
WHERE mr.period_begin <= ALL(SELECT mr.period_begin FROM max_rentals mr)
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

## 2.1 passed nights between rentals

**Question**: Give for each car in the database that was rented
(registered) at least once, the number of nights that passed by between
the first time that the car was rented (based on period\_begin of the
first registration, exclusive) and the last time that the car was rented
(based on period\_begin of the last registration, inclusive). In the
result table, we expect two columns with corresponding datatype:
license\_plate (varchar) and passed\_nights (integer).

**Answer**:

``` sql
SELECT r.license_plate,
    MAX(r.period_begin) - MIN(r.period_begin) passed_nights 
FROM registration r 
GROUP BY r.license_plate
```

<div class="knitsql-table">

| license\_plate | passed\_nights |
|:---------------|---------------:|
| 1-JRM-104      |            518 |
| 1-XQD-366      |            711 |
| 1-DYC-242      |            698 |
| 1-GJJ-808      |            415 |
| 1-FFL-548      |            241 |
| 1-BBA-267      |            663 |
| 1-ABD-789      |            118 |
| 1-CRI-027      |            522 |
| 1-OBT-368      |            542 |
| 1-VTH-870      |            308 |

Displaying records 1 - 10

</div>

## 2.2 Employee with most rents

**Question**: Give the employee who rented the highest number of unique
cars (so, not the employee that did the highest number of unique car
rentals). In the result table, we expect one column with name email and
datatype varchar. Make sure that your query takes into account ex
aequos.

``` sql
SELECT r.email 
FROM registration r 
INNER JOIN employee e USING(email) -- After inner join, only employees are present
GROUP BY r.email
HAVING COUNT(DISTINCT r.license_plate) >= ALL(
  SELECT COUNT(DISTINCT r.license_plate)  
  FROM registration r  
  INNER JOIN employee e USING(email)  
  GROUP BY r.email 
) 
```

<div class="knitsql-table">

| email                          |
|:-------------------------------|
| <vrinda.greenhalf@outlook.com> |

1 records

</div>

## 2.3 Employee longest rental during his contract

**Question**: Give, for each car brand (so not car model), the total
number of times that an employee rented a car of this brand
himself/herself during his/her contract at the same company that owns
the rented car (i.e. registration.period\_begin should be between
contract.period\_begin and contract.period\_end, boundaries inclusive).
In the result table, we expect two columns with corresponding datatype:
brand (varchar) and amount (integer). Also include brands that are
persisted in the database and for which no car rental meets the
requirements, with an amount of 0. Sort the results first on amount
(numerically descending) and then on brand (alphabetically ascending).

**Answer**:

``` sql
SELECT brand, 
  COALESCE(tmp.amount, 0) amount
FROM (
    SELECT brand, 
      COUNT(*) amount
    FROM registration r
    INNER JOIN employee e USING(email)
    INNER JOIN contract con USING(employeenumber)
    INNER JOIN car c USING(license_plate)
    WHERE r.period_begin >= con.period_begin
    AND  r.period_begin <= con.period_end
    AND con.enterprisenumber = c.enterprisenumber
    GROUP BY c.brand
) tmp
RIGHT JOIN (SELECT DISTINCT c.brand FROM car c) c USING(brand)
ORDER BY amount desc, brand asc
```

<div class="knitsql-table">

| brand         | amount |
|:--------------|-------:|
| Ford          |      3 |
| Kia           |      2 |
| Peugeot       |      2 |
| Renault       |      2 |
| BMW           |      1 |
| Citroën       |      1 |
| Mercedes-Benz |      1 |
| Mini          |      1 |
| Opel          |      1 |
| Audi          |      0 |

Displaying records 1 - 10

</div>

## 2.4 percentage employees and percentage cars

**Question**: Calculate, for each email domain used by an employee, two
different numerical values, which are

-   the percentage share of unique employees using this email domain on
    the total number of unique persons (i.e. employees and
    non-employees) using this email domain (column
    percentage\_employees), and
-   the percentage share of unique cars rented by employees using this
    email domain on the total number of unique cars rented by persons
    (i.e. employees and non-employees) using this email domain (column
    percentage\_cars).

You may assume that domains in an email address start right after the
‘@’ symbol (and that there is only one ‘@’ symbol in an email address)
and end right before the final ‘.’ symbol (e.g. gmail, hotmail,. . . ).
Besides that, you may also assume that all persons did at least one
registration. So, in the result table, we expect three columns with
corresponding datatype: email\_domain (varchar), percentage\_employees
(numeric) and percentage\_cars (numeric). The values in columns
percentage\_employees and percentage\_cars should be between 0 and 100
(boundaries inclusive) and should be rounded up to two decimals

**Answer**:

``` sql
SELECT *
FROM ( -- subquery, get the percentage of employees relative to all people using an emaildomain
       /* 
         First, get the number of people per domain.
       Then, get the number of employees per domain.
       Next, divide the number of employees and number of people.
       The resulting table is the relative frequency of employees per domain
       */
       SELECT email_domain, 
            ROUND(100 * coalesce(amount_employee, 0)::decimal / amount_people, 2) percentage_employees
       FROM ( -- number of people in with domain
              SELECT SUBSTRING(p.email, '(?<=@).*(?=\.)') email_domain, 
                    COUNT(*) amount_people
              FROM person p
              GROUP BY SUBSTRING(p.email, '(?<=@).*(?=\.)')
       ) tmp
       LEFT JOIN ( -- number of employees with domain
                   SELECT SUBSTRING(e.email, '(?<=@).*(?=\.)') email_domain, 
                        COUNT(*) amount_employee
                   FROM employee e
                   GROUP BY SUBSTRING(e.email, '(?<=@).*(?=\.)')
       ) tmp2 USING(email_domain)
) tmp
LEFT JOIN (
    SELECT email_domain, 
        ROUND(100 * coalesce(rentals_employee, 0)::decimal / rentals_total, 2) percentage_cars
    FROM ( -- Number of unique cars rented by people using domain
        SELECT SUBSTRING(p.email, '(?<=@).*(?=\.)') email_domain, 
            COUNT(DISTINCT r.license_plate) rentals_total
        FROM registration r
        INNER JOIN person p USING(email)
        GROUP BY SUBSTRING(p.email, '(?<=@).*(?=\.)')
    ) tmp
    LEFT JOIN ( -- Number of unique cars rented by employees using domain 
        SELECT SUBSTRING(e.email, '(?<=@).*(?=\.)') email_domain, 
            COUNT(DISTINCT r.license_plate) rentals_employee
        FROM registration r
        INNER JOIN employee e USING(email)
        GROUP BY SUBSTRING(e.email, '(?<=@).*(?=\.)')
    ) tmp2 USING(email_domain)
) tmp2 USING(email_domain)
WHERE tmp.percentage_employees > 0
```

<div class="knitsql-table">

| email\_domain | percentage\_employees | percentage\_cars |
|:--------------|----------------------:|-----------------:|
| coulbeck      |                100.00 |           100.00 |
| fetherby      |                100.00 |           100.00 |
| gmail         |                 22.97 |            36.94 |
| hotmail       |                 13.64 |            19.70 |
| keep          |                100.00 |           100.00 |
| loughrey      |                100.00 |           100.00 |
| mail          |                  9.52 |            12.94 |
| mccane        |                100.00 |           100.00 |
| mildner       |                100.00 |           100.00 |
| msn           |                 25.00 |            39.55 |

Displaying records 1 - 10

</div>

## 2.5 Absolute deviation

**Question**: Return the license plate of the car of which the total
number of times that this car was rented, is the closest to the average
number of times that a car is rented (computed over all cars present in
the database). Be aware of the fact that, in order to calculate the
average, you should also take into account the cars that have never been
rented before. In the result table, only one column license\_plate of
datatype varchar is expected. Make sure that your query takes into
account ex aequos.

**Answer**:

``` sql
/*
  a table with a license_plate, a number of times it was rented,
  and the absolute deviation from the mean amount of rentals
*/
WITH amounts as (
  SELECT license_plate, 
    amts.amount,
    abs(amts.amount - (avg(amts.amount) OVER())) residual
  FROM ( -- get a table of every car with the amount of times it was rented
    SELECT c.license_plate,
      COALESCE(tmp.amount, 0) amount
    FROM car c 
    LEFT JOIN ( -- For every car, add the amount the car was rented
      SELECT r.license_plate,
        COUNT(*) amount
      FROM registration r
      GROUP BY(r.license_plate)
    ) tmp USING(license_plate)
  ) amts
)
SELECT amts.license_plate
FROM  amounts amts
WHERE amts.residual <= ALL( -- get the least residual from the residual tables
  SELECT MIN(amts.residual) FROM amounts amts
)
```

<div class="knitsql-table">

| license\_plate |
|:---------------|
| 1-RYJ-867      |
| 1-FVO-234      |
| 1-EXP-282      |
| 1-YQL-135      |
| 1-RBT-549      |
| 1-DDP-931      |
| 1-LWY-156      |
| 1-JHX-312      |
| 1-HXY-484      |
| 1-FDH-025      |

Displaying records 1 - 10

</div>
