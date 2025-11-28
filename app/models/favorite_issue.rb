class FavoriteIssue < ActiveRecord::Base
  belongs_to :user
  belongs_to :issue
  
  validates :user_id, presence: true
  validates :issue_id, presence: true
  validates :user_id, uniqueness: { scope: :issue_id, message: :already_favorite }
  
  scope :visible, lambda { |user = User.current|
    joins(:issue => :project)
    .where(Issue.visible_condition(user))
  }
  
  def self.favorite?(issue, user = User.current)
    where(issue_id: issue.id, user_id: user.id).exists?
  end
end