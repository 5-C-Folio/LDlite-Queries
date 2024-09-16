select 
	count(it.id) as "Number of items",
	ll."name" as "Library"
from inventory.item__t it
	left join inventory.location__t lt on it.effective_location_id = lt.id
	left join inventory.loclibrary__t ll on lt.library_id = ll.id  
	left join inventory.material_type__t mt on it.material_type_id = mt.id 
where ll."name" in ('SC Annex', 'SC Hillyer Art Library', 'SC Josten Library', 'SC Neilson Library')
	and lt."name" != 'SC Internet'
	and mt.name in ('Book', 'Government Publication', 'Image', 'Journal', 'Map', 'Newspaper', 'Score', 'Serial', 'Supplement', 'Thesis/Dissertation')
group by ll."name"