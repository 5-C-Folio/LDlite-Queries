select
	count(distinct alt.id)
from circulation.audit_loan__t alt
	left join inventory.location__t lt on lt.id = alt.loan__item_effective_location_id_at_check_out 
	left join users.users__t ut on ut.id = alt.loan__user_id 
	left join inventory.item__t it on it.id = alt.loan__item_id 
	left join inventory.material_type__t mtt on mtt.id = it.material_type_id 
where alt.loan__action in ('checkedout', 'checkedOutThroughOverride') and 
	lt.campus_id not in ('7d02e46d-3e60-4eaf-a986-5aa3550e8cb5',  --Smith
	'b23a14ae-b3a8-4cbf-92fb-4b81d1a4b0a1') --Repository
	and mtt.name <> 'Equipment'
	and alt.loan__loan_date between '2022-07-01' and '2023-06-30'
	and ut.external_system_id like '%smith.edu'