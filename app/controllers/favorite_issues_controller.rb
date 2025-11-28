class FavoriteIssuesController < ApplicationController
  before_action :require_login
  before_action :find_issue, only: [:create, :destroy]
  before_action :authorize_global
  
  helper :queries
  helper :issues
  include QueriesHelper
  include IssuesHelper
  include SortHelper
  
  # Переопределяем метод base_scope для IssueQuery, чтобы он возвращал только избранные задачи
  def base_scope_with_favorites
    favorite_issue_ids = FavoriteIssue.where(user_id: User.current.id).pluck(:issue_id)
    Issue.visible.joins(:status, :project).where(id: favorite_issue_ids).where(@query.statement)
  end
  
  def index
    # Initialize a query object for the view
    retrieve_query(IssueQuery, false, :defaults => {:name => l(:label_favorite_issues)})
    @query ||= IssueQuery.new(:name => l(:label_favorite_issues))
    @query.project = nil # global query
    @query.build_from_params(params)
    
    # Настройка сортировки по умолчанию
    sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
    sort_update(@query.sortable_columns)
    
    # Устанавливаем параметры группировки
     @query.group_by = params[:group_by] if params[:group_by].present?
     @query.column_names = params[:c] if params[:c].present?
    
    # Получаем избранные задачи
    favorite_issue_ids = FavoriteIssue.where(user_id: User.current.id).pluck(:issue_id)
    
    # Переопределяем методы для текущего запроса
      @query.instance_eval do
        # Переопределяем base_scope для использования в других методах
        define_singleton_method :base_scope do
          Issue.visible.joins(:status, :project).where(id: favorite_issue_ids).where(statement)
        end
        
        # Переопределяем issue_count для правильного подсчета
        define_singleton_method :issue_count do
          base_scope.count
        rescue ::ActiveRecord::StatementInvalid => e
          raise StatementInvalid.new(e.message)
        end
        
        # Переопределяем issues для получения списка задач
        define_singleton_method :issues do |options={}|
          order_option = [group_by_sort_order, (options[:order] || sort_clause)].flatten.reject(&:blank?)
          # The default order of IssueQuery is issues.id DESC(by IssueQuery#default_sort_criteria)
          unless ["#{Issue.table_name}.id ASC", "#{Issue.table_name}.id DESC"].any?{|i| order_option.include?(i)}
            order_option << "#{Issue.table_name}.id DESC"
          end

          scope = base_scope.
            preload(:priority).
            includes(([:status, :project] + (options[:include] || [])).uniq)

          scope = scope.preload([:tracker, :author, :assigned_to, :fixed_version, :category, :priority])

          if options[:order]
            scope = scope.reorder order_option
          elsif !options[:ids]
            scope = scope.reorder order_option
          end

          if options[:limit]
            scope = scope.limit(options[:limit])
          end
          if options[:offset]
            scope = scope.offset(options[:offset])
          end
          scope
        end
      end
    
    # Получаем общее количество задач
     @issue_count = @query.issue_count
     @issue_pages = Paginator.new @issue_count, per_page_option, params[:page]
     @offset = @issue_pages.offset
     
     # Получаем задачи с учетом фильтров и сортировки
     @issues = @query.issues(:limit => per_page_option, :offset => @offset)
    
    # Настройка группировки
    @query.group_by ||= params[:group_by]
    @query.column_names = params[:c] || @query.column_names
    
    # Настройка дополнительных параметров для корректной работы шаблона
    if @query.grouped?
      # Переопределяем метод result_count_by_group для правильной группировки
      @query.instance_eval do
        define_singleton_method :base_group_scope do
          base_scope.joins(joins_for_order_statement(group_by_statement)).group(group_by_statement)
        end
        
        define_singleton_method :grouped_query do |&block|
          r = nil
          if grouped?
            r = yield base_group_scope
            c = group_by_column
            if c.is_a?(QueryCustomFieldColumn)
              r = r.keys.inject({}) {|h, k| h[c.custom_field.cast_value(k)] = r[k]; h}
            end
          end
          r
        rescue ::ActiveRecord::StatementInvalid => e
          raise StatementInvalid.new(e.message)
        end
        
        define_singleton_method :result_count_by_group do
          grouped_query do |scope|
            scope.count
          end
        end
      end
      
      @issue_count_by_group = @query.result_count_by_group
    end
    
    respond_to do |format|
      format.html { render :index, layout: !request.xhr? }
      format.api
      format.atom { render :index, layout: false }
      format.csv  { send_data(query_to_csv(@issues, @query), type: 'text/csv; header=present', filename: 'favorites.csv') }
      format.pdf  { send_file_headers! type: 'application/pdf', filename: 'favorites.pdf' }
    end
  end
  
  def create
    success = true
    errors = []
    
    if @issues.present?
      # Обработка массива задач
      @issues.each do |issue|
        favorite_issue = FavoriteIssue.new(user: User.current, issue: issue)
        unless favorite_issue.save
          success = false
          errors << favorite_issue.errors.full_messages
        end
      end
      # Используем первую задачу для отображения в шаблоне
      @favorite_issue = FavoriteIssue.find_by(user_id: User.current.id, issue_id: @issue.id) if @issue
    else
      # Обработка одной задачи
      @favorite_issue = FavoriteIssue.new(user: User.current, issue: @issue)
      success = @favorite_issue.save
      errors = @favorite_issue.errors.full_messages unless success
    end
    
    respond_to do |format|
      if success
        format.html { redirect_back_or_default issue_path(@issue), notice: l(:notice_successful_create) }
        format.js
        format.api { render_api_ok }
      else
        format.html { redirect_back_or_default issue_path(@issue), error: l(:error_favorite_issue_create) }
        format.js { render :error }
        format.api { render_validation_errors(@favorite_issue) }
      end
    end
  end
  
  def destroy
    success = true
    errors = []
    
    if @issues.present?
      # Обработка массива задач
      @issues.each do |issue|
        favorite_issue = FavoriteIssue.find_by(user_id: User.current.id, issue_id: issue.id)
        if favorite_issue
          unless favorite_issue.destroy
            success = false
            errors << l(:error_favorite_issue_delete)
          end
        end
      end
      # Используем первую задачу для отображения в шаблоне
      @favorite_issue = FavoriteIssue.find_by(user_id: User.current.id, issue_id: @issue.id) if @issue
    else
      # Обработка одной задачи
      @favorite_issue = FavoriteIssue.find_by(user_id: User.current.id, issue_id: @issue.id)
      if @favorite_issue
        success = @favorite_issue.destroy
        errors << l(:error_favorite_issue_delete) unless success
      else
        success = false
        errors << l(:error_favorite_issue_delete)
      end
    end
    
    respond_to do |format|
      if success
        format.html { redirect_back_or_default issue_path(@issue), notice: l(:notice_successful_delete) }
        format.js
        format.api { render_api_ok }
      else
        format.html { redirect_back_or_default issue_path(@issue), error: errors.join(", ") }
        format.js { render :error }
        format.api { render_api_error errors.join(", ") }
      end
    end
  end
  
  private
  
  def find_issue
    if params[:issue_id].is_a?(Array)
      @issues = Issue.where(id: params[:issue_id]).to_a
      @issue = @issues.first if @issues.any?
    elsif params[:issue_id].present?
      @issue = Issue.find(params[:issue_id])
      @issues = [@issue]
    else
      render_404
      return
    end
    
    # Проверяем доступность задач для текущего пользователя
    if @issues.present?
      @issues = @issues.select { |issue| issue.visible? }
      @issue = @issues.first if @issues.any?
    end
    
    render_404 if @issues.empty?
  rescue ActiveRecord::RecordNotFound
    render_404
  end
end