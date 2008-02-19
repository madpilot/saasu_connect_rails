module SaasuConnect
	class Invoice < Base
		belongs_to :contact, :foreign_key => :contact_uid

		validates_presence_of :uid, :on => :update
		validates_presence_of :last_updated_uid, :on => :update
		validates_presence_of :transaction_type
		validates_presence_of :date
		validates_presence_of :layout
		validates_presence_of :status

		validates_format_of :transaction_type, :with => /^P$|^S$/
		validates_format_of :layout, :with => /^P$|^S$/
		validates_format_of :status, :with => /^Q$|^O$|^I$/

		#validates_length_of :reference, :maximum => 50
		#validates_length_of :summary, :maximum => 75
		#validates_length_of :invoice_number, :maximum => 50
		#validates_length_of :purchase_order_number, :maximum => 50

		def initialize(data = nil)
			self.fields = ActiveSupport::OrderedHash.new

			# To send/common
			self.fields[:uid] = :int 
			self.fields[:last_updated_uid] = :string 
			self.fields[:transaction_type] = :string 
			self.fields[:date] = :date
			self.fields[:contact_uid] = :int
			self.fields[:folder_uid] = :int
			self.fields[:reference] = :string
			self.fields[:summary] = :string
			self.fields[:notes] = :string
			self.fields[:requires_follow_up] = :bool
			self.fields[:due_or_expiry_date] = :date
			self.fields[:layout] = :string
			self.fields[:status] = :string
			self.fields[:invoice_number] = :string
			self.fields[:purchase_order_number] = :string
			self.fields[:invoice_items] = :invoice_item
			self.fields[:quick_payment] = :float
			self.fields[:is_sent] = :bool

			# To receive
			self.fields[:due_date] = :date_time
			self.fields[:folder_uid] = :int
			self.fields[:folder_name] = :string
			self.fields[:payment_count] = :int
			self.fields[:total_amount_paid] = :float
			self.fields[:amount_owned] = :float
			self.fields[:paid_status] = :string
			self.fields[:requires_follow_up] = :bool
			self.fields[:invoice_layout] = :string
			self.fields[:invoice_status] = :string
			self.fields[:contact_given_name] = :string
			self.fields[:contact_family_name] = :string
			self.fields[:contact_organisation_name] = :string
			self.fields[:total_amount_incl_tax] = :float
			self.fields[:amount_owed] = :float
			
			super(data)

			self.attributes[:invoice_items] = Array.new
		end

		def invoice_items=(invoice_items)
			self.attributes[:invoice_items] = invoice_items
		end

		def invoice_items
			return self.attributes[:invoice_items]
		end

		def self.deserialize(xml, options={})
			doc = Document.new(xml)
			
			invoices = Array.new
			
			if doc.root.name == "invoiceListResponse"
				nodes = doc.root.elements["invoiceList"]

				nodes.children.each { |item|
					if item.node_type == :element && item.name.underscore.to_sym == :invoice_list_item
						invoices << Invoice.obj_from_xml(item)
					end
				}
				return invoices

			elsif doc.root.name == "invoiceResponse"
				node = doc.root.elements["invoice"]
				invoice = Invoice.obj_from_xml(node)
				invoice.uid = node.attributes["uid"].to_i
				invoice.last_updated_uid = node.attributes["lastUpdatedUid"]
				return invoice
			end
		end

		def serialize(options = {})
			options[:indent] ||= 2
			xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
			xml.instruct! unless options[:skip_instruct]
			
			if self.uid != nil
				options[:root] ||= "updateInvoice"

				output = xml.tag!(options[:root]) do
					xml.tag!('invoice', :uid => self.uid, :lastUpdatedUid => self.last_updated_uid) do
						self.fields.keys.each { |field|
							xml.tag!(field.to_s.camelize(:lower).to_s, cast_to_node(attributes[field], field)) unless (cast_to_node(attributes[field], field) == "" || field == :uid || field == :last_updated_uid)
						}
					end
				end
			else
				options[:root] ||= "insertInvoice"
				
				output = xml.tag!(options[:root]) do
					xml.tag!('invoice', :uid => 0) do
						self.fields.keys.each { |field|
							if field == :invoice_items
								dup_options = options.dup
								dup_options[:root] = nil
								dup_options[:skip_instruct] = true

								xml.tag!(field.to_s.camelize(:lower)) do
									attributes[field].each do |item|
										item.serialize(dup_options)
									end
								end
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
			invoice = Invoice.new
			
			item.children.each { |node|
				if node.node_type == :element
					node_name = node.name.underscore.to_sym

					if node_name == :invoice_uid
						invoice.uid = invoice.cast_from_node(node, :uid)
					elsif node_name == :invoice_items
						node.children.each { |invoice_item|
							if invoice_item.node_type == :element
								invoice_item_name = invoice_item.name.underscore.to_sym

								if invoice_item_name == :service_invoice_item
									invoice.invoice_items << ServiceInvoiceItem.obj_from_xml(invoice_item)
								end
								
								if invoice_item_name == :item_invoice_item
									invoice.invoice_items << ItemInvoiceItem.obj_from_xml(invoice_item)
								end
							end
						}
					elsif invoice.fields.keys.include?(node_name)
						invoice.send(node_name.to_s + "=", invoice.cast_from_node(node, node_name))
					end
				end
			}
			return invoice
		end
	end
end
