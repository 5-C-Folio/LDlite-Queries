select hrid, identifiers__value  from inventory.instance__t__identifiers
where identifiers__identifier_type_id ='11effde5-6bf4-49ac-b9a4-040ef765ed88'
and hrid in (select hrid
	from inventory.instance__t__identifiers
	where identifiers__identifier_type_id ='11effde5-6bf4-49ac-b9a4-040ef765ed88'
	and identifiers__value in (select * from public.sup_bibs_2022_07_15))
