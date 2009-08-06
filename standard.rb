# Setup some variables
current_app_name = File.basename(File.expand_path(root))


# Gems
gem 'mysql'
gem 'thoughtbot-shoulda', :lib => 'shoulda', :source => 'http://gems.github.com'
gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'

rake("gems:install", :sudo => true)


# Ignore auto-generated files
file '.gitignore',
%q{log/*.log
log/*.pid
db/*.db
db/*.sqlite3
db/schema.rb
tmp/**/*
.DS_Store
doc/api
doc/app
config/database.yml
public/javascripts/all.js
coverage
coverage.data
*.swp
}

 
# Remove unused files
run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"
run "rm public/images/rails.png"


# add to Git (before plugin definitions, so submodule works)
git :init
git :add => "."


# Vendor/plugins.
plugin 'paperclip', :git => 'git://github.com/thoughtbot/paperclip.git', :submodule => true if yes?("Use PaperClip in this project? (y/n)")
plugin 'attachment_fu', :git => 'git://github.com/technoweenie/attachment_fu.git', :submodule => true if yes?("Use Attachment_fu in this project? (y/n)")
plugin 'correct-format', :git => 'git://github.com/mendable/correct-format.git', :submodule => true if yes?("Use correct-format in this project? (y/n)")



# Configure MySQL database
file 'config/database.yml', <<-END
development:
  adapter: mysql
  encoding: utf8
  reconnect: false
  database: #{current_app_name}_development
  pool: 5
  username: root
  password:
  socket: /var/run/mysqld/mysqld.sock
test:
  adapter: mysql
  encoding: utf8
  reconnect: false
  database: #{current_app_name}_test
  pool: 5
  username: root
  password:
  socket: /var/run/mysqld/mysqld.sock
production:
  adapter: mysql
  encoding: utf8
  reconnect: false
  database: #{current_app_name}_production
  pool: 5
  username: root
  password:
  socket: /var/run/mysqld/mysqld.sock
END
run "cp config/database.yml config/database.yml.example"


# Stylesheets
file 'public/stylesheets/layout.css', <<-END
body {
  margin: 0;
  margin-bottom: 25px;
  padding: 0;
  background-color: #f0f0f0;
  font-family: "Arial";
  font-size: 14px;
  color: #333;
}

h1 {
  font-size: 28px;
  color: #000;
}

h2 {
  font-size: 18px;
  font-weight: normal;
  color: #000;
  margin-top: 25px;
}

a  {color: #03c}
a:hover {
  background-color: #03c;
  color: white;
  text-decoration: none;
}

#page {
  background-color: #f0f0f0;
  width: 950px;
  margin: 0;
  margin-left: auto;
  margin-right: auto;
}

#content {
  float: left;
  background-color: white;
  border: 1px solid #aaa;
  border-top: none;
  padding: 25px;
  width: 700px;
}

#sidebar {
  float: right;
  width: 175px;
}

#footer {
  clear: both;
}

#sidebar ul {
  margin-left: 0;
  padding-left: 0;
}
#sidebar ul h3 {
  margin-top: 25px;
  font-size: 18px;
  padding-bottom: 10px;
  border-bottom: 1px solid #ccc;
}
#sidebar li {
  list-style-type: none;
}
#sidebar ul.links li {
  margin-bottom: 5px;
}

img {border:0px;}
END


file 'public/stylesheets/error.css', <<-END
.fieldWithErrors {
  padding: 2px;
  background-color: red;
  display: table;
}

#errorExplanation {
  width: 400px;
  border: 2px solid red;
  padding: 7px;
  padding-bottom: 12px;
  margin-bottom: 20px;
  background-color: #f0f0f0;
}

#errorExplanation h2 {
  text-align: left;
  font-weight: bold;
  padding: 5px 5px 5px 15px;
  font-size: 12px;
  margin: -7px;
  background-color: #c00;
  color: #fff;
}

#errorExplanation p {
  color: #333;
  margin-bottom: 0;
  padding: 5px;
}

#errorExplanation ul li {
  font-size: 12px;
  list-style: square;
}
END


# Default application template
file 'app/views/layouts/application.html.erb', <<-END
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
        "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
  <head>
    <meta http-equiv="Content-type" content="text/html; charset=utf-8" />
    <title>#{current_app_name}</title>
    <%= stylesheet_link_tag 'layout' %>
    <%= stylesheet_link_tag 'error' %>
  </head>
  <body>
    <div id="page">
      <div id="sidebar">
        <ul id="sidebar-items">
          <li>
            <h3>#{current_app_name}</h3>
            <ul class="links">
              <li><%= link_to 'Home', root_path %></li>
            </ul>
          </li>
        </ul>
      </div>

      <div id="content">
        <% [{:flash => :notice, :color => :green}, {:flash => :error, :color => :red}].each do |possible_flash| %>
          <% if flash[possible_flash[:flash]] %>
            <p style="color: <%= possible_flash[:color] %>"><%= flash[possible_flash[:flash]] %></p>
          <% end %>
        <% end %>
        <%= yield %>
        <div id="footer">&nbsp;</div>
      </div>
    </div>
  </body>
