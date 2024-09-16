select distinct
	it.barcode,
	alt.*
from circulation.audit_loan__t alt
	left outer join circulation.loan__t loans on loans.item_id = alt.loan__item_id
	left join inventory.location__t lt on lt.primary_service_point = alt.loan__checkout_service_point_id
	left join inventory.item__t it on alt.loan__item_id = it.id 
where
alt.loan__action in ('checkedout', 'checkedOutThroughOverride') and 
	lt.campus_id = '7d02e46d-3e60-4eaf-a986-5aa3550e8cb5'
	and alt.loan__loan_date between '2023-12-01' and '2023-12-31'
	and alt.loan__item_id = '1630703e-5153-55ed-aee0-3f226003c7bc'
order by alt.created_date 










/*
	extract(year from TO_DATE(alt.loan__loan_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"')) AS "year",
	extract(month from TO_DATE(alt.loan__loan_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"')) AS "month",
--	TO_DATE(alt.loan_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"') AS "date",
	sp.name as service_point,
	count(alt.id) as loans
from circulation.audit_loan__t alt 
inner join inventory.location__t lt on lt.primary_service_point = alt.loan__checkout_service_point_id
left join inventory.service_point__t sp on sp.id = alt.loan__checkout_service_point_id
where 
	alt.loan__action in ('checkedout', 'checkedOutThroughOverride') and 
	lt.campus_id = '7d02e46d-3e60-4eaf-a986-5aa3550e8cb5'
	and alt.loan__item_id not in (
		select loans.item_id
		from circulation.loan__t loans
			inner join inventory.location__t lt on lt.primary_service_point = loans.checkout_service_point_id
			left join inventory.service_point__t sp on sp.id = loans.checkout_service_point_id
		where 
			loans.action in ('checkedout', 'checkedOutThroughOverride') and 
			lt.campus_id = '7d02e46d-3e60-4eaf-a986-5aa3550e8cb5')
group by service_point,
	extract(year from TO_DATE(alt.loan__loan_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"')),
	extract(month from TO_DATE(alt.loan__loan_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"'))

order by "year", "month", service_point

*/