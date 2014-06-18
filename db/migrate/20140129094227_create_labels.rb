class CreateLabels < ActiveRecord::Migration
  def change
    create_table :labels do |t|
      t.string :name
      t.string :white_list
      t.boolean :uniqueness

      t.references :project, index: true

      t.timestamps
    end
  end
end
