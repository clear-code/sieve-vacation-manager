class AddReplyToColumnIntoSieveFilterSettings < ActiveRecord::Migration
  def change
    add_column :sieve_filter_settings, :reply_options, :string
  end
end
