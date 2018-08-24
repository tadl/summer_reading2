Rails.application.routes.draw do
  resources :weeks
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'
  root 'main#index'
  match 'auth/:provider/callback', to: 'sessions#create', via: [:get, :post]
  match 'auth/failure', to: redirect('/'), via: [:get, :post]
  match 'signout', to: 'sessions#destroy', as: 'signout', via: [:get, :post]
  match 'register_participant', to: 'main#register_participant', as: 'register_participant', via: [:get]
  match 'edit_participant', to: 'main#edit_participant', as: 'edit_participant', via: [:get]
  match 'update_participant', to: 'main#update_participant', as: 'update_participant', via: [:post]
  match 'set_inactive', to: 'main#set_inactive', as: 'set_inactive', via: [:post]
  match 'mark_got_shirt', to: 'main#mark_got_shirt', as: 'mark_got_shirt', via: [:post]
  match 'save_new_participant', to: 'main#save_new_participant', as: 'save_new_participant', via: [:post]
  match 'list_participants', to: 'main#list_participants', as: 'list_participants', via: [:get]
  match 'search_by_name', to: 'main#search_by_name', as: 'search_by_name', via: [:get, :post]
  match 'search_by_card', to: 'main#search_by_card', as: 'search_by_card', via: [:get, :post]
  match 'load_report_interface', to: 'main#load_report_interface', as: 'load_report_interface', via: [:get, :post]
  match 'record_minutes', to: 'main#record_minutes', as: 'record_minutes', via: [:post]
  match 'stats', to: 'main#stats', as: 'stats', via:[:get, :post]
  match 'shirt_stats', to: 'main#shirt_stats', as: 'shirt_stats', via:[:get, :post]
  match 'weekly_reports', to: 'main#weekly_reports', as: 'weekly_reports', via:[:get, :post]
  match 'final_reports', to: 'main#final_reports', as: 'final_reports', via:[:get, :post]
  match 'send_to_school_report', to: 'main#send_to_school_report', as: 'send_to_school_report', via:[:get, :post]
  match 'leaders', to: 'main#leaders', as: 'leaders', via:[:get, :post]
  match 'patron_check_for_participants', to: 'main#patron_check_for_participants', as: 'check_for_participants', via: [:get, :post]
  match 'patron_show_participants', to: 'main#patron_show_participants', as: 'patron_show_participants', via: [:get, :post]
  match 'patron_load_report_interface', to: 'main#patron_load_report_interface', as: 'patron_load_report_interface', via:[:get, :post]
  match 'patron_register_participant', to: 'main#patron_register_participant', as: 'patron_register_participant', via:[:get, :post]
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
