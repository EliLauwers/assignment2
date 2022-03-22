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
