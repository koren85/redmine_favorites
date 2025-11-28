module RedmineFavorites
  module Patches
    module IssuesControllerPatch
      def self.included(base)
        base.class_eval do
          # Добавляем хелпер для работы с избранными задачами
          helper :favorite_issues
          
          # Добавляем метод для проверки, является ли задача избранной
          before_action :check_issue_is_favorite, only: [:show, :edit]
          
          private
          
          def check_issue_is_favorite
            @issue_is_favorite = @issue.favorite? if @issue.present?
          end
        end
      end
    end
  end
end