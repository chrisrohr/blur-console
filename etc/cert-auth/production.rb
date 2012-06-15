BlurAdmin::Application.configure do
  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # Use a different logger for distributed setups
  class LogFormatter < Logger::Formatter
    def call(severity, time, progname, msg)
       "#{severity} [#{time.strftime('%Y-%m-%d %H:%M:%S')}] #{msg}\n"
    end
  end
  config.logger = Logger.new( "#{::Rails.root.to_s}/log/#{ENV['RAILS_ENV]'}.log", 10, 26_214_400 )  
  config.logger.formatter = LogFormatter.new
  config.logger.level = Logger::WARN



  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  
  config.middleware.use Proof::Middleware, Proof::Config.new({
   :ldap_connection => {
      :host=>'localhost', 
      :port=>1636, 
      :base=>'o=Near Infinity Corporation,c=US', 
      :encryption=>:simple_tls, 
      :auth=>{:method=>:simple, :username=>'cn=Directory Manager', :password=>'password'}
    },
   :attributes => [:cn, :employeenumber, :displayname],
   :user_search_base => 'o=Near Infinity Corporation,c=US',
   :group_search_base => 'o=Near Infinity Corporation,c=US',
   :search_base => 'o=Near Infinity Corporation,c=US',
   :attribute_map => {:employeenumber => :employee_number, :displayname => :display_name}
  })
  
end
