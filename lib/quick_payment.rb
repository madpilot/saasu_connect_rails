module SaasuConnect
	class QuickPayment < Base
		set_primary_key nil

		def initialize(data = nil)
			self.fields = ActiveSupport::OrderedHash.new
			
			self.fields[:date_paid] = :date
			self.fields[:date_cleared] = :date
			self.fields[:bank_to_account_uid] = :int
			self.fields[:amount] = :float
			self.fields[:reference] = :string
			self.fields[:summary] = :string
			
			super(data)
		end
	end
end
