module ApplicationHelpers
  def login_view_as(role=:user)
    user = Factory(role)
    fill_in 'user_email', :with => user.email
    fill_in 'user_password', :with => user.password
    click_button 'Sign in'
  end
  def login_controller_as(role=:user)
    user = Factory(role)
    #user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the confirmable module
    sign_in user
  end
end
