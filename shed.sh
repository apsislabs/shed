#!/bin/bash

echo "=> Installing global rake tasks for shed."

(which rake > /dev/null) || {
  echo '=> Exiting: rake not installed. Run gem install rake to continue.';
  exit 1;
}

echo "=>\tcreating directories..."
mkdir -p $HOME/.shed
mkdir -p $HOME/.rake

echo "=>\tcreating files..."
touch $HOME/.shed/shedrc.example
touch $HOME/.rake/shed.rake

cat <<EOF > $HOME/.shed/shedrc.example
# place relative paths to executable scripts into each
# array below. Scripts should be idempotent.

bootstrap: []
post_checkout: []
server_restart: []
server_start: []
server_stop: []
test: []
dependencies: []
EOF

cat <<EOF > $HOME/.rake/shed.rake
require 'yaml'

namespace :shed do
  desc "Initialize a project for use with shed"
  task :init do
    puts "Creating .shedrc..."
    if File.exist?('$HOME/.shed/shedrc.example')
      if !File.exist?('.shedrc')
        cp '$HOME/.shed/shedrc.example', '.shedrc'
      else
        puts ".shedrc already exists"
      end
    else
      puts ".shedrc template is missing, creating blank .shedrc"
      touch ".shedrc"
    end
  end

  desc "Run the bootstrap commands from .shedrc"
  task :bootstrap do
    Rake::Task["shed:run_tools"].invoke("bootstrap")
  end

  desc "Run the post_checkout commands from .shedrc"
  task :post_checkout do
    Rake::Task["shed:run_tools"].invoke("post_checkout")
  end

  desc "Run the test commands from .shedrc"
  task :test do
    Rake::Task["shed:run_tools"].invoke("test")
  end

  desc "Run the dependencies commands from .shedrc"
  task :dependencies do
    Rake::Task["shed:run_tools"].invoke("dependencies")
  end

  namespace :server do
    desc "Run the server_restart commands from .shedrc"
    task :restart do
      Rake::Task["shed:run_tools"].invoke("server_restart")
    end

    desc "Run the server_start commands from .shedrc"
    task :start do
      Rake::Task["shed:run_tools"].invoke("server_start")
    end

    desc "Run the server_stop commands from .shedrc"
    task :stop do
      Rake::Task["shed:run_tools"].invoke("server_stop")
    end
  end

  namespace :self do
    desc "Update global shed tasks to latest version"
    task :update do
      puts "Updating shed to latest version...\n\n"
      sh "curl -fsSL https://raw.githubusercontent.com/apsislabs/shed/master/shed.sh | sh"
      puts "\n\nDone"
    end

    desc "Uninstall shed globally."
    task :uninstall do
      puts "Uninstalling shed."
      sh "rm -rf $HOME/.shed"
      sh "rm $HOME/.rake/shed.rake"
    end
  end

  desc "Run command based on .shedrc"
  task :run_tools, [:entry] do |t, args|
    unless File.exist?('.shedrc')
      puts "Shed is not initialized for this directory. Do you need to run init?"
      return false
    end

    base_dir = File.expand_path(File.dirname('.shedrc'))
    config = YAML::load(File.open('.shedrc'))

    if config[args[:entry]]
      entry = [config[args[:entry]]].flatten(1)

      entry.each do |fp|
        sh "sh #{base_dir}/#{fp}"
      end
    else
      puts "Entry does not exist for #{args[:entry]}"
    end
  end
end

EOF

echo "=> Done."
