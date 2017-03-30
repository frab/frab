require 'active_support/concern'

module Searchable
  extend ActiveSupport::Concern

  private

  def perform_search(models, params, options)
    if params.key?(:term) and params[:term].present?
      term = params[:term]
      terms = options.map { |o| [o, term] }.to_h
      terms[:m] = 'or'
      terms[:s] = params.dig(:q, :s)
      models.ransack(terms)
    else
      models.ransack(params[:q])
    end
  end
end
