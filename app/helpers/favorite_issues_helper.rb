module FavoriteIssuesHelper
  # Возвращает URL для добавления задачи в избранное
  # Может принимать как одну задачу, так и массив задач
  def favorite_issue_path(issue)
    if issue.is_a?(Array)
      favorite_issues_path(issue_id: issue.map(&:id))
    elsif issue.respond_to?(:id)
      favorite_issues_path(issue_id: issue.id)
    else
      favorite_issues_path(issue_id: issue)
    end
  end
  
  # Возвращает URL для удаления задачи из избранного
  # Может принимать как одну задачу, так и массив задач
  def unfavorite_issue_path(issue)
    favorite_issue_path(issue)
  end
  
  # Возвращает кнопку для избранной/неизбранной задачи (аналог watcher_link)
  def favorite_link(issue, user = User.current)
    return '' unless user && user.logged? && issue.present?

    is_favorite = issue.favorite?(user)
    css_class = is_favorite ? 'icon icon-favorite' : 'icon icon-favorite-off'

    url = favorite_issues_path(issue_id: issue.id)
    method = is_favorite ? :delete : :post

    label = l(:label_favorite)
    title = is_favorite ? l(:button_remove_favorite) : l(:button_add_favorite)

    link_to label, url,
      remote: true,
      method: method,
      class: css_class,
      title: title,
      data: { issue_id: issue.id, method: method.to_s }
  end

  # Компактная иконка для таблиц (без текста)
  def favorite_icon(issue, user = User.current, options = {})
    return '' unless user && user.logged? && issue.present?

    is_favorite = issue.favorite?(user)
    css_class = is_favorite ? 'icon-only icon-favorite' : 'icon-only icon-favorite-off'

    url = favorite_issues_path(issue_id: issue.id)
    method = is_favorite ? :delete : :post

    title = is_favorite ? l(:button_remove_favorite) : l(:button_add_favorite)

    link_to '', url,
      remote: true,
      method: method,
      class: css_class,
      title: title,
      data: { issue_id: issue.id, method: method.to_s }
  end
end