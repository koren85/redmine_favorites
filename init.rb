require 'redmine'

Redmine::Plugin.register :redmine_favorites do
  name 'Redmine Favorites plugin'
  author 'Your Name'
  description 'This plugin allows users to mark issues as favorites'
  version '0.0.1'
  url 'https://github.com/yourusername/redmine_favorites'
  author_url 'https://github.com/yourusername'
  
  # Добавляем пункт в глобальное меню
  menu :top_menu, :favorites,
    { controller: 'favorite_issues', action: 'index' },
    caption: :label_favorites,
    if: Proc.new { User.current.logged? }
  
  # Добавляем разрешения
  permission :view_favorite_issues, { favorite_issues: [:index] }
  permission :manage_favorite_issues, { favorite_issues: [:create, :destroy] }
  
  # Добавляем модуль в проект
  project_module :favorite_issues do
    permission :view_favorite_issues, { favorite_issues: [:index] }
    permission :manage_favorite_issues, { favorite_issues: [:create, :destroy] }
  end
end

# Подключаем хуки
require_dependency 'redmine_favorites/hooks/views_issues_hook'
require_dependency 'redmine_favorites/hooks/views_layouts_hook'

# Патчи для моделей и контроллеров
Rails.configuration.to_prepare do
  require_dependency 'issue'
  require_dependency 'issues_controller'
  require_dependency 'issue_query'
  
  unless Issue.included_modules.include?(RedmineFavorites::Patches::IssuePatch)
    Issue.send(:include, RedmineFavorites::Patches::IssuePatch)
  end
  
  unless IssuesController.included_modules.include?(RedmineFavorites::Patches::IssuesControllerPatch)
    IssuesController.send(:include, RedmineFavorites::Patches::IssuesControllerPatch)
  end
  
  unless IssueQuery.included_modules.include?(RedmineFavorites::Patches::IssueQueryPatch)
    IssueQuery.send(:include, RedmineFavorites::Patches::IssueQueryPatch)
  end
end