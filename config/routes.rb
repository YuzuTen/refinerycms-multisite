::Refinery::Application.routes.draw do
  scope(:module=> 'refinery') do
    scope(:module => 'admin', :path => 'refinery', :as => 'refinery_admin') do
      resources :sites do
        resources :hostnames
      end
    end
  end
end
