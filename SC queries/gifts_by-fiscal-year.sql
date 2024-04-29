select
	it.title as "Title",
	lt."name" as "Location",
	hrt.call_number as "Call number",
	itn.barcode as "Barcode",
	itn.volume as "Description",
	mtt."name" as "Format",
	itn.notes__note as "Gift note",
	cast(substring(it2.metadata__created_date, 0, 11) as date) as "Accession date"
from inventory.item__t__notes itn 
	left join inventory.location__t lt on itn.effective_location_id = lt.id 
	left join inventory.material_type__t mtt on itn.material_type_id = mtt.id 
	left join inventory.holdings_record__t hrt on itn.holdings_record_id = hrt.id 
	left join inventory.instance__t it on hrt.instance_id =it.id 
	left join inventory.item__t it2 on it2.id = itn.id 
where itn.notes__item_note_type_id = 'a28539e9-21ce-40f1-9b64-b1faf4e189c0'  -- "Gift note"
	and lt.campus_id = '7d02e46d-3e60-4eaf-a986-5aa3550e8cb5'  -- "Smith College"
	and cast(substring(it2.metadata__created_date, 0, 11) as date) between '2022-07-01' and '2023-06-30'
group by hrt.call_number, itn.volume, lt."name", it.title, itn.barcode, mtt."name", itn.notes__note, it2.metadata__created_date 