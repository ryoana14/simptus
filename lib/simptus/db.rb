require 'active_record'
require 'simptus/execute'

module Simptus
  module DB
    def self.prepare
      db_path = File.join(ENV["HOME"], '.simptus', 'simptus.sqlite3')
      server_list = Execute::Common.read_server_list
      connect_db(db_path)
      create_table_if_not_exists(db_path, server_list)
    end

    # DB接続処理
    def self.connect_db(path)
      options = {adapter: "sqlite3", database: path}
      ActiveRecord::Base.establish_connection options
    end

    # 存在しない場合はDBとテーブルを作成する。
    def self.create_table_if_not_exists(path, server_list)
      connection = ActiveRecord::Base.connection

      return if connection.table_exists?(:resources)

      puts "テーブルが存在しないため、新規に作成します。"

      # テーブル作成
      connection.create_table :resources do |r|
        server_list.each_key do |section|
          server_name = section.to_s
          idle = server_name + '_idle'
          total = server_name + '_total'
          mem = server_name + '_mem'

          r.column idle,  :integer, default: 0, null: false
          r.column total, :integer, default: 0, null: false
          r.column mem,   :integer, default: 0, null: false
        end
        r.column :time, :string, null: false
      end
    end

    private_class_method :connect_db, :create_table_if_not_exists
  end
end
