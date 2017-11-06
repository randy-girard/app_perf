class EnableUuidExtension < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'
  end
end
