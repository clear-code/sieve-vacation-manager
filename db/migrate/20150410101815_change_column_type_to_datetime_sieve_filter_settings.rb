class ChangeColumnTypeToDatetimeSieveFilterSettings < ActiveRecord::Migration
  def change
    change_column :sieve_filter_settings, :begin, :datetime
    change_column :sieve_filter_settings, :end, :datetime
  end
end
