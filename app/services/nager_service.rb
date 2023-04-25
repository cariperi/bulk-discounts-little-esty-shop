require 'httparty'
require './app/poros/holiday'

class NagerService
  @@country_code_US = 'US'

  def get_holidays(count)
    result = get_url("https://date.nager.at/api/v3/NextPublicHolidays/#{@@country_code_US}")
    result[0...count]
  end

  def get_url(url)
    response = HTTParty.get(url)
    JSON.parse(response.body, symbolize_names: true)
  end
end
