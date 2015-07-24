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

require "managesieve"
require "gettext"

module SieveVacationManager
  module Helper
    include GetText

    SIEVE_SCRIPT_NAME = "sieve-vacation-manager"

    def current_user
      @_current_user ||= session[:current_user_id] &&
        User.find(session[:current_user_id])
    end

    def format_toggle_switch(settings, name, expired)
      checked = "checked" if !expired && settings.send(name)
      enabled_i18n = h _("Enabled")
      disabled_i18n = h _("Disabled")
      %Q(<input data-toggle="toggle"
          name="toggle-#{name}"
          data-on="#{enabled_i18n}"
          data-off="#{disabled_i18n}"
          type="checkbox" value="#{name}-on"
          #{checked}>)
    end

    def reply_option_selected?(settings, value)
      selected = settings.reply_options
      if selected == value
        true
      elsif not selected or selected.empty?
        value == "only-internal"
      else
        false
      end
    end

    def format_toggle_reply_options(settings, value)
      checked = %Q(checked="checked") if reply_option_selected?(settings, value)
      %Q(<label>
         <input type="radio" name="reply-options"
          id="reply-options-#{value}" value="#{value}"
          #{checked}>#{format_reply_options(value)}</input>
        </label><br>)
    end

    def format_datetime(time)
      time.strftime("%Y/%m/%d") if time
    end

    def expired?(time)
      Time.zone.now > time
    end

    def format_end_of_absence_time(time)
      return if time.empty?

      Time.zone.parse(time) + 1.day - 1.second
    end

    def format_locale
      lang = env["rack.locale"]
      if lang
        lang.split("-").first
      else
        "en"
      end
    end

    def format_reply_options(option)
      messages = message_config[format_locale]
      if option == "only-internal"
        h("#{messages["reply-to-internal-mail"]}")
      elsif option == "only-external"
        h("#{messages["reply-to-external-mail"]}")
      elsif option == "all"
        h("#{messages["reply-to-all-mail"]}")
      end
    end

    def format_domains(domains)
      list = "<ul>"
      domains ||= []
      domains.each do |domain|
        list << "<li>#{h(domain)}</li>";
      end
      list << "</ul>"
    end

    def send_sieve_script(script, server_config, user, password)
      managesieve = ManageSieve.new(user:     user,
                                    password: password,
                                    host:     server_config["host"],
                                    auth:     server_config["auth"],
                                    port:     server_config["port"],
                                    tls:      server_config["tls"])
      if (script.empty?)
        managesieve.set_active("")
      else
        managesieve.put_script(SIEVE_SCRIPT_NAME, script)
        managesieve.set_active(SIEVE_SCRIPT_NAME)
      end
      managesieve.logout
    end
  end
end
