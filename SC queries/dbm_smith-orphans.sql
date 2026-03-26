SELECT 
	it.hrid AS "instance hrid",
	it.id as "instance UUID",
	it.title,
	iti2.identifiers__value as "OCN",
	it.discovery_suppress  AS "suppressed from discovery",
	it.staff_suppress,
	sct.code AS "stat code",
	it."source",
	it.metadata__updated_date::date,
	m."content" as "998$a",
	m2."content" as "EAST",
	plt.payment_status
FROM         
	inventory.instance__t it 
	LEFT JOIN inventory.holdings_record__t hrt ON it.id = hrt.instance_id 
	LEFT JOIN inventory.instance__t__statistical_code_ids itsci ON itsci.id = it.id 
	LEFT JOIN inventory.statistical_code__t sct ON sct.id = itsci.statistical_code_ids 
	LEFT JOIN users.users__t ut ON ut.id = it.metadata__updated_by_user_id 
	left join orders.po_line__t plt on plt.instance_id = it.id
	left join inventory.instance__t__identifiers iti on iti.id = it.id and iti.identifiers__identifier_type_id = '7e591197-f335-4afb-bc6d-a6d76ca3bace' and iti.identifiers__value like '%LKR)%'
	left join inventory.instance__t__identifiers iti2 on iti2.id = it.id and iti2.identifiers__identifier_type_id = '439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef'
	left join folio_source_record.marctab m on m.instance_hrid::varchar = it.hrid and m.field = '998' and m.sf = 'a'
	left join folio_source_record.marctab m2 on m2.instance_hrid::varchar = it.hrid and m2.field = '583' and m2.sf = 'z' and m2."content" = 'Smith copy: EAST commitment'
WHERE hrt.id IS NULL 
	--AND it.metadata__created_date::date >= '2022-07-01'
	AND it.title NOT LIKE '%TEMPLATE%'
	and (split_part(ut.username, '@', 2) = 'smith.edu' or m."content" = 'SM')
	and (it.discovery_suppress = false or it.staff_suppress = false or (sct.code <> 'DELETE' or sct.code is null))
	and (plt.payment_status <> 'Pending' or plt.payment_status is null)
	and iti.identifiers__value is null