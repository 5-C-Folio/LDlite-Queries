select
	regexp_replace(it2.title , E'[\\n\\r]+', ' ', 'g' ) as "Title",
	case 
		when substring(iti1.identifiers__value from '^[^\s]*') is not null then substring(iti1.identifiers__value from '^[^\s]*')
		when substring(iti2.identifiers__value from '^[^\s]*') is not null then substring(iti2.identifiers__value from '^[^\s]*')
		else ''
		--to do, only bring in the first ISBN, to remove the need to deduplicate on other columns
	end "ISSN/ISBN",
	iti3.identifiers__value as "OCLC#",
	coalesce(itc.contributors__name, 'blank') as "Collection",
	--again to do, take only the first corpo name
	hrtea.electronic_access__uri as "Call number/URL",
	hrths.holdings_statements__statement as "Years/volumes"
from inventory.item__t it 
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id 
	left join inventory.instance__t it2 on it2.id = hrt.instance_id 
	left join inventory.location__t lt on lt.id = it.effective_location_id 
	left join inventory.material_type__t mtt on mtt.id = it.material_type_id 
	left join inventory.instance__t__identifiers iti1 on iti1.id = it2.id and iti1.identifiers__identifier_type_id = '913300b2-03ed-469a-8179-c1092c991227' --ISSN
	left join inventory.instance__t__identifiers iti2 on iti2.id = it2.id and iti2.identifiers__identifier_type_id = '8261054f-be78-422d-bd51-4ed9f33c3422' --ISBN
	left join inventory.instance__t__identifiers iti3 on iti3.id = it2.id and iti3.identifiers__identifier_type_id = '439bfbae-75bc-4f74-9fc7-b2a2d47ce3ef' --OCN
	left join inventory.instance__t__contributors itc on itc.id = it2.id and itc.contributors__contributor_name_type_id = 'f5bda109-a719-4f72-b797-b9c22f45e4e1' --corpo name
	left join inventory.holdings_record__t__electronic_access hrtea on hrtea.id = hrt.id
	left join inventory.holdings_record__t__holdings_statements hrths on hrths.id = hrt.id
where lt."name" = 'SC Internet'
	and mtt."name" = 'E-Journal'