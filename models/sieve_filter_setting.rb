require 'validates_email_format_of'

class SieveFilterSetting < ActiveRecord::Base
  belongs_to :user

  validates :begin_at, presence: true
  validates :end_at, presence: true
  validate :begin_at, :excess_deadline, on: :registration
  validate :end_at, :already_expired, on: :registration
  validates :forward, allow_blank: true, presence: true
  validates :forwarding_address, email_format: { message: :malformed_address }, if: :forwarding_enabled?
  validate :forwarding_address, :address_not_mine, on: :registration
  validates :vacation, allow_blank: true, presence: true
  validates :reply_options, presence: true, if: :vacation_enabled?
  validates :subject, length: {minimum: 1, maximum: 255}, if: :vacation_enabled?
  validates :body, length: {maximum: 1024}, if: :vacation_enabled?

  private
  def forwarding_enabled?
    self.forward == true
  end

  def vacation_enabled?
    self.vacation == true
  end

  def already_expired
    if Time.now > self.end_at
      errors.add(:end_at, I18n.t("activerecord.errors.models.sieve_filter_setting.attributes.expired"))
    end
  end

  def address_not_mine
    if self.forwarding_address == self.user.email
      errors.add(:forwarding_address, I18n.t("activerecord.errors.models.sieve_filter_setting.attributes.not_mine"))
    end
  end

  def excess_deadline
    if self.begin_at > self.end_at
      errors.add(:begin_at, I18n.t("activerecord.errors.models.sieve_filter_setting.attributes.begin_at"))
    end
  end

  def format_time_range_script(inner_script)
    begin_zone = begin_at.strftime("%z")
    end_zone = end_at.strftime("%z")
    begin_time = %Q(:zone "#{begin_zone}" "iso8601" "#{begin_at.iso8601}")
    end_time = %Q(:zone "#{end_zone}" "iso8601" "#{end_at.iso8601}")
    script = <<-EOS
if allof (currentdate :value "ge" #{begin_time},
          currentdate :value "le" #{end_time}) {
#{inner_script}}
    EOS
  end

  def escaped_forwarding_address
    self.class.escape_sieve_string(forwarding_address)
  end

  def escaped_subject
    self.class.escape_sieve_string(subject)
  end

  def escaped_body
    self.class.escape_sieve_string(body)
  end

  def format_domains(domains)
    domains.collect do |domain|
      escaped_domain = self.class.escape_sieve_string(domain)
      %Q(address :domain ["from"] ["#{escaped_domain}"])
    end.join(",\n           ")
  end

  def format_vacation_conditions(domains)
    case reply_options
    when "all"
      "true"
    when "only-internal"
      if domains.empty?
        "false"
      else
        "anyof(#{format_domains(domains)})"
      end
    when "only-external"
      if domains.empty?
        "true"
      else
        "not anyof(#{format_domains(domains)})"
      end
    else
      "false"
    end
  end

  def format_vacation_script(params)
    params[:domains] ||= []
    params[:fixed_phrase] ||= ""

    return "" if not vacation
    return "" if reply_options == "only-internal" and params[:domains].empty?

    escaped_address = self.class.escape_sieve_string(params[:my_address])
    escaped_fixed_phrase = self.class.escape_sieve_string(params[:fixed_phrase])
    escaped_fixed_phrase += "\n" unless escaped_fixed_phrase.empty?
    conditions = format_vacation_conditions(params[:domains])
    script = %Q(require "vacation";\n);
    vacation_script = <<-EOS
  if #{conditions} {
    vacation
      :days 1
      :subject "#{escaped_subject}"
      :addresses ["#{escaped_address}"]
"#{escaped_fixed_phrase}#{escaped_body}";
  }
    EOS
    script += format_time_range_script(vacation_script);
  end

  def format_forward_script
    return "" if not forward

    forward_script = %Q(  redirect "#{escaped_forwarding_address}";\n)
    format_time_range_script(forward_script)
  end

  public
  def self.escape_sieve_string(string)
    string.gsub(/(\"|\\)/, '\\\\\1')
  end

  def to_sieve_script(params)
    vacation_script = format_vacation_script(params)
    forward_script = format_forward_script
    return "" if vacation_script.empty? and forward_script.empty?

    [
      %Q(require "date";\n),
      %Q(require "relational";\n),
      vacation_script,
      forward_script,
      "keep;\n"
    ].join("")
  end
end
