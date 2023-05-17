WITH parameters as (
	SELECT
		'{Expiration Date (YYYY-MM-DD)}'::date AS "expirationDate", 
		'{Institution (AC, MH, HC, SC, UM)}' as "institution")
select users.barcode, 
	   string_agg(distinct users.personal__last_name||', '||users.personal__first_name, '') as "Patron Name",
	   string_agg(distinct users.personal__email::text, '') as "Patron Email Address",
	   count(loan.id) as "Open Loan Count"
from users.users__t as users
join users.groups__t as patrongroup on
users.patron_group = patrongroup.id
join circulation.loan__t as loan on
loan.user_id = users.id
where
patrongroup."group" = 'Undergraduate'
and case
	when (select institution from parameters) = 'AC' then users.external_system_id like '%@amherst.edu'
	when (select institution from parameters) = 'HC' then users.external_system_id like '%@hampshire.edu'
	when (select institution from parameters) = 'MH' then users.external_system_id like '%@mtholyoke.edu'
	when (select institution from parameters) = 'SC' then users.external_system_id like '%@smith.edu'
	when (select institution from parameters) = 'UM' then users.external_system_id like '%@umass.edu'
	end
and loan.status__name = 'Open'
and users.expiration_date::date = (select "expirationDate" from parameters)
group by
users.barcode