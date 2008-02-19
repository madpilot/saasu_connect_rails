require 'rexml/document'

$LOAD_PATH.unshift  File.join(File.dirname(__FILE__))

require 'errors/error'
require 'errors/connection_exception'
require 'errors/security_exception'
require 'errors/record_not_found_exception'
require 'errors/schema_validation_exception'
require 'errors/invalid_reference_exception'
require 'errors/data_access_exception'
require 'rest'
require 'base'
require 'contact'
require 'invoice'
require 'tasks'
require 'postal_address'
require 'bank_account'
require 'contact_category'
require 'transaction_category'
require 'item_invoice_item'
require 'service_invoice_item'

$LOAD_PATH.shift

module SaasuConnect
	SAASU_VERSION = "1.0"
end
