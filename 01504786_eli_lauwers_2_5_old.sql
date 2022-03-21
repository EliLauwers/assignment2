SELECT tmp.license_plate
FROM (
	SELECT license_plate, 
		amts.amount,
		abs(amts.amount - (avg(amts.amount) OVER())) residual
	FROM(
		SELECT c.license_plate,
			COALESCE(tmp.amount, 0) amount
		FROM car c 
		LEFT JOIN (
			SELECT r.license_plate,
				COUNT(*) amount
			FROM registration r
			GROUP BY(r.license_plate)
		) tmp USING(license_plate)
	) amts
) tmp 
WHERE tmp.residual <= ALL(
	SELECT MIN(tmp.residual)
	FROM (
	SELECT license_plate, 
		amts.amount,
		abs(amts.amount - (avg(amts.amount) OVER())) residual
	FROM(
		SELECT c.license_plate,
			COALESCE(tmp.amount, 0) amount
		FROM car c 
		LEFT JOIN (
			SELECT r.license_plate,
				COUNT(*) amount
			FROM registration r
			GROUP BY(r.license_plate)
		) tmp USING(license_plate)
	) amts
) tmp 
)
