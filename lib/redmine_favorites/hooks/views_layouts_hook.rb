module RedmineFavorites
  module Hooks
    class ViewsLayoutsHook < Redmine::Hook::ViewListener
      # Добавляем JavaScript и CSS в заголовок страницы
      def view_layouts_base_html_head(context = {})
        stylesheet_link_tag('favorites', plugin: 'redmine_favorites') +
        javascript_include_tag('favorites', plugin: 'redmine_favorites')
      end
    end
  end
end