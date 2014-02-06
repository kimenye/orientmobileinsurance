require 'prawn'

class AttachmentService
	def self.generate_pdf quote
		doc = Prawn::Document.new do |pdf|
			pdf.image "#{Rails.root}/app/assets/images/KOIL_Logo_2013.jpg", :scale => 0.1, :vposition => 0, :position => :left
			
			pdf.move_down 10

			pdf.horizontal_rule

		    pdf.move_down 50
			  
       
			pdf.formatted_text [{:text => "Dear #{quote.customer.name},", :styles => [:italic]}], :size => 12
			
			pdf.move_down 20

			pdf.formatted_text [{:text => "Welcome to Orient Mobile,", :styles => [:bold]}], :size => 30
			pdf.formatted_text [{:text => "Kenya Orient - Because You Can ", :styles => [:italic]}], :size => 12

			pdf.move_down 20

			pdf.text "Thank you for you interest in Orient Mobile. 
			          Find attached a quotation for Orient Mobile for your organisation. ", :size => 12

			

		    data = [ 
		    	["<b>Device</b>", "<b>YOP</b>", "<b>IMEI</b>", "<b>Insured Value</b>", "<b>Premium</b>" ] 
		    ]

		    InsuredDevice.find_all_by_quote_id(quote.id).each do |insured_device|

		    	device          = insured_device.device.name
		    	yop             = insured_device.yop
		    	imei            = insured_device.imei
		    	insurance_value = insured_device.insurance_value.to_s
		    	premium_value   = insured_device.premium_value

		    	data.push [device, yop, imei, insurance_value, premium_value]

		    end

		    total_insurance_value = InsuredDevice.find_all_by_quote_id(quote.id).map {|n| n.insurance_value.to_f}.sum
		    total_premium_value = InsuredDevice.find_all_by_quote_id(quote.id).map {|n| n.premium_value.to_f}.sum

		    data.push [{content: "<b>TOTAL</b>", colspan:3}, "<b>#{total_insurance_value}</b>", "<b>#{total_premium_value}</b>"]





		    pdf.table data, :cell_style => { :inline_format => true, :size => 8 }, :width => 480, :column_widths => [120, 90, 90, 90,90] 
		    pdf.move_down 50
		    pdf.text "Quotation / Account # (Please quote this when making payment): #{quote.account_name}.
		              This Quotation / Account NO is valid until #{quote.expiry_date}. 
		              Payment can be made via MPesa Business No. 513201, 
		              Airtel Money Business Name JAMBOPAY, Visa, MasterCard or Kenswitch. ", :size => 12

		    pdf.move_down 20

		    pdf.horizontal_rule

		    pdf.move_down 20
		      
		    

		    pdf.formatted_text [{:text => "Kind Regards,", :styles => [:bold]}], :size => 12	
		    pdf.formatted_text [{:text => "Orient Mobile Services,", :styles => [:italic]}], :size => 12	
		    pdf.text  "Kenya Orient Insurance Limited" , :size => 12 
		    pdf.text  "Tel: 020 2962000" , :size => 12          
		    pdf.text  "Kenya Orient Insurance Limited" , :size => 12
		end
		doc
	end
end
