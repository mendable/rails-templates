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
}

 
# Remove unused files
run "rm README"
run "rm public/index.html"
run "rm public/favicon.ico"
run "rm public/robots.txt"


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
        <p style="color: green"><%= flash[:notice] %></p>
        <p style="color: red"><%= flash[:error] %></p>
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


# add to Git
git :init
git :add => "."
git :submodule => "init"
git :commit => "-am 'Start of project'"
