class AddCorrectAnswerToChallenges < ActiveRecord::Migration[7.1]
  def change
    add_column :challenges, :correct_answer, :integer

    add_check_constraint :challenges,
                         "correct_answer BETWEEN 1 AND 4",
                         name: "challenges_correct_answer_range"
  end
end
