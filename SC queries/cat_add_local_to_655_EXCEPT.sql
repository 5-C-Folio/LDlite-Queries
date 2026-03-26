select 
	n.srs_id,
	n.instance_hrid,
	n.instance_id 
from folio_source_record.marctab n
--LEFT JOIN inventory.holdings_record__t hrt ON cast(hrt.instance_id as uuid) = n.instance_id
--LEFT JOIN inventory.location__t lt ON lt.id = hrt.permanent_location_id
where 
    n.field = '655' and n."content" like 'Electronic books%'
    --and lt.code = 'SCINT'
EXCEPT
select
    m.srs_id,
    m.instance_hrid,
    m.instance_id
from (
	select 
	    m.srs_id,
	    m.instance_hrid,
	    m.instance_id
	from folio_source_record.marctab m 
	where m.field = '655' and m."content" like 'Electronic books%'
    ) as m,  
    folio_source_record.marctab as m2
where m.srs_id=m2.srs_id and m2.field = '655' and m2."content" like '%local%'
--
--
--
--
--
--example for deletion in00000779410