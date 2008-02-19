module SaasuConnect
	class Base
		class SchemaValidationException < Error
			@message = "Validation failed"
		end
	end
end
