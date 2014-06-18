class AddLabelOrderToLabel < ActiveRecord::Migration
  def change
    add_column :labels, :label_order, :integer
  end
end
