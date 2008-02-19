module SaasuConnect
	class ServiceInvoiceItem < Base
		belongs_to :transaction_category, :foreign_key => :account_uid
		set_primary_key nil

		def initialize(data = nil, options = {})
			self.fields = ActiveSupport::OrderedHash.new
			
			self.fields[:description] = :string
			self.fields[:account_uid] = :int
			self.fields[:tax_code] = :string
			self.fields[:total_amount_incl_tax] = :float
			
			super(data, options)
		end
		
		# Call that builds the XML that will be sent to the web service
		def serialize(options = {})
			name = self.class.to_s.split("::").pop
			
			options[:indent] ||= 2
			xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
			xml.instruct! unless options[:skip_instruct]
	
			# Un-DRY dirty hack ahead...
			if options[:root] == nil
				xml.tag!(name.underscore.camelize(:lower)) do
					self.fields.keys.each { |field|
						xml.tag!(field.to_s.camelize(:lower).to_s, cast_to_node(attributes[field], field)) unless cast_to_node(attributes[field], field) == ""
					}
				end
			else
				output = xml.tag!(options[:root]) do
					xml.tag!(name.underscore.camelize(:lower)) do
						self.fields.keys.each { |field|
							xml.tag!(field.to_s.camelize(:lower).to_s, cast_to_node(attributes[field], field)) unless cast_to_node(attributes[field], field) == ""
						}
					end
				end
			end
			
			output
		end
	end
end
