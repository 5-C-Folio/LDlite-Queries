select 
	it.it,
	it.hrid,
	it.title,
	
from inventory.instance__t it
	left join folio_source_record.marctab m on it.hrid = m.instance_hrid
	left join inventory.instance__t__statistical_code_ids stat on it.id = stat.id
where it."source" = 'MARC' and m.instance_hrid is null
	and (it.id not in )  --how do you say not in a table, or if in a table, not this code?