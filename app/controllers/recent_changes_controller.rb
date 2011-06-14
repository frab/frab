class RecentChangesController < ApplicationController

  before_filter :authenticate_user!
  before_filter :require_admin

  def index
    @audits = Audit.reorder("created_at DESC").paginate(
      :page => params[:page],
      :per_page => 25
    )
  end

  def show
    @audit = Audit.find(params[:id])
  end

end
