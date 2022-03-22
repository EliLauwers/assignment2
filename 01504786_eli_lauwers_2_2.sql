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
