module SaasuConnect
	class ItemInvoiceItem < Base
		belongs_to :inventory_uid

		set_primary_key nil
		def initialize(data = nil)
			self.fields = ActiveSupport::OrderedHash.new
			
			self.fields[:quantity] = :float
			self.fields[:inventory_item_uid] = :int
			self.fields[:description] = :string
			self.fields[:tax_code] = :string
			self.fields[:unit_price_inc_tax] = :float
			self.fields[:percentage_discount] = :float
			
			super(data)
		end
	end
end
