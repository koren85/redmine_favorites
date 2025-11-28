# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get 'favorite_issues', to: 'favorite_issues#index', as: :favorite_issues
post 'favorite_issues', to: 'favorite_issues#create'
delete 'favorite_issues', to: 'favorite_issues#destroy'