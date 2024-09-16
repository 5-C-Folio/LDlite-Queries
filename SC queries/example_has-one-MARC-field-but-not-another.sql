select n.srs_id, n.instance_hrid
from folio_source_record.marctab n
where n.field = '000'
EXCEPT
select m.srs_id, m.instance_hrid
from folio_source_record.marctab m
where m.field = '008'