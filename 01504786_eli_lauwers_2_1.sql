SELECT r.license_plate, 
MAX(r.period_begin) - MIN(r.period_begin) passed_nights
FROM registration r
GROUP BY r.license_plate
