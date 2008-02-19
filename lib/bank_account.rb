module SaasuConnect
	class BankAccount < Base
		def initialize(data = nil)
			self.fields = ActiveSupport::OrderedHash.new
			
			self.fields[:uid] = :int
			self.fields[:last_updated_uid] = :string
			self.fields[:type] = :string
			self.fields[:name] = :string
			self.fields[:is_active] = :bool
			self.fields[:display_name] = :string
			self.fields[:bsb] = :string
			self.fields[:account_number] = :string

			super(data)
		end
	end
end
