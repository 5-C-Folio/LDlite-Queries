select holdings_record_id 
from inventory.item__t
where item__t.effective_location_id in ('8429f99f-bd18-4f1b-be4b-3e8b29afe573', '0bd310b3-17b0-41cd-8ebb-09715ca36958', '08d8a4d8-ed03-4a9e-b194-986756b818df')
--FC monos, FC Annex, FC serials
group by holdings_record_id
having count(distinct item__t.id) = '1'