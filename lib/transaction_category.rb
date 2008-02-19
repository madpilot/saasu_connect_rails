module SaasuConnect
	class TransactionCategory < Base
		has_many :service_invoice_items, :foreign_key => :account_uid
		has_many :item_invoice_items, :foreign_key => :account_uid
		
		has_many :invoices, :foreign_key => :payment_account_uid

		def initialize(data = nil)
			self.fields = ActiveSupport::OrderedHash.new
			
			self.fields[:uid] = :int 
			self.fields[:last_updated_uid] = :string
			self.fields[:type] = :string
			self.fields[:name] = :string
			self.fields[:is_active] = :bool

			super(data)
		end
	end
end
