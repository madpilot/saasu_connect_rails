module SaasuConnect
	class Base
		include REXML
		attr_accessor :fields, :complete_download, :access_key, :file_uid
		
		def initialize(data = nil, options = {})
			@attributes = Hash.new

			self.fields ||= ActiveSupport::OrderedHash.new

			self.access_key = options[:access_key] || SAASU_ACCESS_KEY
			self.file_uid = options[:file_uid] || SAASU_FILE_UID

			if !data.nil?
				if data.is_a?(Document)
					fields.keys.each do |f|
						camelized = f.to_s.underscore
						self.attributes[f] = cast_from_node(data[camelized], fields[f]) if data[camelized] != nil
					end
				else
					fields.keys.each { |f| self.attributes[f] = cast_from_string(data[f.to_s], fields[f]) if data[f.to_s] != nil }
				end
			end
		end

		def attributes=(attr)
			attr.each { |key, value| @attributes[key] = cast_from_string(value, key.to_sym) unless value.is_a?(Hash) }
		end

		def attributes
			@attributes
		end

		def self.set_primary_key(key)
			@primary_key = key
		end
		
		def self.primary_key
			@primary_key || :uid
		end

		def primary_key
			return self.class.primary_key
		end

		# Stuff to make the validations work
		def new_record?
			return self.send(self.class.primary_key) == nil
		end

		def self.human_attribute_name(attribute_key_name)
			attribute_key_name.humanize
		end

		def update_attribute(name, value)
			send(name.to_s + '=', value)
		end
	
		def [](key)
			send(key)
		end

		def inspect
			return "#<#{self.class.to_s}: " + self.fields.keys.map { |k| k.to_s + ": " + self.attributes[k].inspect }.join(", ") + ">"
		end

		def self.has_many(association_id, options = {})
			@@associations ||= Hash.new
			@@associations[:has_many] ||= Hash.new
			
			options[:class_name] ||= association_id.to_s.singularize
			options[:foreign_key] ||= options[:class_name].to_s.foreign_key
			options[:conditions] ||= Hash.new
			
			@@associations[:has_many][association_id] = { 
				:class_name => options[:class_name].to_s.camelize, 
				:foreign_key => options[:foreign_key], 
				:conditions => options[:conditions] 
			}
		end

		def self.belongs_to(association_id, options = {})
			@@associations ||= Hash.new
			@@associations[:belongs_to] ||= Hash.new
			
			options[:class_name] ||= association_id.to_s
			options[:foreign_key] ||= options[:class_name].to_s.foreign_key
			options[:conditions] ||= Hash.new

			@@associations[:belongs_to][association_id] = { :class_name => options[:class_name].to_s.camelize, :foreign_key => options[:foreign_key], :conditions => options[:conditions] }
		end

		def cast_from_string(value, field)
			type = self.fields[field]
			
			return nil if (value == "" || value == nil) && type != :string

			begin
				return value.to_i if type == :int
				return value.to_f if type == :float
				return Date.parse(value) if type == :date
				return Time.parse(value) if type == :time
				return DateTime.parse(value) if type == :date_time
			rescue Class::ArgumentError => e
				raise SaasuConnect::Base::ArgumentError.new e.message	
			end
			return value == "true" if type == :bool
			return value
		end

		def cast_to_string(value, field)
			type = self.fields[field]

			return value ? "true" : "false" if type == :bool unless value == nil
			return value.strftime("%Y-%m-%d") if type == :date unless value == nil
			return value.strftime("%H:%M:%S %p") if type == :time unless value == nil
			return value.strftime("%d/%m/%Y %H:%M:%S %p") if type == :date_time unless value == nil
			return value.to_s
		end

		# Converts an XML node into a Ruby Object
		def cast_from_node(value, field)
			cast_from_string(value.text, field)
		end

		# Converts a Ruby Object into an XML Node
		def cast_to_node(value, field)
			cast_to_string(value, field)
		end

		def self.find(type, options = {})
			options = options.dup
			
			access_key = options.delete(:access_key) if options[:access_key] != nil
			file_uid = options.delete(:file_uid) if options[:file_uid] != nil

			name = self.name.to_s.split("::").pop
			rest = Rest.new(access_key, file_uid)
			
			if type.is_a?(Fixnum) || type.is_a?(Bignum)
				options[:uid] = type
				response = rest.get(name.underscore.camelize(:lower), options)
				doc = Document.new(response)
				if doc.root.elements["errors/error"] != nil && !(nodes = doc.root.elements["errors/error"]).children.empty?
					Base.xml_error nodes do |exception, message|
						raise exception, message
					end
				end
				
				objects = self.deserialize(response)
				
				objects.access_key = access_key
				objects.file_uid = file_uid

				@complete_download = false
			elsif type == :all || type == :first
				response = rest.get((name.underscore + "_list").camelize(:lower), options)
				
				doc = Document.new(response)
				if doc.root.elements["errors/error"] != nil && !(nodes = doc.root.elements["errors/error"]).children.empty?
					Base.xml_error nodes do |exception, message|
						raise exception, message
					end
				end
				
				objects = self.deserialize(response)
				objects.map do |o| 
					o.access_key = access_key
					o.file_uid = file_uid
				end
				
				objects = objects.first if type == :first
				@complete_download = true
			end
			return objects
		end

		def save
			begin
				create_or_update
				return true
			rescue
				return false
			end
		end
		
		def save!
			create_or_update
		end

		def create_or_update
			errors = Tasks.run do |task|
				task.save(self)
				task.perform(self.access_key, self.file_uid)
			end
			raise errors.first[0], errors.first[1] if !errors.empty?
		end

		# Build the XML data ready for posting
		def build_data(action, options = {})
			# Ignore the action parameter because it means nothing at the moment
			options ||= Hash.new
			options[:indent] ||= 2
			xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])

			xml.instruct! if !options[:skip_instruct]

			self.serialize(options)
		end

		def delete
			rest = Rest.new(self.access_key, self.file_uid)
			name = self.class.to_s.split("::").pop
			response = rest.delete(name.underscore, :uid => self.uid)

			doc = Document.new(response)
		
			if doc.root.elements["errors/error"] != nil && !(nodes = doc.root.elements["errors/error"]).children.empty?
				Base.xml_error(nodes) do |exception, message|
					raise exception, message
				end
			end
		end

		def self.xml_error(node, &block)
			type = nil
			message = nil

			node.children.each do |child|
				if child.node_type == :element
					message = child.text if child.name == "message"
					type = child.text if child.name == "type"
				end
			end

			const_set(type, Class.new(Error)) unless defined?(type)
			yield(const_get(type), message)
		end

		# Parses the XML that is getting returned from the web service - must be overridden
		def self.deserialize(xml, options = {})
			name = self.name.to_s.split("::").pop
			
			doc = Document.new(xml)
			objects = Array.new

			if doc.root.name == "#{name.underscore.camelize(:lower)}ListResponse"
				nodes = doc.root.elements["#{name.underscore.camelize(:lower)}List"]

				nodes.children.each do |item|
					if item.node_type == :element && item.name.underscore == "#{name.underscore}_list_item"
						objects << SaasuConnect.const_get(name).obj_from_xml(item)
					end
				end
				return objects

			elsif doc.root.name == "#{name.underscore.camelize(:lower)}Response"
				node = doc.root.elements[name.underscore.camelize(:lower)]
				
				object = SaasuConnect.const_get(name).obj_from_xml(node)
				
				object.uid = node.attributes["uid"].to_i
				object.last_updated_uid = node.attributes["lastUpdatedUid"]

				# These are (more) invoice specific exceptions
				if node.attributes["generatedInvoiceNumber"] != nil
					object.invoice_number = node.attributes["generatedInvoiceNumber"]
				end
				if node.attributes["sentToContact"] != nil
					object.sent_to_contact = node.attributes["sentToContact"]
				end
				return object
			end
		end

		# Call that builds the XML that will be sent to the web service
		def serialize(options = {})
			name = self.class.to_s.split("::").pop
			
			options[:indent] ||= 2
			xml = options[:builder] ||= Builder::XmlMarkup.new(:indent => options[:indent])
			xml.instruct! unless options[:skip_instruct]
			
			if self.send(self.primary_key) != nil
				options[:root] ||= "update#{name.underscore.camelize}"

				output = xml.tag!(options[:root]) do
					xml.tag!(name.underscore.camelize(:lower), :uid => self.uid, :lastUpdatedUid => self.last_updated_uid) do
						self.fields.keys.each do |field|
							xml.tag!(field.to_s.camelize(:lower).to_s, cast_to_node(attributes[field], field)) unless (cast_to_node(attributes[field], field) == "" || field == :uid || field == :last_updated_uid)
						end
					end
				end
			else
				options[:root] ||= "insert#{name.underscore.camelize}"
				
				output = xml.tag!(options[:root]) do
					xml.tag!(name.underscore.camelize(:lower), :uid => 0) do
						self.fields.keys.each do |field|
							xml.tag!(field.to_s.camelize(:lower).to_s, cast_to_node(attributes[field], field)) unless cast_to_node(attributes[field], field) == "" || field == :uid || field == :last_updated_uid
						end
					end
				end
			end
			
			output
		end

		def self.obj_from_xml(item)
			name = self.name.to_s.split("::").pop
			
			object = SaasuConnect.const_get(name).new
			
			item.children.each do |node|
				if node.node_type == :element
					node_name = node.name.underscore.to_sym
					
					if node_name.to_s == name.underscore + "_uid" && object.primary_key != nil
						object.send(object.primary_key.to_s + "=", object.cast_from_node(node, object.primary_key))
					else
						object.send(node_name.to_s + "=", object.cast_from_node(node, node_name))
					end
				end
			end

			return object
		end


		def to_xml(options = {})
			self.attributes.to_xml(options)
		end

		def method_missing(method_id, *params)
			name = self.class.to_s.split("::").pop
			
			if method_id.id2name.last == "="
				method = method_id.id2name[0..-2].intern

				# The second check here facilitates virtual methods prefexed by the class name (to stop clashes) with out breaking
				# methods that are legitimately prefixed by the class name
				if self.fields.keys.include?(method) || self.fields.keys.include?(method.to_s.gsub(name.underscore + "_", "").intern)
					self.attributes[method] = params[0] 
					return
				end
			else
				method = method_id.id2name.intern
				
				# Download the full object if it was only partially downloaded before
				if self.fields.keys.include?(method) || self.fields.keys.include?(method.to_s.gsub(name.underscore + "_", "").intern)
					if self.primary_key != nil && self.attributes[self.primary_key] != nil && !@complete_download
						if self.attributes[method] == nil
							# I'm worried about the face I need to include a to_i, it should be already cast
							self.attributes = SaasuConnect.const_get(name).find(self.attributes[self.primary_key].to_i, { :access_key => self.access_key, :file_uid => self.file_uid }).attributes
							@complete_download = true
						end
					end
	
					return self.attributes[method]
				end
			end

			# Check the has many relations
			if @@associations.has_key?(:has_many) && @@associations[:has_many].has_key?(method)
				if method_id.id2name.last == "="
					method = method_id.id2name[0..-2].intern
					return cached[method] = params[0]
				else
					if !cached.has_key?(method)
						name = self.class.to_s.split("::").pop
						@@associations[:has_many][method][:conditions][@@associations[:has_many][method][:foreign_key]] ||= self.send(self.primary_key)
						cached[method] = Kernel.const_get(@@associations[:has_many][method][:class_name]).find(:all, @@associations[:has_many][method][:conditions])
						cached[method].each { |c| c.send(name.underscore.singularize + "=", self) }
					end

					return cached[method]
				end
			end

			if @@associations.has_key?(:belongs_to) && @@associations[:belongs_to].has_key?(method)
				if method_id.id2name.last == "="
					method = method_id.id2name[0..-2].intern
					return cached[method] = params[0]
				else
					if !cached.has_key?(method)
						name = self.class.to_s.split("::").pop
						cached[method] = SaasuConnect.const_get(@@associations[:belongs_to][method][:class_name]).find(self.send(@@associations[:belongs_to][method][:foreign_key]))
						cached[method].send(name.underscore.pluralize + "=", self)
					end
					return cached[method]
				end
			end
			
			super
		end

		def reset
			@cached = Hash.new
			@attributes = Hash.new
		end

		def to_s
			self.inspect
		end

		def to_json(options = {})
			@attributes.to_json(options)
		end

		include ActiveRecord::Validations
		
	protected
		def cached
			@cached ||= Hash.new
		end
	end

end
