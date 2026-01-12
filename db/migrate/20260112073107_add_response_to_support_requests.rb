class AddResponseToSupportRequests < ActiveRecord::Migration[8.0]
  def change
    add_column :support_requests, :response, :text
  end
end
