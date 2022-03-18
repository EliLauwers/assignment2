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
        /* All email adresses of people who have registrations at different enterprises */
        SELECT DISTINCT r1.email
        FROM ( 
            SELECT *    
            FROM registration r    
            INNER JOIN car c USING(license_plate)
        ) r1 -- r1 => link a registration to a cars owning enterprise
        INNER JOIN (
                SELECT *
                FROM registration r
                INNER JOIN car c USING(license_plate)
        ) r2 -- Same as r2
        ON r1.email = r2.email 
        AND r1.enterprisenumber != r2.enterprisenumber 
)
