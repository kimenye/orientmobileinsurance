class AnalyticsService

	def self.months_between(start_date, end_date)
		(start_date..end_date)..map{ |m| m.strftime('%Y%m') }.uniq.map{ |m| "#{Date::ABBR_MONTHNAMES[ Date.strptime(m, '%Y%m').mon ]} #{Date.strptime(m,'%Y%m').year}" }
	end

	def self.month_range(month)
		start_of_month = ReminderService._get_start_of_day(Time.parse(month))
		end_of_month = ReminderService._get_end_of_day(start_of_month.end_of_month)
		[start_of_month, end_of_month]
	end

	def self.num_enquiries(month) 
		range = AnalyticsService.month_range(month)

		Enquiry.where("created_at >= ? and created_at <= ?", range.first, range.last).count
	end

	def self.num_policies(month)
	end
end