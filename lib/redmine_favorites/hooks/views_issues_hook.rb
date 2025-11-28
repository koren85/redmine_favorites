module RedmineFavorites
  module Hooks
    class ViewsIssuesHook < Redmine::Hook::ViewListener
      # Добавляем кнопку избранного в область действий на странице задачи
      def view_issues_show_details_bottom(context)
        issue = context[:issue]
        return '' unless issue

        context[:controller].send(:render_to_string, {
          partial: 'favorite_issues/favorite_button',
          locals: { issue: issue }
        })
      end

      # Добавляем иконку избранного в список задач
      render_on :view_issues_index_table_row, partial: 'favorite_issues/favorite_icon_list'
      
      # Добавляем пункт в контекстное меню задачи
      def view_issues_context_menu_start(context)
        issue_ids = context[:issues].map(&:id)
        user = User.current
        
        # Получаем избранные задачи для текущего пользователя из выбранных задач
        favorite_issue_ids = FavoriteIssue.where(user_id: user.id, issue_id: issue_ids).pluck(:issue_id)
        
        # Определяем, все ли выбранные задачи являются избранными
        all_favorite = favorite_issue_ids.size == issue_ids.size
        
        # Определяем, есть ли среди выбранных задач избранные
        any_favorite = favorite_issue_ids.any?
        
        # Добавляем пункты в контекстное меню
        context[:controller].send(:render_to_string, {
          partial: 'favorite_issues/context_menu',
          locals: {
            issues: context[:issues],
            favorite_issue_ids: favorite_issue_ids,
            all_favorite: all_favorite,
            any_favorite: any_favorite
          }
        })
      end
    end
  end
end