module SaasuConnect
	class Contact < Base
		has_many :sale_invoices, :class_name => :invoice, :foreign_key => :contact_uid, :conditions => { :transaction_type => 's' }
		has_many :purchase_invoices, :class_name => :invoice, :foreign_key => :contact_uid, :conditions => { :transaction_type => 'p' }

		validates_presence_of :given_name, :if => Proc.new { |contact| contact.middle_initials == nil && contact.family_name == nil }
		validates_presence_of :middle_initials, :if => Proc.new { |contact| contact.given_name == nil && contact.family_name == nil }
		validates_presence_of :family_name, :if => Proc.new { |contact| contact.middle_initials == nil && contact.given_name == nil }

		def initialize(data = nil)
			self.fields = ActiveSupport::OrderedHash.new
			
			self.fields[:uid] = :int 
			self.fields[:last_updated_uid] = :string
			self.fields[:salutation] = :string 
			self.fields[:given_name] = :string 
			self.fields[:middle_initials] = :string
			self.fields[:family_name] = :string
			self.fields[:organisation_name] = :string
			self.fields[:organisation_abn] = :string
			self.fields[:organisation_website] = :string
			self.fields[:organisation_position] = :string
			self.fields[:contact_id] = :string
			self.fields[:abn] = :string
			self.fields[:website_url] = :string
			self.fields[:email] = :string
			self.fields[:main_phone] = :string
			self.fields[:home_phone] = :string
			self.fields[:fax] = :string
			self.fields[:mobile_phone] = :string
			self.fields[:other_phone] = :string
			self.fields[:status_uid] = :int
			self.fields[:industry_uid] = :int
			self.fields[:postal_address] = :postal_address
			self.fields[:other_address] = :postal_address
			self.fields[:is_active] = :bool
			self.fields[:accept_direct_deposit] = :bool
			self.fields[:direct_deposit_account_name] = :string
			self.fields[:direct_deposit_bsb] = :string
			self.fields[:direct_deposit_account_number] = :string
			self.fields[:accept_cheque] = :bool
			self.fields[:cheque_payable_to] = :string
			
			super(data)

			self.attributes[:postal_address] = PostalAddress.new
			self.attributes[:other_address] = PostalAddress.new
		end

		def self.deserialize(xml, options={})
			doc = Document.new(xml)
			contacts = Array.new
			
			if doc.root.name == "contactListResponse"
				nodes = doc.root.elements["contactList"]

				nodes.children.each { |item|
					if item.node_type == :element && item.name.underscore.to_sym == :contact_list_item
						contacts << Contact.obj_from_xml(item)
					end
				}
				return contacts

			elsif doc.root.name == "contactResponse"
				node = doc.root.elements["contact"]
				contact = Contact.obj_from_xml(node)
				contact.uid = node.attributes["uid"].to_i
				contact.last_updated_uid = node.attributes["lastUpdatedUid"]
				return contact
			end
		end

		def serialize(options = {})
			options[:indent] ||= 2
			xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
			xml.instruct! unless options[:skip_instruct]
			
			if self.send(self.primary_key) != nil
				options[:root] ||= "updateContact"

				output = xml.tag!(options[:root]) do
					xml.tag!('contact', :uid => self.uid, :lastUpdatedUid => self.last_updated_uid) do
						self.fields.keys.each { |field|
							if attributes[field].is_a?(PostalAddress)
								dup_options = options.dup
								dup_options[:skip_instruct] = true
								dup_options[:root] = field.to_s.camelize(:lower)
								attributes[field].serialize(dup_options)
							elsif field == :contact_id
								xml.tag!("contactID", cast_to_node(attributes[field], field)) unless cast_to_node(attributes[field], field) == ""
							else
								xml.tag!(field.to_s.camelize(:lower).to_s, cast_to_node(attributes[field], field)) unless (cast_to_node(attributes[field], field) == "" || field == :uid || field == :last_updated_uid)
							end
						}
					end
				end
			else
				options[:root] ||= "insertContact"
				
				output = xml.tag!(options[:root]) do
					xml.tag!('contact', :uid => 0) do
						self.fields.keys.each { |field|
							if attributes[field].is_a?(PostalAddress)
								dup_options = options.dup
								dup_options[:root] = field.to_s.camelize(:lower)
								dup_options[:skip_instruct] = true
								attributes[field].serialize(dup_options)
							elsif field == :contact_id
								xml.tag!("contactID", cast_to_node(attributes[field], field)) unless cast_to_node(attributes[field], field) == ""
							else
								xml.tag!(field.to_s.camelize(:lower).to_s, cast_to_node(attributes[field], field)) unless cast_to_node(attributes[field], field) == "" || field == :uid || field == :last_updated_uid
							end
						}
					end
				end
			end
			output
		end

		def self.obj_from_xml(item)
			contact = Contact.new
			postal_address = PostalAddress.new
			other_address = PostalAddress.new
			
			item.children.each { |node|
				if node.node_type == :element
					node_name = node.name.underscore.to_sym
					if node_name == :contact_uid
						contact.uid = contact.cast_from_node(node, :uid)
					elsif node_name == :street || node_name == :city || node_name == :city || node_name == :state || node_name == :postcode || node_name == :country
						postal_address.send(node_name.to_s + "=", postal_address.cast_from_node(node, node_name))
					elsif node_name == :other_street || node_name == :other_city || node_name == :other_city || node_name == :other_state || node_name == :other_postcode || node_name == :other_country
						other_address.send(node_name.to_s.gsub('other_', '') + "=", other_address.cast_from_node(node, node_name))
					elsif node_name == :postal_address
						postal_address = PostalAddress.obj_from_xml(node)
					elsif node_name == :other_address
						other_address = PostalAddress.obj_from_xml(node)
					elsif contact.fields.keys.include?(node_name)
						contact.send(node_name.to_s + "=", contact.cast_from_node(node, node_name))
					end
				end
			}
			contact.postal_address = postal_address
			contact.other_address = other_address

			return contact
		end
	end
end
