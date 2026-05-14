--UM SOA Report
with
  parameters AS (
    SELECT
  	  -- Start and end dates are INCLUSIVE please use a YYYY-MM-DD format
      '{Payment Start Date|DATE}':: VARCHAR AS start_date, -- Change this value to the first date of the desired range
      '{Payment End Date|DATE}':: VARCHAR AS end_date, --Change this value to the last date of the desired range
      '{Fiscal Year (UMFY[YYYY])}'::VARCHAR as fiscal_year -- change this value to the Code for the desired Fiscal Year
      --'2025-07-01'::VARCHAR as start_date,
      --'2026-04-01'::VARCHAR as end_date,
      --'UMFY2026'::VARCHAR as fiscal_year 
  ),
soa_invoice_lines as (
	select
	  --/*
	  soa_invoice_lines.invoice_status as "Invoice Status",
	  soa_invoice_lines.line_fund_dist_total::float as "Invoice Line Fund Distribution Amount",
	  soa_invoice_lines.vendor_invoice_no as "Vendor Invoice Number",
	  soa_invoice_lines.invoice_id as "Invoice UUID",
	  soa_invoice_lines.invoice_date as "Invoice Date",
	  soa_invoice_lines.payment_date as "Payment Date",
	  organizations.name as "Vendor Name",
	  organizations.code as "Vendor Code",
	  funds.name as "Fund Name",
	  funds.code as "Fund Code",
	  expense_classes.name as "Expense Class",
	  expense_classes.code as "Expense Class Code",
	  soa_invoice_lines.accounting_code as "Accounting Code" --*/
	from
	  (
	    select
	      invoices.id as invoice_id,
	      invoices.status as invoice_status,
	      invoices.vendor_invoice_no,
	      SUBSTR(invoices.invoice_date::TEXT, 0, 11) as invoice_date,
	      SUBSTR(invoices.payment_date::TEXT, 0, 11) as payment_date,
	      invoices.vendor_id,
	      fund_distributions.fund_distributions__expense_class_id as expense_class_id,
	      vouchers.account_no as vouch_no,
	      vouchers.accounting_code as vouch_code,
	      invoice_lines.accounting_code as line_code,
	      invoice_lines.account_number as line_no,
	      invoices.account_no as inv_no,
	      invoices.accounting_code as inv_code,
	      case
	      	when (invoices.account_no is null and invoices.accounting_code is null)
	      	then 
	      		case 
		      		when (invoice_lines.accounting_code is null and invoice_lines.account_number is null)
		      		then
			      		case
			      			when vouchers.account_no is null
		      				then vouchers.accounting_code
		      				when vouchers.accounting_code is null 
		      				then vouchers.account_no
			    			when vouchers.accounting_code = vouchers.account_no
		      				then vouchers.accounting_code
		      				else vouchers.account_no || ' (' || vouchers.accounting_code || ')'
		      			end
	      			when invoice_lines.account_number is null
	      			then invoice_lines.accounting_code
	      			when invoice_lines.accounting_code is null 
	      			then invoice_lines.account_number
		    		when invoice_lines.accounting_code = invoice_lines.account_number
	      			then invoice_lines.accounting_code
	      			else invoice_lines.account_number || ' (' || invoice_lines.accounting_code || ')'
	      		end 
		    when invoices.account_no is null
	      	then invoices.accounting_code
	      	when invoices.accounting_code is null 
	      	then invoices.account_no
		    when invoices.accounting_code = invoices.account_no
	      	then invoices.accounting_code
	      	else invoices.account_no || ' (' || invoices.accounting_code || ')'
	      end as accounting_code,
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
	      join invoice.invoice_lines__t as invoice_lines on fund_distributions.id = invoice_lines.id
	      join invoice.invoices__t as invoices on invoices.id = fund_distributions.invoice_id
	      left join invoice.vouchers__t as vouchers on invoices.id = vouchers.invoice_id 
	      join invoice.invoices__t__acq_unit_ids as acq_unit on acq_unit.id = invoices.id     
	      left join finance.fiscal_year__t as fy on fy.id = invoices.fiscal_year_id
	    where
	      (invoices.status = 'Paid')
	      and acq_unit.acq_unit_ids = '7e8d460a-93dc-40b4-a1b7-f4a85a0a0dba'
	      and invoices.payment_date::DATE >= TO_DATE((SELECT start_date FROM parameters), 'YYYY-MM-DD')
	      and invoices.payment_date::DATE <= TO_DATE((SELECT end_date FROM parameters), 'YYYY-MM-DD')
	      and fy.code like (select fiscal_year from parameters)
      ) as soa_invoice_lines
  left join organizations.organizations__t as organizations 
  	on soa_invoice_lines.vendor_id::varchar = organizations.id::varchar
  left join finance.expense_class__t as expense_classes 
  	on soa_invoice_lines.expense_class_id::varchar = expense_classes.id::varchar
  left join finance.transaction__t as transactions 
  	on soa_invoice_lines.encumbrance_id::varchar = transactions.id::varchar
  left join finance.fund__t as funds 
  	on soa_invoice_lines.fund_distributions__fund_id::varchar = funds.id::varchar
),
voucher_batches as (
	select distinct
		export.id as "exportId",
		export.start::timestamp,
		export.end::timestamp,
		vouchers.voucher_date::timestamp,
		invoices.vendor_invoice_no,
		vouchers.voucher_number,
		invoices.id as "invoiceId",
		batchgroups.name
	from
		invoice.batch_voucher_exp__t as export
	left join invoice.vouchers__t as vouchers on
		(vouchers.voucher_date >= export."start"
			and vouchers.voucher_date <= export."end")
	left join invoice.invoices__t as invoices on
		invoices.id = vouchers.invoice_id
	left join invoice.batch_groups__t as batchgroups on batchgroups.id = vouchers.batch_group_id 
	where
		batchgroups."name" = 'UMass'	
		and export.batch_group_id = 'a7e45bf0-5762-4936-bf26-4cabd4941337'
		and vouchers.export_to_accounting
	order by
		export.end::timestamp desc
)
  	--ORDER BY
--  "Fund Name",
--  "Payment Date"
select soa_invoice_lines.*, batch.end::timestamp as "Batch Export Date" from soa_invoice_lines
left join voucher_batches as batch on soa_invoice_lines."Invoice UUID" = batch."invoiceId"
union all
select
  --/*
  'Total' as "Invoice Status",
  round(sum("Invoice Line Fund Distribution Amount")::numeric, 2)::float as "Invoice Line Fund Distribution Amount",
  '' as "Vendor Invoice Number",
  Null as "Invoice UUID",
  '' as "Invoice Date",
  '' as "Payment Date",
  '' as "Vendor Name",
  '' as "Vendor Code",
  '' as "Fund Name",
  '' as "Fund Code",
  '' as "Expense Class",
  '' as "Expense Class Code",
  '' as "Accounting Code",
  null as "Batch Export Date"--*/
from
  soa_invoice_lines 

ORDER BY
  "Fund Name" desc, 
  "Payment Date"

