with
  parameters AS (
    SELECT
      '{Batch Export Date|DATE}':: VARCHAR AS export_date -- Change this value to the first date of the desired range
      --'2026-03-04':: DATE AS export_date
  )
select distinct
	string_agg(distinct invoices.status,', ') as "Invoice Status",
	string_agg(distinct invoices.total::VARCHAR, ', ') as "Invoice Ammount",
	string_agg(distinct invoices.vendor_invoice_no::VARCHAR, ', ') as "Vendor Invoice Number",
	string_agg(distinct invoices.invoice_date::DATE::VARCHAR, ', ') as "Invoice Date",
	string_agg(distinct invoices.payment_date::DATE::VARCHAR, ', ') as "Payment Date",
	string_agg(distinct vendor.name, ', ') as "Vendor Name",
	string_agg(distinct vendor.code, ', ') as "Vendor Code",
	string_agg(distinct fund.name, ', ') as "Fund Name",
	string_agg(distinct fund.code, ', ') as "Fund Code",
	string_agg(distinct expenseclass.name, ', ') as "Expense Class Name",
	string_agg(distinct expenseclass.code, ', ') as "Expense Class Code",
	string_agg(distinct invoices.accounting_code, ', ') as "Accounting Code",
	string_agg(distinct export.end::DATE::VARCHAR, ', ') as "Batch Export Date"
from
	invoice.batch_voucher_exp__t as export 
left join invoice.vouchers__t as vouchers on (vouchers.voucher_date >= export."start" and vouchers.voucher_date <= export."end")
left join invoice.invoices__t as invoices on invoices.id = vouchers.invoice_id
left join invoice.batch_groups__t as batchgroups on batchgroups.id = vouchers.batch_group_id 
left join organizations.organizations__t as vendor on vendor.id = invoices.vendor_id
left join invoice.invoice_lines__t__fund_distributions as invoicelines on invoicelines.invoice_id = invoices.id
left join finance.fund__t as fund on fund.id = invoicelines.fund_distributions__fund_id
left join finance.expense_class__t as expenseclass on invoicelines.fund_distributions__expense_class_id = expenseclass.id
where
	invoices.batch_group_id = 'a7e45bf0-5762-4936-bf26-4cabd4941337'
	and vouchers.export_to_accounting
	and export.batch_group_id = 'a7e45bf0-5762-4936-bf26-4cabd4941337'
	and export.end::DATE = (select export_date::DATE from parameters)
group by (invoices.id)
order by "Invoice Date"