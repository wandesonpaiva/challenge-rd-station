class TestHelpersController < ApplicationController
  def set_session
    session[:cart_id] = params[:cart_id]
    head :ok
  end
end
