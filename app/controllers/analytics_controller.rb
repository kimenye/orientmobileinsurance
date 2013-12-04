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

		start_month = Date.parse('August 2013')
		months = AnalyticsService.months_between(start_month, Date.today)

		data_table = GoogleVisualr::DataTable.new
		data_table.new_column('string', 'Month')
		data_table.new_column('number', 'Enquiries')
		data_table.new_column('number', 'Policies')

		data_table.add_rows(months.count)
		i = 0


		overall = GoogleVisualr::DataTable.new
		overall.new_column('string', 'Month')
		overall.new_column('number', 'Leads')
		overall.new_column('number', 'Policies')		
		overall.new_column('number', 'Claims')
		
		overall.add_rows(months.count)

		values = GoogleVisualr::DataTable.new
		values.new_column('string', 'Month')
		values.new_column('number', 'Policies')
		values.new_column('number', 'Insured Value')
		values.new_column('number', 'Claims')

		values.add_rows(months.count)

		@claims_paid = 0

		months.each do |month|
			data_table.set_cell(i, 0, month)
			range = AnalyticsService.month_range(month)

			data_table.set_cell(i, 1, Enquiry.where("created_at >= ? and created_at <= ?", range.first, range.last).count)
			data_table.set_cell(i, 2, Policy.where("created_at >= ? and created_at <= ?", range.first, range.last).count)

			overall.set_cell(i, 0, month)
			overall.set_cell(i, 1, Customer.where("created_at >= ? and created_at <= ? and lead = ?", range.first, range.last, true).count)
			overall.set_cell(i, 2, Policy.where("created_at >= ? and created_at <= ?", range.first, range.last).count)
			overall.set_cell(i, 3, Claim.where("created_at >= ? and created_at <= ?", range.first, range.last).count)
			# overall.set_cell(i, 4, 5000)

			values.set_cell(i, 0, month)
			# values.set_cell
			policies = Policy.where("created_at >= ? and created_at <= ?", range.first, range.last)
			policy_amount = 0
			insured_value = 0
			claim_amount = 0
			policies.each do |policy|
				policy_amount += policy.amount_paid
				insured_value += policy.quote.insured_value
			end

			claims = Claim.where("created_at >= ? and created_at <= ?", range.first, range.last)
			claims.each do |claim|
				if claim.is_damage?
					claim_amount += claim.repair_limit if !claim.repair_limit.nil?
				else
					claim_amount += claim.replacement_limit if !claim.replacement_limit.nil?
				end
			end

			values.set_cell(i, 1, policy_amount)
			values.set_cell(i, 2, insured_value)
			values.set_cell(i, 3, claim_amount)
			@claims_paid += claim_amount

			i+=1
		end	


		opts   = { :width => 400, :height => 300, vAxis: {title: 'Month', titleTextStyle: {color: 'red'}} }
		@chart = GoogleVisualr::Interactive::BarChart.new(data_table, opts)

		data_table = GoogleVisualr::DataTable.new
		data_table.new_column('string', 'Type')
		data_table.new_column('number', 'Number')
		data_table.add_rows(5)
		data_table.set_cell(1, 0, 'Claims'     )
  		data_table.set_cell(1, 1, Claim.count )
  		data_table.set_cell(0, 0, 'Policies'      )
  		data_table.set_cell(0, 1, Policy.count  )

  		opts   = { :width => 400, :height => 300, :is3D => true }
  		@piechart = GoogleVisualr::Interactive::PieChart.new(data_table, opts)

		opts   = { :width => 500, :height => 450, :title => '', :legend => 'bottom' }
  		@overall = GoogleVisualr::Interactive::LineChart.new(overall, opts)

		opts   = { :width => 500, :height => 450, :title => '', :legend => 'bottom' }
  		@values = GoogleVisualr::Interactive::LineChart.new(values, opts)

  		vendors = Enquiry.uniq.pluck(:vendor)
  		data_table = GoogleVisualr::DataTable.new
  		data_table.new_column('string', 'Vendor')
  		data_table.new_column('number', 'Number')
		
		vendors.reject!  do |v|
			v.nil?
		end
		data_table.add_rows(vendors.count)

		i = 0
		vendors.each do |vendor|
			amount = Enquiry.where("vendor = ?", vendor).count
			data_table.set_cell(i,0,vendor)
			data_table.set_cell(i,1,amount)
			i += 1
		end
		
		opts = { :width => 400, :height => 300, :is3D => true }
  		@devices = GoogleVisualr::Interactive::PieChart.new(data_table, opts)	
	end
end