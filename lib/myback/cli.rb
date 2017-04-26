# coding: utf-8

require 'thor'
require 'dotenv'

Dotenv.load('.env.development.local', '.env.local', '.env.development', '.env')

module MyBack
  class CLI < Thor
    def initialize(*args)
      super
      @db = ENV['MYBACK_DB_NAME']
      @backup_dir = ENV['MYBACK_BACKUP_DIR']
      @mysql_args = ENV['MYBACK_MYSQL_ARGS'] || '-u root'
      unless @db && @backup_dir
        puts 'MYBACK_DB_NAME and MYBACK_BACKUP_DIR are required in .env file'
        exit 1
      end
    end

    desc 'backup BACKUP_NAME [--no-time-suffix]', 'make a backup'
    option :time_suffix, type: :boolean, default: true
    def backup(backup)
      do_backup(backup)
    end

    desc 'restore BACKUP_NAME [--no-backup]', 'restore from the backup'
    option :backup, type: :boolean, default: true
    option :time_suffix, type: :boolean, default: false
    def restore(backup)
      do_backup('_backup_before_restore') if options[:backup]
      do_cmd("gzip -dc '#{@backup_dir}/#{backup}' | mysql #{@mysql_args}")
      todo_setup_test_db
    end

    desc 'ls', 'show backup list'
    def ls
      do_cmd("ls -l '#{@backup_dir}'")
    end

    desc 'rm BACKUP_NAME [BACKUP_NAME ...]', 'delete backups'
    def rm(*backups)
      backups.each do |backup|
        do_cmd("rm '#{@backup_dir}/#{backup}'")
      end
    end

    desc 'open_dir', 'open the backup directory in Finder (for macOS)'
    def open_dir
      do_cmd("open '#{@backup_dir}'")
    end

    desc 'migrate [--seed] [--no-backup]', 'run db:migrate (for rails)'
    option :backup, type: :boolean, default: true
    option :time_suffix, type: :boolean, default: true
    option :seed, type: :boolean, default: false
    def migrate
      do_backup('_backup_before_migrate') if options[:backup]
      do_cmd('bin/rails db:migrate')
      do_cmd('bin/rails db:seed') if options[:seed]
      todo_setup_test_db
    end

    desc 'migrate_status', 'run db:migrate:status (for rails)'
    def migrate_status
      do_cmd('bin/rails db:migrate:status')
    end

    desc 'rollback [--step <STEP>]', 'run db:rollback (for rails)'
    option :step
    def rollback
      do_cmd('bin/rails db:rollback' + (options[:step] ? " STEP=#{options[:step]}" : ''))
      todo_setup_test_db
    end

    desc 'setup_test_db', 'setup a test DB (for rails)'
    def setup_test_db
      do_cmd('bin/rails db:environment:set RAILS_ENV=test')
      do_cmd('bin/rails db:setup RAILS_ENV=test')
    end

    private

    def do_cmd(s)
      puts "$ #{s}"
      system(s) || exit(1)
    end

    def do_backup(backup)
      backup += time_suffix if options[:time_suffix]
      do_cmd("mysqldump #{@mysql_args} -x --databases --add-drop-database '#{@db}'" \
             " | gzip -c > '#{@backup_dir}/#{backup}'")
    end

    def time_suffix
      '_' + `date +%Y_%m_%d_%H_%M_%S`.chomp
    end

    def todo_setup_test_db
      puts("[TODO] run 'myback setup_test_db' to setup a test DB.")
    end
  end
end
