class CreateEvents < ActiveRecord::Migration[7.2]
  def change
    create_table :events do |t|
      t.bigint :event_id
      t.bigint :repository_id
      t.bigint :push_id
      t.string :ref
      t.string :head
      t.string :before

      t.timestamps
    end
  end
end
