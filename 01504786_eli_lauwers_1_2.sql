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
