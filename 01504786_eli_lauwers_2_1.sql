SELECT r.license_plate,
    MAX(r.period_begin) - MIN(r.period_begin) passed_nights 
FROM registration r 
GROUP BY r.license_plate
HAVING COUNT(r.email) > 1 -- Excluce vehicles that were only rented once
