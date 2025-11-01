class CreateEmailLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :email_logs do |t|
      t.string :filename, null: false
      t.string :sender
      t.integer :status, default: 0, null: false
      t.jsonb :extracted_data
      t.text :error_message
      t.datetime :processed_at

      t.timestamps
    end

    add_index :email_logs, :status
    add_index :email_logs, :created_at
    add_index :email_logs, :extracted_data, using: :gin
  end
end
