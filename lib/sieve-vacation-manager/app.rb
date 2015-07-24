require "sinatra"
require "sinatra/reloader"
require "sinatra/json"
require "sinatra/cookies"
require "rack/flash"
require "net/http"
require "pathname"
require "date"
require "yaml"
require "gettext"
require "net/pop"
require "active_record"
require "active_support/core_ext/time"
require "sieve-vacation-manager/helper"
require "sieve-vacation-manager/version"

Time.zone_default = Time.find_zone!("Tokyo")
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.time_zone_aware_attributes = true

Tilt.register Tilt::ERBTemplate, "html.erb"

def top_dir
  Pathname(__FILE__).dirname.parent.parent
end

def log_dir
  top_dir + "log"
end

def app_config
  YAML.load_file(top_dir + "config/settings.yml")
end

def db_config
  YAML.load_file(top_dir + "config/database.yml")
end

def message_config
  YAML.load_file(top_dir + "config/messages.yml")
end

def fixed_vacation_phrase
  message_config[format_locale]["fixed-phrase"]
end

def app_session_secret
  app_config["session_secret"] || "3b638fd0-bd17-4982-86ea-020719cd2658"
end

module SieveVacationManager
  class App < Sinatra::Base
    include GetText
    bindtextdomain "sieve-vacation-manager"
    enable :sessions
    enable :methodoverride
    set :session_secret, app_session_secret
    set :public_dir, (top_dir + "public").to_s
    set :views, (top_dir + "views").to_s

    configure do
      ActiveRecord::Base.establish_connection(db_config[environment.to_s])
      log_dir.mkpath
      logger = Logger.new("#{log_dir}/#{environment}.log")
      logger.level = Logger::DEBUG unless production?
      set :logger, logger
    end

    configure :development do
      register Sinatra::Reloader
    end
    configure :test do
    end

    before do
      set_locale format_locale
      I18n.locale = format_locale
      timezone = Time.find_zone(cookies[:timezone])
      Time.zone = Time.find_zone!(timezone) if timezone
    end

    helpers do
      include Rack::Utils
      alias_method :h, :escape_html

      include Sinatra::JSON
      include Sinatra::Cookies
      include Helper
      use Rack::Flash, sweep: true
      use Rack::Protection
    end

    get "/" do
      if session[:auth] and User.exists?(session[:current_user_id])
        @setting =
          SieveFilterSetting.find_or_create_by(user_id: current_user.id)
        @expired = expired?(@setting.end_at) if @setting.end_at
        erb :index
      else
        session.clear
        redirect :login
      end
    end

    get "/login" do
      if session[:auth]
        erb :logout
      end
      @notice = message_config[format_locale]["login-page-notice"]
      erb :login
    end

    post "/login" do
      user = User.new(email: params[:email])
      auth_result = user.authenticate(params[:password],
                                      app_config["managesieve-server"])
      if auth_result
        session[:auth] = auth_result
        session[:email] = params[:email]
        session[:password] = params[:password]
        current_user = User.find_or_create_by(email: params[:email])
        session[:current_user_id] = current_user.id
        redirect "/"
      else
        flash[:error] = _("Failed to login. Please check your Email address and password.")
        redirect :login
      end
    end

    delete "/logout" do
      session.clear
      redirect :login
    end

    post "/vacation-config" do
      @setting =
        SieveFilterSetting.find_or_create_by(user_id: current_user.id)
      @setting.begin_at = params["datetime-begin"]
      @setting.end_at = format_end_of_absence_time(params["datetime-end"])
      @setting.forward = params["toggle-forward"] == "forward-on"
      @setting.vacation = params["toggle-vacation"] == "vacation-on"
      @setting.reply_options = params["reply-options"]
      @setting.forwarding_address = params["forwarding-address"]
      @setting.subject = params["mail-subject"]
      @setting.body = params["mail-body"]
      if @setting.valid?(:registration)
        script = @setting.to_sieve_script(my_address: session[:email],
                                          domains: app_config["internal-domains"],
                                          fixed_phrase: fixed_vacation_phrase)
        send_sieve_script(script,
                          app_config["managesieve-server"],
                          session[:email], session[:password])
        @setting.save!(context: :registration)
        @message = _("Successfully saved.")
        erb :confirm
      else
        flash[:error] = _("Failed to save out of office auto-reply settings. ")
        flash[:error] += @setting.errors.full_messages.join(" ")
        erb :index
      end
    end

    not_found do
      @title = "404 not found"
      @message = env["sinatra.error"].message
      status 404
      erb :error
    end

    error ActiveRecord::RecordInvalid do
      flash[:error] = env['sinatra.error'].message
      if session[:auth] and User.exists?(session[:current_user_id])
        erb :index
      else
        session.clear
        redirect :login
      end
    end

    error ActiveRecord::RecordNotFound do
      flash[:error] = env['sinatra.error'].message
      redirect '/'
    end

    error SieveCommandError do
      flash[:error] = h(_("Fail to put sieve filter. Reason: ") +
                        env['sinatra.error'].message)
      redirect '/'
    end

    error NoMethodError do
      if session[:auth] and User.exists?(session[:current_user_id])
        session.clear
        erb :confirm
      else
        redirect '/'
      end
    end
  end
end