</html>
END


# Default routes
file 'config/routes.rb', <<-END
ActionController::Routing::Routes.draw do |map|
  map.root :controller => "site", :action => "index"
end
END

generate("controller", "site", "index")
run "rm test/unit/helpers/site_helper_test.rb"
run "rm app/helpers/site_helper.rb"

file 'lib/tasks/shoulda.rake', <<-END
begin require 'shoulda/tasks' rescue LoadError end
END

file 'test/test_helper.rb', <<-END
ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'shoulda'

class ActiveSupport::TestCase
  
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  #fixtures :all

end
END


file 'lib/tasks/rcov.rake', <<-END
def run_coverage(files)
  rm_f "coverage"
  rm_f "coverage.data"
 
  # turn the files we want to run into a  string
  if files.length == 0
    puts "No files were specified for testing"
    return
  end
 
  files = files.join(" ")
 
  if PLATFORM =~ /darwin/
    exclude = '--exclude "gems/*"'
  else
    exclude = '--exclude "rubygems/*"'
  end
 
  rcov = "rcov --rails -Ilib:test --sort coverage --text-report \#{exclude} --no-validator-links --aggregate coverage.data"
  cmd = "\#{rcov} \#{files}"
  sh cmd
end
 
namespace :test do
 
  desc "Measures unit, functional, and integration test coverage"
  task :coverage do
    run_coverage Dir["test/**/*.rb"]
  end
 
  namespace :coverage do
    desc "Runs coverage on unit tests"
    task :units do
      run_coverage Dir["test/unit/**/*.rb"]
    end
    desc "Runs coverage on functional tests"
    task :functionals do
      run_coverage Dir["test/functional/**/*.rb"]
    end
    desc "Runs coverage on integration tests"
    task :integration do
      run_coverage Dir["test/integration/**/*.rb"]
    end
  end
end
END


file 'lib/tasks/metric_fu.rake', <<-END
require 'metric_fu'

# Fix NaN issue: http://thestewscope.wordpress.com/2009/07/09/ruby-code-quality-and-metric_fu/
module MetricFu
  class Generator
    def round_to_tenths(decimal)
      decimal=0.0 if decimal.to_s.eql?('NaN')
      (decimal.to_i * 10).round / 10.0
    end
  end
end


MetricFu::Configuration.run do |config|
  #define which metrics you want to use
  config.metrics  = [:churn, :saikuro, :stats, :flog, :flay, :reek, :roodi, :rcov]
  config.graphs   = [:flog, :flay, :reek, :roodi, :rcov]
  config.flay     = { :dirs_to_flay => ['app', 'lib']  }
  config.flog     = { :dirs_to_flog => ['app', 'lib']  }
  config.reek     = { :dirs_to_reek => ['app', 'lib']  }
  config.roodi    = { :dirs_to_roodi => ['app', 'lib'] }
  config.saikuro  = { :output_directory => 'scratch_directory/saikuro',
                      :input_directory => ['app', 'lib'],
                      :cyclo => "",
                      :filter_cyclo => "0",
                      :warn_cyclo => "5",
                      :error_cyclo => "7",
                      :formater => "text"} #this needs to be set to "text"
  config.churn    = { :start_date => "1 year ago", :minimum_churn_count => 10}
  config.rcov     = { :test_files => ['test/**/*_test.rb',
                                      'spec/**/*_spec.rb'],
                      :rcov_opts => ["--sort coverage",
                                     "--no-html",
                                     "--text-coverage",
                                     "--no-color",
                                     "--profile",
                                     "--rails",
                                     "--exclude /gems/,/Library/,spec",
                                     "-ltest"]}
end
END


file 'config/environments/test.rb', <<-END
# Settings specified here will take precedence over those in config/environment.rb

# The test environment is used exclusively to run your application's
# test suite.  You never need to work with it otherwise.  Remember that
# your test database is "scratch space" for the test suite and is wiped
# and recreated between test runs.  Don't rely on the data there!
config.cache_classes = true

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_controller.perform_caching             = false
config.action_view.cache_template_loading            = true

# Disable request forgery protection in test environment
config.action_controller.allow_forgery_protection    = false

# Tell Action Mailer not to deliver emails to the real world.
# The :test delivery method accumulates sent emails in the
# ActionMailer::Base.deliveries array.
config.action_mailer.delivery_method = :test

# Use SQL instead of Active Record's schema dumper when creating the test database.
# This is necessary if your schema can't be completely dumped by the schema dumper,
# like if you have constraints or database-specific column types
# config.active_record.schema_format = :sql

config.gem 'flay' #, :version => '2.1.0'
config.gem 'flog'
config.gem 'reek'
config.gem 'roodi'
config.gem 'gruff'
config.gem 'jscruggs-metric_fu', :lib => 'metric_fu', :source => 'http://gems.github.com'
END

rake("gems:install RAILS_ENV=test", :sudo => true)

# add to Git
git :init
git :add => "."
git :submodule => "init"
git :commit => "-am 'Start of project'"
