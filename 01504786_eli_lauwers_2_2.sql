/* Subquery: for every employee, get all distinct rented cars */
SELECT r.email
FROM registration r
INNER JOIN employee e USING(email)
GROUP BY r.email
HAVING COUNT(DISTINCT r.license_plate) >= ALL(
	SELECT COUNT(DISTINCT r.license_plate)
	FROM registration r
	INNER JOIN employee e USING(email)
	GROUP BY r.email
)
