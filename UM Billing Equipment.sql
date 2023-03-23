with
  parameters AS (
    SELECT
      '{Start Date (YYYY-MM-DD)}':: VARCHAR AS start_date, --Change this value to the earliest date you want to see
      '{End Date (YYYY-MM-DD)}':: VARCHAR AS end_date --Change this value to the latest date you want to see
  )
select
  accounts.id as "Fee/Fine ID",
  --users.barcode as "Patron Barcode",
  case
    when users.external_system_id like '%@%' then substring(
      users.external_system_id
      from
        '[1234567890]*'
    )
    else users.external_system_id
  end as "University ID",
  --users.personal__email as "Patron Email",
  patron_groups.group as "Patron Group",
  substring(accounts.metadata__created_date, 0, 11) as "Billed Date",
  substring(actions.date_action, 0, 11) as "Transaction Date",
  actions.type_action as "Transaction Description",
  case
    when actions.type_action in (
      'Credited fully',
      'Waived fully',
      'Cancelled item declared lost',
      'Waived partially',
      'Paid fully',
      'Cancelled item renewed',
      'Cancelled item returned',
      'Refunded fully'
    ) then actions.amount_action * -1
    when actions.type_action in (
      'Hourly Equipment Replacement Bill',
      'General Library Charge',
      'Daily Equipment Replacement Bill',
      'ILL Replacement',
      'Overdue fine',
      'Lost item processing fee',
      'Lost item fee',
      'Staff info only'
    ) then actions.amount_action
    else '0'
  end as "Transaction Amount",
  accounts.barcode as "Item Barcode",
  users.personal__last_name || ', ' || users.personal__first_name as "Patron name",
  accounts.title as "Item title",
  accounts.fee_fine_owner as "FeeFine Owner",
  locations.name as "Item Location at Checkout",
  material_type.name as "Material Type"
from
  feesfines.feefineactions__t as actions
  left join feesfines.accounts__t as accounts on actions.account_id = accounts.id
  join users.users__t as users on actions.user_id = users.id
  left join circulation.loan__t as loans on accounts.loan_id = loans.id
  left join users.groups__t as patron_groups on users.patron_group = patron_groups.id
  left join inventory.location__t as locations on loans.item_effective_location_id_at_check_out = locations.id
  left join inventory.material_type__t as material_type on material_type.id = accounts.material_type_id
where
  users.barcode != 'failsafe' 
  --and accounts.owner_id = '' --Include only actions on bills owned by an institution
  --and actions.type_action in ('Hourly Equipment Replacement Bill', 'Daily Equipment Replacement Bill', 'Lost item fee', 'Lost item processing fee')
  and material_type.name = 'Equipment'
  --and patron_groups.group = 'Undergraduate'
  and users.external_system_id like '%@umass.edu'
  and TO_DATE(
    actions.date_action,
    'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"'
  ) >= TO_DATE(
    (
      select
        start_date
      from
        parameters
    ),
    'YYYY-MM-DD'
  )
  and TO_DATE(
    actions.date_action,
    'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"'
  ) <= TO_DATE(
    (
      select
        end_date
      from
        parameters
    ),
    'YYYY-MM-DD'
  )
order by
  accounts.metadata__created_date