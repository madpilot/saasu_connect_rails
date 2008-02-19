module SaasuConnect
	class Base
		class RecordNotFoundException < Error
			@message = "Contact not found"
		end
	end
end
