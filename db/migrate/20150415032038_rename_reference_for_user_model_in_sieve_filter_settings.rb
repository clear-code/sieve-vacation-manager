class RenameReferenceForUserModelInSieveFilterSettings < ActiveRecord::Migration
  def change
    remove_reference :sieve_filter_settings, :users, index: true
    add_reference :sieve_filter_settings, :user, index: true
  end
end
