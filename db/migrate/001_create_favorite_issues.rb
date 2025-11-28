class CreateFavoriteIssues < ActiveRecord::Migration[5.2]
  def change
    create_table :favorite_issues do |t|
      t.references :user, null: false, index: true
      t.references :issue, null: false, index: true
      t.timestamps
    end
    
    add_index :favorite_issues, [:user_id, :issue_id], unique: true
  end
end