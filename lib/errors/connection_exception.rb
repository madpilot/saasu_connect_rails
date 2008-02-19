module SaasuConnect
	class Rest
		class ConnectionException < Error
			@message = "Couldn't connect to remote server"
		end

		class HttpException < Error
			@message = "A error occured while trying to retrieve the resource"
		end
	end
end
