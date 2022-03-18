/* Get all license plates for cars that were only rented by the same person */
SELECT r1.license_plate, 
  COUNT(DISTINCT r1.email) number_of_distinct_renters -- Count number of distinct renters
FROM registration r1
GROUP BY r1.license_plate
HAVING COUNT(DISTINCT r1.email) = 1 --Only return rows where there is one distinct renter
