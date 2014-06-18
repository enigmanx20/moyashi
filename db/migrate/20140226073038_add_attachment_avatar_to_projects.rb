class AddAttachmentAvatarToProjects < ActiveRecord::Migration
  def self.up
    change_table :projects do |t|
      t.attachment :avatar
    end
  end

  def self.down
    drop_attached_file :projects, :avatar
  end
end
