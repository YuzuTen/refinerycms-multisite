::Refinery::Application.routes.draw do
  scope(:path => 'refinery', :as => 'refinery_admin', :module => 'refinery/admin') do
    resources :sites do
      resources :hostnames
    end
  end
end
