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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :dealer do
    code "MyString"
    name "MyString"
    sales_code_prefix "MyString"
  end
end
