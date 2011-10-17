ApplicationController.class_eval do
  skip_filter :current_user_session
  
  enable_authorization do |exception|
    if current_user
      if can? :index, :zookeepers
        redirect_to root_url, :alert => "Unauthorized"
      else
        render :text => 'Unauthorized'
      end
    else
      redirect_to login_path, :alert => "Please login"
    end
  end
  
  
  def current_user
    return @current_user if @current_user.present?
    
    if session[:proof].try(:fetch, :employee_number, nil).present?
      
      employee_number = session[:proof][:employee_number].first.to_s

      u = User.where(:username => employee_number).first
      if u.nil?
        rnd_password = ActiveSupport::SecureRandom.base64(20)
        
        u = User.new
        u.username = employee_number
        u.password = rnd_password
        u.password_confirmation = rnd_password
        u.email = "#{employee_number}@nic.com"
        u.save!
      end
      @current_user = u
    end
  end
  
  def current_user_session
    raise "This method should no longer be used"
  end
end