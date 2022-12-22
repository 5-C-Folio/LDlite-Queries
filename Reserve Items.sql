select
    distinct reserves.item_id as "Item ID",
    reserves.copied_item__barcode as "Item Barcode",
    reserves.copied_item__title "Title",
    locations."name" as "Temp Location",
    courses.course_listing_object__term_id as "Term ID",
    --courses.name,
    terms."name" as "Term"
from
    courses.coursereserves_reserves__t reserves
    inner join inventory.location__t locations on reserves.copied_item__temporary_location_id = locations.id
    inner join courses.coursereserves_courses__t courses on courses.course_listing_id = courses.course_listing_object__id
    inner join courses.coursereserves_terms__t terms on courses.course_listing_object__term_id = terms.id
where terms."name" like '{Term Name (YYYY Fall/Winter/Spring/Summer): }'