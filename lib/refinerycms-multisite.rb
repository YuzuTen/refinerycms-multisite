require 'refinerycms-base'

module Refinery
  module Sites
    class Engine < Rails::Engine

      class << self
        attr_accessor :root
        def root
          @root ||= Pathname.new(File.expand_path('../../', __FILE__))
        end
      end

      class Engine < ::Rails::Engine
        isolate_namespace ::Refinery

        initializer "init plugin", :after => :set_routes_reloader do |app|
          ::Refinery::Plugin.register do |plugin|
            plugin.pathname = root
            plugin.name = 'refinery_sites'
            plugin.url = app.routes.url_helpers.refinery_admin_sites_path
            plugin.version = Refinerycms::Multisite::VERSION
            plugin.menu_match = /refinery\/sites$/
          end
        end
      end
    end
  end

  module SiteModel
    extend ActiveSupport::Concern

    included do
      belongs_to :page
      attr_accessible :name, :page_id, :stylesheet, :hostnames,
          :hostnames_attributes

      has_many :hostnames, :dependent => :destroy

      accepts_nested_attributes_for :hostnames, :allow_destroy => true
    end

    module ClassMethods
      def find_by_hostname(hostname)
        Site.joins(:hostnames).where(:hostnames=>{:hostname=>hostname}).first ||
          Site.joins(:hostnames).where(:hostnames=>{:hostname=>'*'}).first
      end
    end

    module InstanceMethods
    end
  end

  module SiteModelClassMethods
    #include ActiveRecord

  end
end

module PagesControllerSite
  def home_with_site
    if (@site)
      @page = Page.find(@site.page_id)
      if @page.try(:live?) || (refinery_user? && current_user.authorized_plugins.include?("refinery_pages"))
        # if the admin wants this to be a "placeholder" page which goes to its first child, go to that instead.
        if @page.skip_to_first_child && (first_live_child = @page.children.order('lft ASC').live.first).present?
          redirect_to first_live_child.url
        elsif @page.link_url.present?
          redirect_to @page.link_url and return
        end
      else
        error_404
      end
    else
      home_without_site
    end
  end
end

class ActionController::Base
  # Loading the Current Site
  before_filter :load_site
  protected
  def load_site
    @site = Site.find_by_hostname(request.host)
    return if Refinery::PagesController.include? PagesControllerSite
    # Monkey-Patch the Page-Controller for loading the right root-Page
    Refinery::PagesController.class_eval do
      include PagesControllerSite
      alias_method_chain :home, :site
    end
  end
end
