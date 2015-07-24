class ChangeColumnNameSieveFilterSettings < ActiveRecord::Migration
  def change
    rename_column :sieve_filter_settings, :from, :begin
    rename_column :sieve_filter_settings, :to, :end
  end
end
