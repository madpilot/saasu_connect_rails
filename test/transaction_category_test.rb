require File.dirname(__FILE__) + '/abstract_unit'

class TransactionCategoryTest < Test::Unit::TestCase
	fixtures :transaction_category

	def test_single_transaction_category
		transaction_category = TransactionCategory.new
		transaction_category.transaction_category_type = "Expense"
		transaction_category.transaction_category_name = "Misc"
		transaction_category.save!

		assert_not_nil transaction_category.uid
		assert_not_nil transaction_category.last_updated_uid

		transaction_category_return = TransactionCategory.find(transaction_category.uid)

		assert_equal "Expense", transaction_category_return.transaction_category_type
		assert_equal "Misc", transaction_category_return.transaction_category_name

		transaction = transaction_category.dup

		transaction.transaction_category_name = "Postage"
		transaction.save!

		transaction_return = TransactionCategory.find(transaction_category.uid)
		assert_equal "Expense", transaction_category_return.transaction_category_type
		assert_equal "Postage", transaction_category.transaction_category_name
	end

	def test_list_transaction_category
		transaction_category = TransactionCategory.find :all
		assert_equal 47, transaction_category.size

		transaction_category = transaction_category.first
		assert_equal "Asset", transaction_category.transaction_category_type
		assert_equal "Deposit Paid", transaction_category.transaction_category_name
	end
end
