module RedmineFavorites
  module Patches
    module IssueQueryPatch
      def self.included(base)
        base.send(:include, InstanceMethods)
        base.class_eval do
          unloadable
          
          alias_method :initialize_available_filters_without_favorites, :initialize_available_filters
          alias_method :initialize_available_filters, :initialize_available_filters_with_favorites
        end
      end
      
      module InstanceMethods
        def initialize_available_filters_with_favorites
          initialize_available_filters_without_favorites
          
          if User.current.logged?
            add_available_filter "favorite_issue", 
              type: :list,
              name: l(:label_favorite_issues),
              values: [[l(:general_text_yes), "1"], [l(:general_text_no), "0"]]
          end
          @available_filters
        end
        
        def sql_for_favorite_issue_field(field, operator, value)
          db_table = FavoriteIssue.table_name
          db_field = 'issue_id'
          
          sql = case operator
          when "="
            if value.include?("1")
              # Задачи, которые являются избранными для текущего пользователя
              "#{Issue.table_name}.id IN (SELECT #{db_field} FROM #{db_table} WHERE user_id = #{User.current.id})"
            else
              # Задачи, которые не являются избранными для текущего пользователя
              "#{Issue.table_name}.id NOT IN (SELECT #{db_field} FROM #{db_table} WHERE user_id = #{User.current.id})"
            end
          when "!"
            if value.include?("1")
              # Задачи, которые не являются избранными для текущего пользователя
              "#{Issue.table_name}.id NOT IN (SELECT #{db_field} FROM #{db_table} WHERE user_id = #{User.current.id})"
            else
              # Задачи, которые являются избранными для текущего пользователя
              "#{Issue.table_name}.id IN (SELECT #{db_field} FROM #{db_table} WHERE user_id = #{User.current.id})"
            end
          end
          
          sql
        end
      end
    end
  end
end