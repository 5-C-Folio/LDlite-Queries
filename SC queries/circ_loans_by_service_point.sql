select
	extract(year from TO_DATE(alt.loan__loan_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"')) AS "year",
	extract(month from TO_DATE(alt.loan__loan_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"')) AS "month",
--	TO_DATE(alt.loan__loan_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"') AS "date",
	sp.name as service_point,
	count(distinct alt.loan__id) as loans
from circulation.audit_loan__t alt
inner join inventory.location__t lt on lt.primary_service_point = alt.loan__checkout_service_point_id
left join inventory.service_point__t sp on sp.id = alt.loan__checkout_service_point_id
where 
	alt.loan__action in ('checkedout', 'checkedOutThroughOverride') and 
	lt.campus_id = '7d02e46d-3e60-4eaf-a986-5aa3550e8cb5'
group by service_point,
	extract(year from TO_DATE(alt.loan__loan_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"')),
	extract(month from TO_DATE(alt.loan__loan_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"'))
--	TO_DATE(alt.loan__loan_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"')
order by "year", "month", service_point