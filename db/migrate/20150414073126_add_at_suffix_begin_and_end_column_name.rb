class AddAtSuffixBeginAndEndColumnName < ActiveRecord::Migration
  def change
    rename_column :sieve_filter_settings, :begin, :begin_at
    rename_column :sieve_filter_settings, :end, :end_at
  end
end
