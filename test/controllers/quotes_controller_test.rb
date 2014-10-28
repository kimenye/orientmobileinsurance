require "test_helper"

class QuotesControllerTest < ActionController::TestCase

	test "It should allow for uploading Policy details and creating the necessary records" do

		Device.create! vendor: "Nokia", model: "520- LUMIA", marketing_name: "Nokia Lumia 520", catalog_price: 18500, stock_code: "YCS29E"
		Agent.create! code: "NK001", outlet_name: "Nokia Care"
		Quote.delete_all
		Customer.delete_all
		InsuredDevice.delete_all
		Policy.delete_all
		Sms.delete_all

		post :upload_policy_details, { file:  fixture_file_upload('/files/nokia_policies.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet') }
		
		doc = SimpleXlsxReader.open(fixture_file_upload('/files/nokia_policies.xlsx', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'))
		count = doc.sheets.first.rows[1..doc.sheets.first.rows.length].count

		assert_equal count, Customer.count
		assert_equal count, InsuredDevice.count
		assert_equal count, Policy.count
		assert_equal count, Quote.count
		assert_equal count, Sms.count
	end
end