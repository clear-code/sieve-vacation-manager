class AddTimeStampSieveFilterSettings < ActiveRecord::Migration
  def change
    change_table :sieve_filter_settings do |t|
      t.timestamps
    end
  end
end
