select 
	it2.title,
	it2.hrid as "instance HRID",
	m."content" as "MARC 362",
	it.effective_call_number_components__call_number as "item call#",
	hrths.holdings_statements__statement as "holdings statement",
	it.barcode,
	it.copy_number, 
	it.volume,
	it.enumeration,
	it.chronology,
	itn.notes__note as "item note"
from inventory.item__t it 
	left join inventory.item__t__notes itn on itn.id= it.id and itn.notes__note <> it.volume and itn.notes__item_note_type_id = 'c7bc292c-a318-43d3-9b03-7a40dfba046a'
	left join inventory.location__t lt on lt.id = it.effective_location_id 
	left join inventory.holdings_record__t hrt on hrt.id = it.holdings_record_id 
	left join inventory.holdings_record__t__holdings_statements hrths on hrths.id = hrt.id
	left join inventory.instance__t it2 on it2.id = hrt.instance_id 
	left join inventory.mode_of_issuance__t moit on moit.id = it2.mode_of_issuance_id 
	left join folio_source_record.marctab m on m.instance_hrid = it2.hrid and m.field = '362' and m.sf = 'a'
where moit."name" = 'Serial'
	and (it.barcode not like '%-SMT' or it.barcode not like '%-SC')
	and  lt."name" = 'SC Annex Stacks'
	and it2.hrid in (
		select instancesub1.hrid
		from inventory.item__t itemsub1
		left join inventory.holdings_record__t holdingssub1 on holdingssub1.id = itemsub1.holdings_record_id
		left join inventory.instance__t instancesub1 on instancesub1.id = holdingssub1.instance_id
		left join inventory.location__t locsub1 on locsub1.id = itemsub1.effective_location_id
		where locsub1.library_id = '6bb6c83a-dd37-43dd-bf4d-bea653be401a' --Annex
		EXCEPT
		select instancesub2.hrid
		from inventory.item__t itemsub2
		left join inventory.holdings_record__t holdingssub2 on holdingssub2.id = itemsub2.holdings_record_id
		left join inventory.instance__t instancesub2 on instancesub2.id = holdingssub2.instance_id
		left join inventory.location__t locsub2 on locsub2.id = itemsub2.effective_location_id
		where locsub2.library_id in ('b9a3e61b-26cf-4d23-a24a-1e339c61a646', '2d9fc0a4-5ff0-4c19-a819-910f090614bc', 'd541a5ab-50d8-4822-83fc-8469ddfcbb57')) --Hillyer, Josten, Neilson
	--and it2.hrid in ('in00004333387', 'in00000149896') --show the first title, not the second
--group by it2.hrid,1,3,4,5,6,7,8,9,10,11
--order by it.effective_call_number_components__call_number, it.volume