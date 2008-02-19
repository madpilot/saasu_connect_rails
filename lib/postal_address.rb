module SaasuConnect
	class PostalAddress < Base
		set_primary_key nil

		def initialize(data = nil)
			self.fields = ActiveSupport::OrderedHash.new
			
			self.fields[:street] = :string
			self.fields[:city] = :string
			self.fields[:state] = :string
			self.fields[:post_code] = :string
			self.fields[:country] = :string

			super
		end

		def serialize(options = {})
			options[:indent] ||= 2
			xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
			xml.instruct! unless options[:skip_instruct]

			options[:root] ||= "postalAddress"

			output = xml.tag!(options[:root]) do
				self.fields.keys.each { |field|
					xml.tag!(field.to_s.camelize(:lower).to_s, cast_to_node(attributes[field], field)) unless cast_to_node(attributes[field], field) == ""
				}
			end	

			output
		end

		def self.obj_from_xml(item)
			postal_address = PostalAddress.new
			item.children.each { |node|
				if node.node_type == :element
					node_name = node.name.underscore.to_sym
					postal_address.send(node_name.to_s + "=", postal_address.cast_from_node(node, node_name))
				end
			}
			return postal_address
		end
	end
end
