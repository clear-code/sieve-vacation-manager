require 'validates_email_format_of'

class User < ActiveRecord::Base
  has_many :sieve_filter_settings
  validates :email, presence: true, uniqueness: true, email_format: { message: :malformed_address }

  def valid_email?
    # Validates only the format of the email.
    # Can't use valid? for this purpose because uniqueness is true.
    ValidatesEmailFormatOf::validate_email_format(self.email).nil?
  end

  def authenticate(password, server_config)
    return nil unless valid_email?
    begin
      managesieve = ManageSieve.new(user:     self.email,
                                    password: password,
                                    host:     server_config["host"],
                                    auth:     server_config["auth"],
                                    port:     server_config["port"],
                                    tls:      server_config["tls"])
      true
    rescue SieveAuthError, SieveCommandError => e
      nil
    end
  end
end
