require 'csv'

namespace :csv_create do
  desc "create CSV file with sample Bulk Discount data"
  task bulk_discounts: :environment do

    rows = FactoryBot.build_list(:bulk_discount, 200) do |record|
      record.save!
    end

    CSV.open('db/data/bulk_discounts.csv', 'w') do |csv|
      csv << ['id', 'merchant_id', 'threshold_quantity', 'percentage']

      rows.each do |row|
        merchant_id = rand(1..100)
        row_array = [row.id, merchant_id, row.threshold_quantity, row.percentage]
        csv << row_array.to_csv.split(',')
      end
    end
  end
end
