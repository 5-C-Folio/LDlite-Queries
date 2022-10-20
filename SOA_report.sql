--Draft UM SOA Report
with
  parameters AS (
    SELECT
  	  --Start and end dates are INCLUSIVE please use a YYYYMMDD format
      '{Start Date (YYYYMMDD)}':: VARCHAR AS start_date, -- Change this value to the first date of the desired range
      '{End Date (YYYYMMDD)}':: VARCHAR AS end_date --Change this value to the last date of the desired range
  )
select
  --/*
  soa_invoice_lines.invoice_status as "Invoice Status",
  soa_invoice_lines.vendor_invoice_no as "Vendor Invoice Number",
  soa_invoice_lines.invoice_id as "Invoice UUID",
  soa_invoice_lines.invoice_date as "Invoice Date",
  soa_invoice_lines.payment_date as "Payment Date",
  organizations.name as "Vendor Name",
  organizations.code as "Vendor Code",
  funds.name as "Fund Name",
  funds.code as "Fund Code",
  soa_invoice_lines.fund_distributions__fund_id,
  expense_classes.name as "Expense Class",
  expense_classes.code as "Expense Class Code",
  soa_invoice_lines.line_fund_dist_total::float as "Invoice Line Fund Distribution Amount",
  soa_invoice_lines.accounting_code as "Accounting Code" --*/
from
  (
    select
      invoices.id as invoice_id,
      invoices.status as invoice_status,
      invoices.vendor_invoice_no,
      SUBSTR(invoices.invoice_date, 0, 11) as invoice_date,
      SUBSTR(invoices.payment_date, 0, 11) as payment_date,
      invoices.vendor_id,
      fund_distributions.fund_distributions__expense_class_id as expense_class_id,
      invoices.accounting_code,
      fund_distributions.id as invoice_line_id,
      fund_distributions.fund_distributions__encumbrance as encumbrance_id,
      fund_distributions.release_encumbrance,
      fund_distributions.fund_distributions__fund_id,
      case
        fund_distributions.fund_distributions__distribution_type
        when 'percentage' then
          fund_distributions.fund_distributions__value::float
         * fund_distributions.total::float / 100
        when 'amount' then 
          fund_distributions.fund_distributions__value::float
        else 0
      end as line_fund_dist_total
    from
    invoice.invoice_lines__t__fund_distributions as fund_distributions  
      join invoice.invoices__t as invoices on invoices.id = fund_distributions.invoice_id
    where
      (status = 'Paid')
      and bill_to = 'eabe1a7d-2c24-449a-8e6b-2126f15a8f68'
      and TO_DATE(invoice_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"') >= TO_DATE((SELECT start_date FROM parameters), 'YYYYMMDD')
      and TO_DATE(invoice_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"') <= TO_DATE((SELECT end_date FROM parameters), 'YYYYMMDD')
  ) as soa_invoice_lines
  left join organizations.organizations__t as organizations 
  	on soa_invoice_lines.vendor_id::varchar = organizations.id::varchar
  left join finance.expense_class__t as expense_classes 
  	on soa_invoice_lines.expense_class_id::varchar = expense_classes.id::varchar
  left join finance.transaction__t as transactions 
  	on soa_invoice_lines.encumbrance_id::varchar = transactions.id::varchar
  left join finance.fund__t as funds 
  	on soa_invoice_lines.fund_distributions__fund_id::varchar = funds.id::varchar
--ORDER BY
--  "Fund Name",
--  "Payment Date"
UNION all
select
  --/*
  '' as "Invoice Status",
  '' as "Vendor Invoice Number",
  '' as "Invoice UUID",
  '' as "Invoice Date",
  '' as "Payment Date",
  '' as "Vendor Name",
  '' as "Vendor Code",
  '' as "Fund Name",
  '' as "Fund Code",
  '',
  '' as "Expense Class",
  'Total' as "Expense Class Code",
  --soa_invoice_lines.line_fund_dist_total as "Invoice Line Fund Distribution Amount",
  round(sum(soa_invoice_lines.line_fund_dist_total)::numeric, 2)::float as "Invoice Line Fund Distribution Amount",
  '' as "Accounting Code" --*/
from
  (
    select 
      invoices.id as invoice_id,
      invoices.status as invoice_status,
      invoices.vendor_invoice_no,
      SUBSTR(invoices.invoice_date, 0, 11) as invoice_date,
      SUBSTR(invoices.payment_date, 0, 11) as payment_date,
      invoices.vendor_id,
      fund_distributions.fund_distributions__expense_class_id as expense_class_id,
      invoices.accounting_code,
      fund_distributions.id as invoice_line_id,
      fund_distributions.fund_distributions__encumbrance as encumbrance_id,
      fund_distributions.release_encumbrance,
      fund_distributions.fund_distributions__fund_id,
      case
        fund_distributions.fund_distributions__distribution_type
        when 'percentage' then
          fund_distributions.fund_distributions__value::float
         * fund_distributions.total::float / 100
        when 'amount' then 
          fund_distributions.fund_distributions__value::float
        else 0
      end as line_fund_dist_total
    from
    invoice.invoice_lines__t__fund_distributions as fund_distributions  
      join invoice.invoices__t as invoices on invoices.id = fund_distributions.invoice_id
    where
      (status = 'Paid')
      and bill_to = 'eabe1a7d-2c24-449a-8e6b-2126f15a8f68'
      and TO_DATE(invoice_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"') >= TO_DATE((SELECT start_date FROM parameters), 'YYYYMMDD')
      and TO_DATE(invoice_date, 'YYYY-MM-DD"T"HH24:MI:SS.MS"+0000"') <= TO_DATE((SELECT end_date FROM parameters), 'YYYYMMDD')
  ) as soa_invoice_lines
  left join organizations.organizations__t as organizations 
  	on soa_invoice_lines.vendor_id::varchar = organizations.id::varchar
  left join finance.expense_class__t as expense_classes 
  	on soa_invoice_lines.expense_class_id::varchar = expense_classes.id::varchar
  left join finance.transaction__t as transactions 
  	on soa_invoice_lines.encumbrance_id::varchar = transactions.id::varchar
  left join finance.fund__t as funds 
  	on soa_invoice_lines.fund_distributions__fund_id::varchar = funds.id::varchar

ORDER BY
  "Fund Name" desc, 
  "Payment Date";

