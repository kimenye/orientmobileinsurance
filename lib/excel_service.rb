require 'axlsx'

class ExcelService

  def self.generate_xlsx quote
    
    p = Axlsx::Package.new
    wb = p.workbook

    wb.add_worksheet(:name => "Stuff") do |sheet|
	sheet.add_row ["First", "Second", "Third"]
	sheet.add_row [1,2,3]
    end

    return p.serialize('quote.xlsx')  
  end

end
