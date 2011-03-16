class RecentChangesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :require_admin

  def index
    @audits = Audit.order("created_at DESC").paginate(
      :page => params[:page],
      :per_page => 25
    )
  end

end
