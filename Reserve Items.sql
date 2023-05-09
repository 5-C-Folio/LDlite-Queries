with 
parameters AS (
    SELECT
      '{Institution Code (AC, HC, MH, SC, UM)}':: VARCHAR AS institution, --Change this value to the earliest date you want to see
      '{Semester (YYYY Spring/Summer/Fall Winter)}':: VARCHAR AS semester --Change this value to the latest date you want to see
  )
select
    distinct 
    reserves.item_id as "Item ID",
    reserves.copied_item__barcode,
    reserves.copied_item__title "Title",
    locations."name" as "Temp Location",
    courses.course_listing_object__term_id as "Term ID",
    courses.name,
    terms."name" as "Term",
    temploantype."name" 
from
    courses.coursereserves_reserves__t reserves
    join inventory.item__t as items on items.id = reserves.item_id 
    join inventory.location__t locations on items.temporary_location_id  = locations.id
    join courses.coursereserves_courses__t courses on reserves.course_listing_id = courses.course_listing_id
    join courses.coursereserves_terms__t terms on courses.course_listing_object__term_id = terms.id
    join inventory.loan_type__t as temploantype on temploantype.id = items.temporary_loan_type_id
where CURRENT_DATE >= courses.course_listing_object__term_object__start_date::date
and locations."name" like (select institution from parameters) || '%'
and temploantype."name" = 'Reserve 4 Hour'