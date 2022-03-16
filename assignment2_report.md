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

# 2 Rewrite

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
distinct enterprise(number)’.

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
