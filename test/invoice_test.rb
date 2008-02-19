require File.dirname(__FILE__) + '/abstract_unit'

class InvoiceTest < Test::Unit::TestCase
	fixtures :bank_account, :transaction_category, :contact, :inventory_item, :purchase_invoice, :invoice

	def test_list_invoice
		invoices = Invoice.find(:all, :transaction_type => "S")
		
		assert_equal 2, invoices.size
		assert_not_nil :uid
		assert_not_nil :last_updated_uid

		invoice = invoices.last

		assert_equal "S", invoice.transaction_type
		assert_equal "Test POST sale", invoice.summary
		assert_equal "From REST", invoice.notes
		assert_equal false, invoice.requires_follow_up
		assert_equal "S", invoice.layout
		assert_equal "I", invoice.status
		assert_equal "PO222", invoice.purchase_order_number
		assert_equal false, invoice.is_sent
		
		assert_equal 1, invoice.invoice_items.size
		assert_equal true, invoice.invoice_items.first.is_a?(ServiceInvoiceItem)

		invoice_item = invoice.invoice_items.first
		assert_equal "Design & Development of REST WS", invoice_item.description
		assert_equal "G1", invoice_item.tax_code
		assert_equal 2132.51, invoice_item.total_amount_incl_tax

		invoice = Invoice.find(invoice.uid)
		
		assert_equal "S", invoice.transaction_type
		assert_equal "Test POST sale", invoice.summary
		assert_equal "From REST", invoice.notes
		assert_equal false, invoice.requires_follow_up
		assert_equal "S", invoice.layout
		assert_equal "I", invoice.status
		assert_equal "PO222", invoice.purchase_order_number
		assert_equal false, invoice.is_sent
		
		assert_equal 1, invoice.invoice_items.size
		assert_equal true, invoice.invoice_items.first.is_a?(ServiceInvoiceItem)

		invoice_item = invoice.invoice_items.first
		assert_equal "Design & Development of REST WS", invoice_item.description
		assert_equal "G1", invoice_item.tax_code
		assert_equal 2132.51, invoice_item.total_amount_incl_tax

	end

	def test_create_invoice
		contacts = Contact.find(:all)
		transaction_categories = TransactionCategory.find(:all)

		invoice = Invoice.new
		invoice.transaction_type = "S"
		invoice.date = DateTime.now
		invoice.contact_uid = contacts.first.uid
		invoice.folder_uid = 0
		invoice.summary = "Test Invoice"
		invoice.requires_follow_up = false
		invoice.due_or_expiry_date = DateTime.now
		invoice.layout = "S"
		invoice.status = "I"
		invoice.invoice_number = "<Auto Number>"
		invoice.is_sent = false

		invoice_item = ServiceInvoiceItem.new
		invoice_item.description = "Item #1"
		invoice_item.account_uid = transaction_categories.first.uid
		invoice_item.tax_code = "G1"
		invoice_item.total_amount_incl_tax = 123.12

		invoice.invoice_items << invoice_item

		invoice.save!

		assert_not_nil invoice.uid

		saved_invoice = Invoice.find(invoice.uid)

		assert_equal "S", saved_invoice.transaction_type
		assert_equal contacts.first.uid, invoice.contact_uid
		assert_equal 0, invoice.folder_uid
		assert_equal "Test Invoice", invoice.summary
		assert_equal false, invoice.requires_follow_up
	end
end
