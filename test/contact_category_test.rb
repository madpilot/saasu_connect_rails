require File.dirname(__FILE__) + '/abstract_unit'

class ContactCategoryTest < Test::Unit::TestCase
	fixtures :contact_category

	def test_single_contact_category
		contact_category = ContactCategory.new
		contact_category.contact_category_type = "Status"
		contact_category.contact_category_name = "Charity"
		contact_category.save!

		assert_not_nil contact_category.uid
		assert_not_nil contact_category.last_updated_uid

		contact_category_return = ContactCategory.find(contact_category.uid)

		assert_equal "Status", contact_category_return.contact_category_type
		assert_equal "Charity", contact_category_return.contact_category_name

		contact = contact_category.dup

		contact.contact_category_name = "Personal"
		contact.save!

		contact_return = ContactCategory.find(contact_category.uid)
		assert_equal "Status", contact_category_return.contact_category_type
		assert_equal "Personal", contact_category.contact_category_name
	end

	def test_list_contact_category
		contact_category = ContactCategory.find :all
		assert_equal 2, contact_category.size

		contact_category = contact_category.first
		assert_equal "Status", contact_category.contact_category_type
		assert_equal "Customer", contact_category.contact_category_name
	end
end
