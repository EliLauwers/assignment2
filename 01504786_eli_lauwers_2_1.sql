SELECT r.license_plate,
    MAX(r.period_begin) - MIN(r.period_begin) passed_nights 
FROM registration r 
GROUP BY r.license_plate
/* 
  Excluce vehicles that were only rented once. For those vehicles, there will only be one registered email
*/
HAVING COUNT(r.email) > 1