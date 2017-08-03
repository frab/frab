class HomeController < ApplicationController
  def index
    @conferences = Conference.future.includes(:call_for_participation).paginate(page: page_param)
  end

  def past
    @conferences = Conference.past.includes(:call_for_participation).paginate(page: page_param)
    render 'index'
  end
end
