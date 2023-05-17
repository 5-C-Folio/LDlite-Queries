with 
parameters AS (
    SELECT
      '{Institution Code (AC, HC, MH, SC, UM)}':: VARCHAR AS institution, --Use this line if using the LDlite Reporting Tool
      '{Semester (YYYY Spring/Summer/Fall Winter)}':: VARCHAR AS semester --Use this line if using the LDlite Reporting Tool
	  --'UM':: VARCHAR AS institution, --Use this line if NOT using the LDlite Reporting Tool
      --'2023 Summer':: VARCHAR AS semester --Use this line if NOT using the LDlite Reporting Tool
   )
select
    distinct 
    reserves.item_id as "Item ID"
    --reserves.copied_item__barcode,
    --reserves.copied_item__title "Title",
    --locations."name" as "Temp Location",
    --courses.course_listing_object__term_id as "Term ID",
    --courses.name,
    --terms."name" as "Term",
    --temploantype."name" 
from
    courses.coursereserves_reserves__t reserves
    join inventory.item__t as items on items.id = reserves.item_id 
    join courses.coursereserves_courses__t as courses on reserves.course_listing_id = courses.course_listing_id
    join inventory.location__t as locations on courses.course_listing_object__location_id  = locations.id
    join courses.coursereserves_terms__t as terms on courses.course_listing_object__term_id = terms.id
    join inventory.loan_type__t as temploantype on temploantype.id = items.temporary_loan_type_id
where locations."name" like (select institution from parameters) || '%'
and terms."name" = (select semester from parameters)