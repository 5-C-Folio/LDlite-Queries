select
	it.barcode,
	coalesce(count(alt.id), 0) as FOLIO_count,
	coalesce(itn.notes__note::bigint, 0) as legacy_count,
	coalesce(coalesce(itn.notes__note::bigint, 0)+coalesce(count(alt.id), 0),0) as "Total Circ Count"
from inventory.item__t it 
	left join inventory.item__t__notes itn on 
		itn.id = it.id and itn.notes__item_note_type_id = 'f765f19f-9f1c-4688-8c79-ec366a730842'
	left join circulation.audit_loan__t alt on 
		alt.loan__item_id = it.id and alt.loan__action = 'checkedout'
	left join inventory.location__t lt on 
		lt.id = it.effective_location_id 
where lt.campus_id = '7d02e46d-3e60-4eaf-a986-5aa3550e8cb5' 
/*and it.barcode in ('008267-AMH', -- 5 and 33
					'008259-AMH', -- 1 and 28
					'008264-AMH', -- 3 and 24
					'310183610798182', -- 1 and 0
					'310183610862863', -- 1 and null
					'310183604609248', -- null and null
					'310212300222209') -- null and 4 */
group by it.barcode, itn.notes__note