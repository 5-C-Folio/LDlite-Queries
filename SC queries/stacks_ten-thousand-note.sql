select distinct
	it.index_title as "Title",
	substring(m.content, 8, 4) AS "Pub date",
	lt."name" as "Holdings location",
	itcn.barcode as "Barcode",
	itcn.volume as "Volume",
	itcn.copy_number as "Copy",
	itn.notes__note as "Legacy circ"
from inventory.item__t__circulation_notes itcn
	left join inventory.holdings_record__t hrt on hrt.id = itcn.holdings_record_id 
	left join inventory.location__t lt on lt.id = hrt.permanent_location_id
	left join inventory.instance__t it on it.id = hrt.instance_id 
	left join inventory.item__t__notes itn on itcn.id = itn.id
	left join folio_source_record.marctab AS m ON it.id::uuid = m.instance_id
where itcn.circulation_notes__note = 'Transfer to Annex for stream separation. I am one of the 10000s'
	and itn.notes__item_note_type_id = 'f765f19f-9f1c-4688-8c79-ec366a730842'
	and m.field = '008'
	--and itcn.barcode = '310183611131763'