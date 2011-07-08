class ::Refinery::Admin::SitesController < Admin::BaseController
  skip_filter :load_site

  #Not namespacing the site model because the purpose is to enable an app-specific site model that 
  #might not be exclusive to refinery.
  crudify :site,
    :title_attribute => :name,
    :order => "name ASC",
    #:redirect_to_url => :redirect_to_where?,
    :xhr_paging => true
      
end

