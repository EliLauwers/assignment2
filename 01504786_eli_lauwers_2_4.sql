SELECT *
FROM ( -- subquery, get the percentage of employees relative to all people using an emaildomain
       /* 
         First, get the number of people per domain.
       Then, get the number of employees per domain.
       Next, divide the number of employees and number of people.
       The resulting table is the relative frequency of employees per domain
       */
       SELECT email_domain, 
       		ROUND(100 * coalesce(amount_employee, 0)::decimal / amount_people, 2) percentage_employees
       FROM ( -- number of people in with domain
              SELECT SUBSTRING(p.email, '(?<=@).*(?=\.)') email_domain, 
              		COUNT(*) amount_people
              FROM person p
              GROUP BY SUBSTRING(p.email, '(?<=@).*(?=\.)')
       ) tmp
       LEFT JOIN ( -- number of employees with domain
                   SELECT SUBSTRING(e.email, '(?<=@).*(?=\.)') email_domain, 
                   		COUNT(*) amount_employee
                   FROM employee e
                   GROUP BY SUBSTRING(e.email, '(?<=@).*(?=\.)')
       ) tmp2 USING(email_domain)
) tmp
LEFT JOIN (
	SELECT email_domain, 
		ROUND(100 * coalesce(rentals_employee, 0)::decimal / rentals_total, 2) percentage_cars
	FROM ( -- Number of unique cars rented by people using domain
		SELECT SUBSTRING(p.email, '(?<=@).*(?=\.)') email_domain, 
			COUNT(DISTINCT r.license_plate) rentals_total
		FROM registration r
		INNER JOIN person p USING(email)
		GROUP BY SUBSTRING(p.email, '(?<=@).*(?=\.)')
	) tmp
	LEFT JOIN ( -- Number of unique cars rented by employees using domain 
		SELECT SUBSTRING(e.email, '(?<=@).*(?=\.)') email_domain, 
			COUNT(DISTINCT r.license_plate) rentals_employee
		FROM registration r
		INNER JOIN employee e USING(email)
		GROUP BY SUBSTRING(e.email, '(?<=@).*(?=\.)')
	) tmp2 USING(email_domain)
) tmp2 USING(email_domain)
WHERE tmp.percentage_employees > 0


