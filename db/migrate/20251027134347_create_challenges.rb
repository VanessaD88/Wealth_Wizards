class CreateChallenges < ActiveRecord::Migration[7.1]
  def change
    create_table :challenges do |t|
      t.string :title
      t.references :level, null: false, foreign_key: true
      t.string :category
      t.integer :difficulty
      t.text :challenge_prompt
      t.text :description
      t.integer :choice
      t.decimal :balance_impact
      t.decimal :decision_score_impact
      t.text :feedback
      t.boolean :completion_status, null: false, default: ""

      t.timestamps
    end
  end
end
