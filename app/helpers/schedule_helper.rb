module ScheduleHelper

  def day_active?(index)
    classes = nil
    classes = "active" if params[:day].to_i == index
    classes = "#{classes} first" if index == 0
  end

end
