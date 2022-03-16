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
