class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.text :comment
      t.float :m_z_start
      t.float :m_z_end
      t.float :m_z_interval

      t.timestamps
    end
  end
end
