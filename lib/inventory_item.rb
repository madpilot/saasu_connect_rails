module SaasuConnect
	class InventoryItem
		has_many :item_invoice_items
		def initialize(data = nil)
			self.fields = ActiveSupport::OrderedHash.new
			
			self.fields[:uid] = :int
			self.fields[:last_updated_uid] = :string
			self.fields[:code] = :string
			self.fields[:description] = :string
			self.fields[:is_active] = :bool
			self.fields[:notes] = :string
			self.fields[:is_inventoried] = :bool
			self.fields[:asset_account_uid] = :int
			self.fields[:stock_on_hold] = :float
			self.fields[:current_value] = :float
			self.fields[:is_bought] = :bool
			self.fields[:purchase_expense_account_uid] = :int
			self.fields[:purchase_tax_code] = :string
			self.fields[:minimum_stock_level] = :float
			self.fields[:primary_supplier_contact_uid] = :int
			self.fields[:primary_supplier_item_code] = :string
			self.fields[:default_re_order_quantity] = :float
			self.fields[:is_sold] = :bool
			self.fields[:sale_income_account_uid] = :int
			self.fields[:sale_tax_code] = :string
			self.fields[:sale_co_s_account_uid] = :int
			self.fields[:rrp_incl_tax] = :float

			super(date)
		end
	end
end
