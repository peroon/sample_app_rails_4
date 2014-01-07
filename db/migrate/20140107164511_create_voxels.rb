class CreateVoxels < ActiveRecord::Migration
  def change
    create_table :voxels do |t|
      t.integer :user_id
      t.string :title
      t.text :voxeljson

      t.timestamps
    end
  end
end
