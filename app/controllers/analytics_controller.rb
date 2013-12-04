class AnalyticsController < ApplicationController
	layout "analytics"

	def index

		devices_data = GoogleVisualr::DataTable.new
		@enquiries = Enquiry.all
		@quotes = Quote.all
		@policies = Policy.all

		@payments = Payment.all
		@total = 0
		@payments.each do |payment|
			@total += payment.amount
		end

		@insured_value = 0
		@pending = 0
		@policies.each do |policy|
			@insured_value += policy.quote.insured_value
			@pending += policy.pending_amount
		end

		data_table = GoogleVisualr::DataTable.new
		data_table.new_column('string', 'Month')
		data_table.new_column('number', 'Enquiries')
		data_table.new_column('number', 'Policies')
		data_table.add_rows(4)
		data_table.set_cell(0, 0, 'September')
		data_table.set_cell(0, 1, 6000)
		data_table.set_cell(0, 2, 50)
		data_table.set_cell(1, 0, 'October')
		data_table.set_cell(1, 1, 1170)
		data_table.set_cell(1, 2, 60)
		data_table.set_cell(2, 0, 'November')
		data_table.set_cell(2, 1, 660)
		data_table.set_cell(2, 2, 1120)
		data_table.set_cell(3, 0, 'December')
		data_table.set_cell(3, 1, 1030)
		data_table.set_cell(3, 2, 5)

		opts   = { :width => 600, :height => 300, vAxis: {title: 'Month', titleTextStyle: {color: 'red'}} }
		@chart = GoogleVisualr::Interactive::BarChart.new(data_table, opts)

		data_table = GoogleVisualr::DataTable.new
		data_table.new_column('string', 'Type')
		data_table.new_column('number', 'Number')
		data_table.add_rows(5)
		data_table.set_cell(1, 0, 'Claims'     )
  		data_table.set_cell(1, 1, Claim.count )
  		data_table.set_cell(0, 0, 'Policies'      )
  		data_table.set_cell(0, 1, Policy.count  )

  		opts   = { :width => 600, :height => 300, :is3D => true }
  		@piechart = GoogleVisualr::Interactive::PieChart.new(data_table, opts)

	end
end