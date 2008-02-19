module SaasuConnect
	class Task
		attr_accessor :model, :action

		def initialize(model, action)
			self.model = model
			self.action = action
		end
	end

	class TaskRunner
		include REXML

		@@queue = Array.new

		def save(model)
			@@queue << Task.new(model, :save)
		end

		def perform(access_key = SAASU_ACCESS_KEY, file_uid = SAASU_FILE_UID)
			rest = Rest.new(access_key, file_uid)
			
			options = Hash.new
			options[:indent] = 2
			xml = options[:builder] = Builder::XmlMarkup.new(:indent => options[:indent])

			xml.instruct!
			options[:skip_instruct] = true
				
			output = xml.tasks do
				@@queue.each { |q|
					q.model.build_data(q.action, options)
				}
			end
	
			response = rest.send("post_tasks", :data => output)
			
			doc = Document.new(response)
			errors = Array.new
			index = 0
			doc.root.children.each { |child|
				# Get the action and model from the node name - Looks like insertContactResponse which has an action of insert and a response
				# class of ContactResponse
				if child.node_type == :element
					# Check for errors
					# TODO User XPATH for this
					if child.name == "errors" || child.elements["errors"] != nil
						# Failed, let's add the exception to the stack
						(child.name == "errors" ? child : child.elements["errors"]).children.each do |error|
							if error.node_type == :element
								Base.xml_error error do |exception|
									errors << exception
								end
							end
						end
					else
						response_elements = child.name.underscore.split("_")
						action = response_elements.shift.to_sym
						model = response_elements[0..-2].join("_").camelize.to_sym
					
						if action == :insert
							@@queue[index].model.uid = child.attribute("insertedEntityUid").value.to_i unless child.attribute("insertedEntityUid") == nil
						end
						@@queue[index].model.last_updated_uid = child.attribute("lastUpdatedUid").value unless child.attribute("lastUpdatedUid") == nil
					end
					index += 1
				end
			}

			# Clear the queue ready for the next block
			@@queue.clear
			return errors
		end
	end

	class Tasks
		def self.run(&block)
			block.call(TaskRunner.new)
		end
	end
end
