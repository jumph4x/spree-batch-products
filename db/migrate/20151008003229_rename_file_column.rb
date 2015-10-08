class RenameFileColumn < ActiveRecord::Migration
  def change
    rename_column :spree_product_datasheets, :xls_file_name, :spreadsheet_file_name
    rename_column :spree_product_datasheets, :xls_file_size, :spreadsheet_file_size
    rename_column :spree_product_datasheets, :xls_content_type, :spreadsheet_content_type
  end
end
