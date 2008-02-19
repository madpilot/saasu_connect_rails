module SaasuConnect
	class Base
		class SecurityException < Error
			@message = "It seems that your Saasu access key or File UID is incorrect"
		end
	end
end
