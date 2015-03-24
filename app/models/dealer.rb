# == Schema Information
#
# Table name: dealers
#
#  id                :integer          not null, primary key
#  code              :string(255)
#  name              :string(255)
#  sales_code_prefix :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Dealer < ActiveRecord::Base
  attr_accessible :code, :name, :sales_code_prefix
end
