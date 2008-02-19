require File.dirname(__FILE__) + '/abstract_unit'

class ContactTest < Test::Unit::TestCase
	fixtures :transaction_category, :bank_account, :contact, :invoice

	def test_single_contact
		postal_address = PostalAddress.new
		postal_address.street = "1/10 Queens Cres"
		postal_address.city = "Mt Lawley"
		postal_address.state = "Western Australia"
		postal_address.post_code = "6050"
		postal_address.country = "Australia"

		other_address = PostalAddress.new
		other_address.street = "Level 2, 90 King St"
		other_address.city = "Perth"
		other_address.state = "Western Australia"
		other_address.post_code = "6000"
		other_address.country = "Australia"

		contact = Contact.new
		contact.salutation = "Mr."
		contact.given_name = "Myles"
		contact.middle_initials = "D"
		contact.family_name = "Eftos"
		contact.organisation_name = "MadPilot Productions"
		contact.organisation_abn = "27 081 934 918"
		contact.organisation_website = "http://www.madpilot.com.au"
		contact.organisation_position = "Owner"
		contact.contact_id = "API 1"
		contact.abn = "27 123 456 789" # This does nothing
		contact.website_url = "http://www.madpilot.com.au"
		contact.email = "myles@madpilot.com.au"
		contact.main_phone = "+61 8 9456 7651"
		contact.home_phone = "+61 8 9271 3073"
		contact.fax = "+618 9467 6289"
		contact.mobile_phone = "+61 409 293 183"
		contact.other_phone = "+61 8 6424 8234"
		contact.status_uid = 0
		contact.industry_uid = 0
		contact.postal_address = postal_address
		contact.other_address = other_address
		contact.is_active = true
		contact.accept_direct_deposit = true
		contact.direct_deposit_account_name = "MadPilot Productions"
		contact.direct_deposit_bsb = "306 123"
		contact.direct_deposit_account_number = "4567 1234"
		contact.accept_cheque = true
		contact.cheque_payable_to = "Myles Eftos"

		contact.save!

		assert_not_nil contact.uid
		assert_not_nil contact.last_updated_uid

		contact_return = Contact.find(contact.uid)

		assert_equal "Mr.", contact_return.salutation
		assert_equal "Myles", contact_return.given_name
		assert_equal "D", contact_return.middle_initials
		assert_equal "Eftos", contact_return.family_name
		assert_equal "MadPilot Productions", contact_return.organisation_name
		assert_equal "27 081 934 918", contact_return.organisation_abn
		assert_equal "http://www.madpilot.com.au", contact_return.organisation_website
		assert_equal "Owner", contact_return.organisation_position
		assert_equal "API 1", contact_return.contact_id
		#assert_equal "27 123 456 789", contact_return.abn - This seems to do nothing
		assert_equal "http://www.madpilot.com.au", contact_return.website_url
		assert_equal "myles@madpilot.com.au", contact_return.email
		assert_equal "61894567651", contact_return.main_phone
		assert_equal "61892713073", contact_return.home_phone
		assert_equal "61894676289", contact_return.fax
		assert_equal "61409293183", contact_return.mobile_phone
		assert_equal "61864248234", contact_return.other_phone
		assert_nil contact_return.status_uid
		assert_nil contact_return.industry_uid
		assert_equal true, contact_return.is_active
		assert_equal true, contact_return.accept_direct_deposit
		assert_equal "MadPilot Productions", contact_return.direct_deposit_account_name
		assert_equal "306123", contact_return.direct_deposit_bsb
		assert_equal "4567 1234", contact_return.direct_deposit_account_number
		assert_equal true, contact_return.accept_cheque
		assert_equal "Myles Eftos", contact_return.cheque_payable_to

		assert_equal "1/10 Queens Cres", contact_return.postal_address.street
		assert_equal "Mt Lawley", contact_return.postal_address.city
		assert_equal "Western Australia", contact_return.postal_address.state
		assert_equal "6050", contact_return.postal_address.post_code
		assert_equal "Australia", contact_return.postal_address.country

		assert_equal "Level 2, 90 King St", contact_return.other_address.street
		assert_equal "Perth", contact_return.other_address.city
		assert_equal "Western Australia", contact_return.other_address.state
		assert_equal "6000", contact_return.other_address.post_code
		assert_equal "Australia", contact_return.other_address.country

		contact = contact_return.dup

		postal_address = PostalAddress.new
		postal_address.street = "PO Box 123"
		postal_address.city = "Perth"
		postal_address.state = "Western Australia"
		postal_address.post_code = "6900"
		postal_address.country = "Australia"

		other_address = PostalAddress.new
		other_address.street = "5/123 Beaufort St"
		other_address.city = "Mt Lawley"
		other_address.state = "Western Australia"
		other_address.post_code = "6050"
		other_address.country = "Australia"

		contact.salutation = "Mrs."
		contact.given_name = "Kathy"
		contact.middle_initials = "L"
		contact.family_name = "Taylor"
		contact.organisation_name = "ACME Corporation"
		contact.organisation_abn = "27 081 934 918"
		contact.organisation_website = "http://www.acme.com"
		contact.organisation_position = "Accounts Manager"
		contact.contact_id = "API 1"
		#contact.abn = "27 123 456 78"
		contact.website_url = "http://www.acme.com"
		contact.email = "kathy@acme.com"
		contact.main_phone = "+61 8 9444 1234"
		contact.home_phone = "+61 8 9444 4321"
		contact.fax = "+618 9444 9876"
		contact.mobile_phone = "+61 412 345 678"
		contact.other_phone = "+61 8 9444 7890"
		contact.status_uid = 0
		contact.industry_uid = 0
		contact.postal_address = postal_address
		contact.other_address = other_address
		contact.is_active = true
		contact.accept_direct_deposit = true
		contact.direct_deposit_account_name = "ACME Corp"
		contact.direct_deposit_bsb = "123 321"
		contact.direct_deposit_account_number = "9876 1234"
		contact.accept_cheque = true
		contact.cheque_payable_to = "Kathy Smith"

		contact.save!

		contact_return = Contact.find(contact.uid)
		assert_equal contact.last_updated_uid, contact_return.last_updated_uid

		assert_equal "Mrs.", contact_return.salutation
		assert_equal "Kathy", contact_return.given_name
		assert_equal "L", contact_return.middle_initials
		assert_equal "Taylor", contact_return.family_name
		assert_equal "ACME Corporation", contact_return.organisation_name
		assert_equal "27 081 934 918", contact_return.organisation_abn
		assert_equal "http://www.acme.com", contact_return.organisation_website
		assert_equal "Accounts Manager", contact_return.organisation_position
		assert_equal "API 1", contact_return.contact_id
		#assert_equal "27 123 456 789", contact_return.abn - This seems to do nothing
		assert_equal "http://www.acme.com", contact_return.website_url
		assert_equal "kathy@acme.com", contact_return.email
		assert_equal "61894441234", contact_return.main_phone
		assert_equal "61894444321", contact_return.home_phone
		assert_equal "61894449876", contact_return.fax
		assert_equal "61412345678", contact_return.mobile_phone
		assert_equal "61894447890", contact_return.other_phone
		assert_nil contact_return.status_uid
		assert_nil contact_return.industry_uid
		assert_equal true, contact_return.is_active
		assert_equal true, contact_return.accept_direct_deposit
		assert_equal "ACME Corp", contact_return.direct_deposit_account_name
		assert_equal "123321", contact_return.direct_deposit_bsb
		assert_equal "9876 1234", contact_return.direct_deposit_account_number
		assert_equal true, contact_return.accept_cheque
		assert_equal "Kathy Smith", contact_return.cheque_payable_to

		assert_equal "PO Box 123", contact_return.postal_address.street
		assert_equal "Perth", contact_return.postal_address.city
		assert_equal "Western Australia", contact_return.postal_address.state
		assert_equal "6900", contact_return.postal_address.post_code
		assert_equal "Australia", contact_return.postal_address.country

		assert_equal "5/123 Beaufort St", contact_return.other_address.street
		assert_equal "Mt Lawley", contact_return.other_address.city
		assert_equal "Western Australia", contact_return.other_address.state
		assert_equal "6050", contact_return.other_address.post_code
		assert_equal "Australia", contact_return.other_address.country
	end

	def test_list_contacts
		contacts = Contact.find :all

		assert_equal 3, contacts.size

		contact = contacts.first

		assert_equal "Mr.", contact.salutation
		assert_equal "John", contact.given_name
		assert_equal "Smith", contact.family_name
		assert_equal "ACME Pty Ltd", contact.organisation_name
		assert_equal "www.acme.com", contact.organisation_website
		assert_equal "Director", contact.organisation_position
		assert_equal "67 093 453 886", contact.abn
		assert_equal "john.smith@acme.com.au", contact.email
		assert_equal "02 9999 9999", contact.main_phone
		assert_equal "02 8888 8888", contact.home_phone
		assert_equal "0444 444 444", contact.mobile_phone
		assert_equal "3/33 Victory Av", contact.postal_address.street
		assert_equal "North Sydney", contact.postal_address.city
		assert_equal "NSW", contact.postal_address.state
		assert_equal "2112", contact.postal_address.post_code
		assert_equal "Australia", contact.postal_address.country
		assert_equal "12/22", contact.other_address.street
		assert_equal "Pennant Hills", contact.other_address.city
		assert_equal "NSW", contact.other_address.state
		assert_equal "2122", contact.other_address.post_code
		assert_equal "Australia", contact.other_address.country

	end
end
