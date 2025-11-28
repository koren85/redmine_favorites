module RedmineFavorites
  module Patches
    module IssuePatch
      def self.included(base)
        base.class_eval do
          has_many :favorite_issues, dependent: :destroy
          has_many :favorited_users, through: :favorite_issues, source: :user
          
          # Проверяет, является ли задача избранной для пользователя
          def favorite?(user = User.current)
            FavoriteIssue.favorite?(self, user)
          end
        end
      end
    end
  end
end