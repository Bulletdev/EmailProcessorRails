Rails.logger.debug '=' * 70
Rails.logger.debug 'CUSTOMERS WITH PRODUCT CODES'
Rails.logger.debug '=' * 70
Rails.logger.debug ''

if Customer.any?
  Customer.order(:created_at).each_with_index do |customer, index|
    Rails.logger.debug { "#{index + 1}. #{customer.name}" }
    Rails.logger.debug { "   Email:        #{customer.email || '(not provided)'}" }
    Rails.logger.debug { "   Phone:        #{customer.phone || '(not provided)'}" }
    Rails.logger.debug { "   Product Code: #{customer.product_code || '(not extracted)'}" }
    Rails.logger.debug { "   Subject:      #{customer.subject}" }
    Rails.logger.debug ''
  end

  with_code = Customer.where.not(product_code: [nil, '']).count
  total = Customer.count
  percentage = (with_code.to_f / total * 100).round(1)

  Rails.logger.debug '=' * 70
  Rails.logger.debug 'Statistics:'
  Rails.logger.debug { "  Total Customers:           #{total}" }
  Rails.logger.debug { "  With Product Code:         #{with_code}" }
  Rails.logger.debug { "  Extraction Success Rate:   #{percentage}%" }
  Rails.logger.debug '=' * 70
else
  Rails.logger.debug 'No customers found in database.'
  Rails.logger.debug 'Run: docker-compose exec -T app bundle exec rails runner lib/scripts/test_product_extraction.rb'
end
