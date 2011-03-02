module ConferencesHelper

  def timeslot_durations
    result = Array.new
    [1,5,10,15,20,30,45,60,90,120].each do |duration|
      result << [duration_to_time(duration), duration]
    end
    result
  end

end
