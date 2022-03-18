SELECT brand, COALESCE(tmp.amount, 0) amount
FROM (
  SELECT brand, COUNT(*) amount
  FROM (
    SELECT *
      FROM registration r
    INNER JOIN employee e USING(email)
    INNER JOIN contract con USING(employeenumber)
    INNER JOIN car c USING(license_plate)
    WHERE r.period_begin >= con.period_begin
    AND  r.period_begin <= con.period_end
    AND con.enterprisenumber = c.enterprisenumber
  ) tmp
  GROUP BY brand
) tmp
RIGHT JOIN (SELECT DISTINCT c.brand FROM car c) c USING(brand)
ORDER BY amount desc, brand asc
