require File.dirname(__FILE__) + '/abstract_unit'

class BankAccountTest < Test::Unit::TestCase
	fixtures :bank_account

	def test_single_bank_account
		bank_account = BankAccount.new
		bank_account.bank_account_type = "Asset"
		bank_account.bank_account_name = "BWA"
		bank_account.is_active = true
		bank_account.display_name = "BankWest"
		bank_account.bsb = "222 222"
		bank_account.account_number = "4567 4567"

		bank_account.save!

		assert_not_nil bank_account.uid
		assert_not_nil bank_account.last_updated_uid

		bank_account_return = BankAccount.find(bank_account.uid)
		assert_equal "Asset", bank_account_return.bank_account_type
		assert_equal "BWA", bank_account_return.bank_account_name
		# te isActive parameter doesn't seem to be sent - check this with the Saasu guys
		#assert_equal true, bank_account_return.is_active
		assert_equal "BankWest", bank_account_return.display_name
		assert_equal "222-222", bank_account_return.bsb
		assert_equal "4567 4567", bank_account_return.account_number

		bank_account = bank_account_return.dup

		bank_account.name = "NAB"
		bank_account.is_active = true
		bank_account.display_name = "National Australia Bank"
		bank_account.bsb = "444 444"
		bank_account.account_number = "4444 4444"

		bank_account.save!

		assert_not_equal bank_account_return.last_updated_uid, bank_account.last_updated_uid

		assert_equal "Asset", bank_account.bank_account_type
		assert_equal "NAB", bank_account.bank_account_name
		# te isActive parameter doesn't seem to be sent - check this with the Saasu guys
		#assert_equal true, bank_account.is_active
		assert_equal "National Australia Bank", bank_account.display_name
		assert_equal "444-444", bank_account.bsb
		assert_equal "4444 4444", bank_account.account_number
	end

	def test_list_bank_account
		bank_accounts = BankAccount.find :all

		# There is a default account that isn't included in the fixtures, making the total 3
		assert_equal 3, bank_accounts.size

		bank_account = bank_accounts.first
		assert_equal "Asset", bank_account.bank_account_type
		assert_equal "ANZ", bank_account.bank_account_name
		#assert_equal true, bank_account.is_active
		assert_equal "ANZ", bank_account.display_name
		assert_equal "111-111", bank_account.bsb
		assert_equal "1111 1111", bank_account.account_number
	end
end	
