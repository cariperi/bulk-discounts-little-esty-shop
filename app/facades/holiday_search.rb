require './app/services/nager_service'

class HolidaySearch
  def top_holidays(count)
    service.get_holidays(count).map do |data|
      Holiday.new(data)
    end
  end

  def service
    NagerService.new
  end
end
