class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  protected

  def authenticate_player!
    if player_signed_in?
      super
    else
      redirect_to new_player_session_path, notice: 'Please Login'
    end
  end
end
