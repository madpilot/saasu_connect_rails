module SaasuConnect
	class InvoicePayment < Base
		belongs_to :bank_account, :foreign_key => :payment_account_uid

		validates_presence_of :uid, :on => :update
		validates_presence_of :last_updated_uid, :on => :update
		validates_presence_of :date

		validates_format_of :transaction_type, :with => /^SP$|^PP$/

		validates_length_of :reference, :maximum => 50
		validates_length_of :summary, :maximum => 75

		def initialize(data = nil)
			self.fields = ActiveSupport::OrderedHash.new
			
			self.fields[:uid] = :int
			self.fields[:last_updated_uid] = :string
			self.fields[:transaction_type] = :string
			self.fields[:date] = :date
			self.fields[:reference] = :string
			self.fields[:summary] = :string
			self.fields[:requires_follow_up] = :bool
			self.fields[:payment_account_uid] = :int
			self.fields[:date_cleared] = :date
			self.fields[:invoice_payment_items] = :payment_item
			
			super(data)
		end
	end
end
