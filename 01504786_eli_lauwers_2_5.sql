WITH amounts as (
  SELECT license_plate, 
    amts.amount,
    abs(amts.amount - (avg(amts.amount) OVER())) residual
  FROM (
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
)
SELECT amts.license_plate
FROM  amounts amts
WHERE amts.residual <= ALL(
  SELECT MIN(amts.residual) FROM amounts amts
)
