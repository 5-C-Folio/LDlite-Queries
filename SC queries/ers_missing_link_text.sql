select
	hrtea.id, 
	hrtea.electronic_access__uri
	--hrtea.electronic_access__link_text 
from inventory.holdings_record__t__electronic_access hrtea
	left join inventory.location__t lt on lt.id = hrtea.permanent_location_id 
where hrtea.electronic_access__link_text = ''
	and hrtea.electronic_access__uri not like '%gale:SMIT%'
	and lt."name" = 'SC Internet'
	--and hrtea.hrid = 'ho00004853070'