with
  parameters AS (
    SELECT
      '{Start Date (YYYY-MM-DD)}':: VARCHAR AS start_date,
      --Change this value to the earliest date you want to see
      '{End Date (YYYY-MM-DD)}':: VARCHAR AS end_date,
      --Change this value to the latest date you want to see
      TO_DATE('02/05', 'MM/DD'):: DATE AS winter_end,
      TO_DATE('05/15', 'MM/DD'):: DATE AS spring_end,
      TO_DATE('08/31', 'MM/DD'):: DATE AS summer_end,
      TO_DATE('12/20', 'MM/DD'):: DATE AS fall_end
  )
select
  case
    when users.external_system_id like '%@%' then substring(
      users.external_system_id
      from
        '[1234567890]*'
    )
    else users.external_system_id
  end as "Spire ID",
  
  --substring(accounts.metadata__created_date, 0, 11) as "Billed Date",
  case
    when TO_DATE(
      substring(accounts.metadata__created_date, 6, 11),
      'MM-DD'
    ) <= (
      select
        winter_end
      from
        parameters
    ) then '1' || substring(accounts.metadata__created_date, 3, 2) || '1'
    when TO_DATE(
      substring(accounts.metadata__created_date, 6, 11),
      'MM-DD'
    ) <= (
      select
        spring_end
      from
        parameters
    ) then '1' || substring(accounts.metadata__created_date, 3, 2) || '3'
    when TO_DATE(
      substring(accounts.metadata__created_date, 6, 11),
      'MM-DD'
    ) <= (
      select
        summer_end
      from
        parameters
    ) then '1' || substring(accounts.metadata__created_date, 3, 2) || '5'
    when TO_DATE(
      substring(accounts.metadata__created_date, 6, 11),
      'MM-DD'
    ) <= (
      select
        fall_end
      from
        parameters
    ) then '1' || substring(accounts.metadata__created_date, 3, 2) || '7'
    else '1' || substring(accounts.metadata__created_date, 3, 5) || '1'
  end as "Term Code",
  --substring(actions.date_action, 0, 11) as "Transaction Date",
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
  --case
  --	when actions.type_action in (
  --    'Credited fully',
  --    'Waived fully',
  --    'Cancelled item declared lost',
  --    'Waived partially',
  --    'Paid fully',
  --    'Cancelled item renewed',
  --    'Cancelled item returned',
  --    'Refunded fully'
  --  ) then 'Credit'
  --   when actions.type_action in (
  --    'Hourly Equipment Replacement Bill',
  --    'General Library Charge',
  --    'Daily Equipment Replacement Bill',
  --    'ILL Replacement',
  --    'Overdue fine',
  --    'Lost item processing fee',
  --    'Lost item fee',
  --    'Staff info only'
  --  ) then 'Debit'
  --  else 'UNKNOWN'
  --  end as "Debit/Credit",
  case
  	when accounts.owner_id = '0cab3fdc-9e7b-491f-b565-55928d26d933' --UM
  	then case
  		when service_points.name in ('UM DuBois Library', 'UM Wadsworth Library', 'UM Digital Media Lab') --DuBois
		then case
        	when accounts.fee_fine_type in ('Daily Equipment Replacement Bill', 'Hourly Equipment Replacement Bill', 'ILL Replacement', 'Lost item fee', 'Lost item fee (actual cost)', 'Lost item processing fee', 'Replacement processing fee')
            then '047000000000'
            when accounts.fee_fine_type in ('General Library Charge', 'Overdue fine')
            then '047100000000'
            end
        when service_points.name = 'UM Science & Engineering Library' --SEL
        then case
        	when accounts.fee_fine_type in ('Daily Equipment Replacement Bill', 'Hourly Equipment Replacement Bill', 'ILL Replacement', 'Lost item fee', 'Lost item fee (actual cost)', 'Lost item processing fee', 'Replacement processing fee')
            then '048400000000'
            when accounts.fee_fine_type in ('General Library Charge', 'Overdue fine')
            then '048500000000'
            end
        end
    when accounts.owner_id = 'a59aa418-117f-4382-ad05-afc85ff640e2' --Amherst
    then case
    	when accounts.fee_fine_type in ('Daily Equipment Replacement Bill', 'Hourly Equipment Replacement Bill', 'ILL Replacement', 'Lost item fee', 'Lost item fee (actual cost)', 'Lost item processing fee', 'Replacement processing fee')
        then '049100000000'
        when accounts.fee_fine_type in ('General Library Charge', 'Overdue fine')
        then '049200000000'
        end
    when accounts.owner_id = 'e63dde0f-17eb-4933-b8c4-ce03d9d2c06a' --Hampshire
    then case
    	when accounts.fee_fine_type in ('Daily Equipment Replacement Bill', 'Hourly Equipment Replacement Bill', 'ILL Replacement', 'Lost item fee', 'Lost item fee (actual cost)', 'Lost item processing fee', 'Replacement processing fee')
        then '049300000000'
        when accounts.fee_fine_type in ('General Library Charge', 'Overdue fine')
        then '049400000000'
        end
    when accounts.owner_id = '77221193-4e41-4bd1-af1b-1f5815d1e564' --Mount Holyoke
    then case
    	when accounts.fee_fine_type in ('Daily Equipment Replacement Bill', 'Hourly Equipment Replacement Bill', 'ILL Replacement', 'Lost item fee', 'Lost item fee (actual cost)', 'Lost item processing fee', 'Replacement processing fee')
        then '049500000000'
        when accounts.fee_fine_type in ('General Library Charge', 'Overdue fine')
        then '049600000000'
        end
    when accounts.owner_id = '6c2f5c13-25ac-4f25-88da-428f27cf6767' --Smith
    then case
    	when accounts.fee_fine_type in ('Daily Equipment Replacement Bill', 'Hourly Equipment Replacement Bill', 'ILL Replacement', 'Lost item fee', 'Lost item fee (actual cost)', 'Lost item processing fee', 'Replacement processing fee')
        then '049700000000'
        when accounts.fee_fine_type in ('General Library Charge', 'Overdue fine')
        then '049800000000'
        end
    end as "Item code",
  actions.type_action as "Transaction Description",
  accounts.barcode as "Item Barcode"
  --accounts.fee_fine_owner as "FeeFine Owner",
  --users.personal__last_name || ', ' || users.personal__first_name as "Patron name",
  --locations.name as "Location at Checkout",
  --service_points.name as "Service point at Checkout"
  --accounts.title as "Item title",
  --accounts.id as "Fee/Fine Account ID"
from
  feesfines.feefineactions__t as actions
  join feesfines.accounts__t as accounts on actions.account_id = accounts.id
  join users.users__t as users on accounts.user_id = users.id
  join circulation.loan__t as loans on accounts.loan_id = loans.id
  join users.groups__t as patron_groups on users.patron_group = patron_groups.id
  left join inventory.location__t as locations on loans.item_effective_location_id_at_check_out = locations.id
  left join inventory.service_point__t as service_points on locations.primary_service_point = service_points.id
where
  users.barcode != 'failsafe'
  and (
    patron_groups.group = 'Graduate'
    OR patron_groups.group = 'undergraduate'
  ) --Only include Graduate and Undergraduate Patrons
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
  --"Debit/Credit" desc,
  accounts.metadata__created_date