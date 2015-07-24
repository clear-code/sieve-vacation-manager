class AddSieveFilterSettings < ActiveRecord::Migration
  def change
    create_table :sieve_filter_settings do |t|
      t.string :from, null: false
      t.string :to, null: false
      t.boolean :forward, null: false
      t.string :forwarding_address
      t.boolean :vacation, null: false
      t.string :subject, length: 255
      t.text :body, length: 1024
      t.belongs_to :users, index: true
    end
  end
end
