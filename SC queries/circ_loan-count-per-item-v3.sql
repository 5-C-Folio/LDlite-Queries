select
	it2.title as "Title",
	lt."name" as "Location",
	it.barcode as "Barcode",
	coalesce(count(alt.id), 0) as "FOLIO circulations",
	coalesce(itn.notes__note::bigint, 0) as "Aleph circulations",
	coalesce(coalesce(itn.notes__note::bigint, 0)+coalesce(count(alt.id), 0),0) as "Total count"
from inventory.item__t it 
	left join inventory.item__t__notes itn on itn.id = it.id and itn.notes__item_note_type_id = 'f765f19f-9f1c-4688-8c79-ec366a730842'
	left join circulation.audit_loan__t alt on alt.loan__item_id = it.id and alt.loan__action = 'checkedout'
	left join inventory.location__t lt on lt.id = it.effective_location_id
	left join inventory.material_type__t mtt on mtt.id = it.material_type_id 
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id 
	left join inventory.instance__t it2 on it2.id = hrt.instance_id 
where lt.campus_id = '7d02e46d-3e60-4eaf-a986-5aa3550e8cb5'
	and mtt."name" in ('Book', 'Government Publication', 'Image', 'Journal', 'Map', 'Newspaper', 'Score', 'Serial', 'Supplement', 'Thesis/Dissertation')
	and it.barcode not in ('310183693606393', '312066001709011', '312066001950696', '312066034132527', '312066037561753', '312066038570126')
/*and it.barcode in ('008267-AMH', -- 5 and 33
					'008259-AMH', -- 1 and 28
					'008264-AMH', -- 3 and 24
					'310183610798182', -- 1 and 0
					'310183610862863', -- 1 and null
					'310183604609248', -- null and null
					'310212300222209') -- null and 4 */
group by it2.title, lt."name", it.barcode, itn.notes__note
having coalesce(coalesce(itn.notes__note::bigint, 0)+coalesce(count(alt.id), 0),0) > 0
order by coalesce(coalesce(itn.notes__note::bigint, 0)+coalesce(count(alt.id), 0),0) desc
--limit 50