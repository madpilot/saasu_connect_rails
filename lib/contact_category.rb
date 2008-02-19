module SaasuConnect
	class ContactCategory < Base
		def initialize(data = nil)
			self.fields = ActiveSupport::OrderedHash.new
			
			self.fields[:uid] = :int
			self.fields[:last_updated_uid] = :string
			self.fields[:type] = :string
			self.fields[:name] = :string
			
			super(data)
		end
	end
end
