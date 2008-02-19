module SaasuConnect
	class Error < StandardError
		class << self
			attr_accessor :message
		end
			
		self.message = "Error"
			
		def initialize(message = self.class.message)
			super(message)
		end
	end
end
