# Copyright (C) 2015  ClearCode Inc.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
