require 'test/unit'
require 'yaml'

SAASU_ACCESS_KEY = "1B2A-7638-716B-43D3-B51F-96B0-0A5A-116C"
SAASU_FILE_UID = "102"
RAILS_ENV = "test"

require 'rubygems'
	
require 'rexml/document'
require 'active_record'
require 'action_controller'

require File.dirname(__FILE__) +  '/../lib/saasu_connect'

class Test::Unit::TestCase
	include SaasuConnect
	include REXML

	def self.fixtures(*fixtures)
		@@fixtures ||= Array.new
		@@fixtures.concat(fixtures)
	end

	def clear_fixtures(endpoint)
		if endpoint == :invoice
			uri = URI.parse("https://secure.saasu.com/sandbox/webservices/rest/r1/#{endpoint.to_s.camelize}List?wsaccesskey=#{SAASU_ACCESS_KEY}&FileUid=#{SAASU_FILE_UID}&transactionType=S")
		elsif endpoint == :purchase_invoice
			uri = URI.parse("https://secure.saasu.com/sandbox/webservices/rest/r1/InvoiceList?wsaccesskey=#{SAASU_ACCESS_KEY}&FileUid=#{SAASU_FILE_UID}&transactionType=P")
		else
			uri = URI.parse("https://secure.saasu.com/sandbox/webservices/rest/r1/#{endpoint.to_s.camelize}List?wsaccesskey=#{SAASU_ACCESS_KEY}&FileUid=#{SAASU_FILE_UID}")
		end

		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true
		response = http.get(uri.path + "?" + uri.query)

		case response
		when Net::HTTPSuccess
			xml = response.body.to_s
			doc = Document.new(xml)
			
			XPath.each(doc.root, "/#{endpoint.to_s.camelize(:lower)}ListResponse/#{endpoint.to_s.camelize(:lower)}List/#{endpoint.to_s.camelize(:lower)}ListItem/#{endpoint.to_s.camelize(:lower)}Uid") { |child|
				uri = URI.parse("https://secure.saasu.com/sandbox/webservices/rest/r1/#{endpoint.to_s.camelize(:lower)}?wsaccesskey=#{SAASU_ACCESS_KEY}&FileUid=#{SAASU_FILE_UID}&uid=#{child.text}")
				http = Net::HTTP.new(uri.host, uri.port)
				http.use_ssl = true
				http.delete(uri.path + "?" + uri.query)
			}
		else
			raise StandardError, response.code + ": " + uri.path + "?" + uri.query
		end
	end

	def seed_fixtures(endpoint, ids = Hash.new)
		data = ''
		f = File.open(File.dirname(__FILE__) +  '/fixtures/' + endpoint.to_s+ '.xml', 'r')
		data = f.read 
		f.close

		unless ids.keys.empty?
			doc = Document.new(data.to_s)
			ids.keys.each { |key|
				if endpoint == :invoice && key == :transaction_category
					# Humph more exceptions - probably could do some better key searching...
					XPath.each(doc.root, "/tasks/insertInvoice/invoice/invoiceItems/serviceInvoiceItem/accountUid") { |node|
						node.text = ids[key][node.text.to_i]
					}
					XPath.each(doc.root, "/tasks/insertInvoice/invoice/invoiceItems/itemInvoiceItem/accountUid") { |node|
						node.text = ids[key][node.text.to_i]
					}
				elsif endpoint == :invoice && key == :inventory_item
					XPath.each(doc.root, "/tasks/insertInvoice/invoice/invoiceItems/itemInvoiceItem/inventoryItemUid") { |node|
						node.text = ids[key][node.text.to_i]
					}
				elsif endpoint == :inventory_item && key == :transaction_category
					XPath.each(doc.root, "/tasks/insertInventoryItem/inventoryItem/saleIncomeAccountUid") { |node|
						node.text = ids[key][node.text.to_i]
					}
				else
					XPath.each(doc.root, "/tasks/insert#{endpoint.to_s.camelize}/#{endpoint.to_s}/#{key.to_s.camelize(:lower)}") { |node|
						node.text = ids[key][node.text.to_i]
					}
				end
			}
			data = doc.to_s
		end

		uri = URI.parse("https://secure.saasu.com/sandbox/webservices/rest/r1/tasks?wsaccesskey=#{SAASU_ACCESS_KEY}&FileUid=#{SAASU_FILE_UID}")
			
		http = Net::HTTP.new(uri.host, uri.port)
		http.use_ssl = true

		response = http.request_post(uri.path + "?" + uri.query, data)
		
		doc = Document.new(response.body.to_s)
		XPath.each(doc.root, "/tasksResponse/insert#{endpoint.to_s.camelize}Result/errors/error/message") { |node|
			assert false, node.text
		}
		data = doc.to_s
		
		inserted_ids = Array.new
		XPath.each(doc.root, "/tasksResponse/insert#{endpoint.to_s.camelize}Result") { |node|
			inserted_ids << node.attributes["insertedEntityUid"].to_i
		}
		return inserted_ids
	end

	def setup
		clear_order = @@fixtures.reverse
		seed_order = @@fixtures

		clear_order.each { |c| clear_fixtures(c) }

		uids = Hash.new
		seed_order.each { |s|
			uids[s] = seed_fixtures(s, uids)
		}
	end
end
