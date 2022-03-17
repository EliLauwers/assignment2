SELECT DISTINCT tmp.email
FROM (
  /* Subquery: get the rows with maximum rental period */
    SELECT *
    FROM registration r
  WHERE r.period_end - r.period_begin >= ALL(
    SELECT r.period_end - r.period_begin FROM registration r
  )
) tmp
WHERE tmp.period_begin <= ALL(
  /* Subquery: get the rows with maximum rental period */
    SELECT r.period_begin
  FROM registration r
  WHERE r.period_end - r.period_begin >= ALL(
    SELECT r.period_end - r.period_begin FROM registration r
  )
)