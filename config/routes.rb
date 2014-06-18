Funalyzer::Application.routes.draw do
  # ==================================================
  # = Routing for matlab analysis
  # ==================================================
  get "matlab/pca_lda", as: 'matlab_pca_lda'
  post 'matlab/pca_lda' => 'matlab#run_pca_lda'
  get "matlab/pca_qda", as: 'matlab_pca_qda'
  post 'matlab/pca_qda' => 'matlab#run_pca_qda'
  get "matlab/wilcoxon_rank_sum_test", as: 'matlab_wilcoxon_rank_sum_test'
  post 'matlab/wilcoxon_rank_sum_test' => 'matlab#run_wilcoxon_rank_sum_test'
  get "matlab/welch_ttest", as: 'matlab_welch_ttest'
  post 'matlab/welch_ttest' => 'matlab#run_welch_ttest'



  # ==================================================
  # = Routing for data extracting
  # ==================================================
  get "projects/:id/extract/show" => 'extraction#show', as: 'show_project_extract'
  post "projects/:id/extract/show" => 'extraction#search'
  post "projects/:id/extract" => 'extraction#extract', as: 'extract_project_extract'
  get "projects/:id/extract", to: redirect('projects/:id/extract/show')



  # ==================================================
  # = Routing for project
  # ==================================================
  resources :projects do
    member do
      get   'labels' => 'labels#index'
      patch 'labels' => 'labels#update'
      get   'delete' => 'projects#delete'
      get   'delete_records' => 'projects#show_delete_records'
      post  'delete_records' => 'projects#delete_records'
    end

    resources :records, only: [:show, :new, :create, :edit, :update, :destroy] do
      collection do
        get 'new_next' => 'records#new_next'
      end
    end
  end
  root 'projects#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
