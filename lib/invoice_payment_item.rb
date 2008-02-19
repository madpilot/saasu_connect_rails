module SaasuConnect
	class InvoicePaymentItem < Base
		belongs_to :invoice, :foreign_key => :invoice_uid
		validates_presence_of :amount
		
		def initialize(data = nil)
			self.fields = ActiveSupport::OrderedHash.new
			
			self.fields[:invoice_uid] = :int
			self.fields[:amount] = :float
			
			super(data)
		end
	end
end
