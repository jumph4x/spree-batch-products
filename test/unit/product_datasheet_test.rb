require 'test_helper'

class ProductDatasheetTest < ActiveSupport::TestCase
  should have_attached_file :spreadsheet

  should validate_attachment_presence :spreadsheet

  should validate_attachment_content_type(:spreadsheet).allowing('application/vnd.ms-excel','text/plain').rejecting('text/xml')

  context 'ProductDatasheet' do
    setup do
      @not_deleted_product_datasheet = ProductDatasheet.new(:spreadsheet_file_name => 'does_not_exist.csv')
      @not_deleted_product_datasheet.save
      @deleted_product_datasheet = ProductDatasheet.new(:spreadsheet_file_name => 'does_not_exist.csv', :deleted_at => Time.now)
      @deleted_product_datasheet.save
    end

    should 'return all ProductDatasheets with nil :deleted_at attribute on scope :not_deleted call' do
      collection = ProductDatasheet.not_deleted
      assert_equal true, collection.include?(@not_deleted_product_datasheet)
      assert_equal false, collection.include?(@deleted_product_datasheet)
    end

    should 'return all ProductDatasheets with non-nil :deleted_at attribute on scope :deleted call' do
      collection = ProductDatasheet.deleted
      assert_equal false, collection.include?(@not_deleted_product_datasheet)
      assert_equal true, collection.include?(@deleted_product_datasheet)
    end
  end

  context 'A ProductDatasheet' do
    setup do
      @product_datasheet = ProductDatasheet.new
    end

    should 'return the absolute path where it is located on #path call' do
      product_datasheet = ProductDatasheet.new(:spreadsheet_file_name => 'does_not_exist.csv')
      product_datasheet.id = 123456
      assert_equal "#{Rails.root}/uploads/product_datasheets/123456/does_not_exist.csv", product_datasheet.path
    end

    should 'update its statistic attributes :before_save' do
      product_datasheet = ProductDatasheet.new(:spreadsheet_file_name => 'does_not_exist.csv')
      product_datasheet.save
      assert_equal false, product_datasheet.matched_records.nil?
      assert_equal false, product_datasheet.failed_records.nil?
      assert_equal false, product_datasheet.updated_records.nil?
      assert_equal false, product_datasheet.failed_queries.nil?
    end

    should 'set its dummy tracking variables to 0 :after_find and :after_initialize' do
      product_datasheet = ProductDatasheet.new(:spreadsheet_file_name => 'does_not_exist.csv')
      assert_equal 0, product_datasheet.records_matched
      assert_equal 0, product_datasheet.records_failed
      assert_equal 0, product_datasheet.records_updated
      assert_equal 0, product_datasheet.queries_failed
    end

    should 'return true on call to #processed? when :processed_at is not nil' do
      @product_datasheet.processed_at = Time.now
      assert_equal true, @product_datasheet.processed?
    end

    should 'return false on call to #processed? when :processed_at is nil' do
      assert_equal false, @product_datasheet.processed?
    end

    should 'return true on call to #deleted? when :deleted_at is not nil' do
      @product_datasheet.deleted_at = Time.now
      assert_equal true, @product_datasheet.deleted?
    end

    should 'return false on call to #deleted? when :deleted_at is nil' do
      assert_equal false, @product_datasheet.deleted?
    end

    context 'creating new Products' do

      should 'create a new Product when using a valid attr_hash' do
        attr_hash = {:name => 'test_product_name', :slug => 'test-product-permalink', :price => 902.10}
        @product_datasheet.create_product(attr_hash)
        assert_equal 0, @product_datasheet.queries_failed
      end

      should 'increment @failed_queries when using an invalid attr_hash' do
        attr_hash = {}
        @product_datasheet.create_product(attr_hash)
        assert_equal 1, @product_datasheet.queries_failed
      end
    end

    context 'creating new Variants' do

      should 'create a new Variant when using a valid attr_hash' do
        product = Product.new({:name => 'test_product_name', :slug => 'test-product-permalink', :price => 902.10})
        product.save
        attr_hash = {:product_id => product.id}
        @product_datasheet.create_variant(attr_hash)
        assert_equal 0, @product_datasheet.queries_failed
      end

      should 'increment @failed_queries when using an invalid attr_hash' do
        attr_hash = {}
        @product_datasheet.create_variant(attr_hash)
        assert_equal 1, @product_datasheet.queries_failed
      end
    end

    context 'updating Products' do
      setup do
        @product = Product.new({:name => 'test_product_name', :slug => 'test-product-permalink', :price => 902.10})
        @product.save
        @key = 'slug'
        @value = 'test-product-permalink'
      end

      should 'increment @failed_queries when the query returns an empty collection' do
        value = 'chunky bacon chunky bacon chunky bacon'
        attr_hash = {}
        @product_datasheet.update_products(@key, value, attr_hash)
        assert_equal 1, @product_datasheet.queries_failed
      end

      should 'add the size of the collection returned by the query to @records_matched' do
        attr_hash = {}
        @product_datasheet.update_products(@key, @value, attr_hash)
        assert_equal 1, @product_datasheet.records_matched
      end

      should 'increment @records_updated when the Product successfully updates with the attr_hash and saves' do
        attr_hash = {:price => 90210.00}
        @product_datasheet.update_products(@key, @value, attr_hash)
        assert_equal 90210.00, @product.reload.price
        assert_equal 1, @product_datasheet.records_updated
      end

      should 'increment @records_failed when the Product fails to save' do
        attr_hash = {:slug => nil}
        @product_datasheet.update_products(@key, @value, attr_hash)
        assert_equal 1, @product_datasheet.records_failed
      end
    end

    context 'updating Variants' do
      setup do
        product = Product.new({:name => 'test_product_name', :slug => 'test-product-permalink', :price => 902.10})
        product.save
        @variant = Variant.new({:product_id => product.id, :sku => 'testvariantsku'})
        @variant.save
        @key = 'sku'
        @value = 'testvariantsku'
      end

      should 'increment @failed_queries when the query returns an empty collection' do
        value = 'chunky bacon chunky bacon chunky bacon'
        attr_hash = {}
        @product_datasheet.update_variants(@key, value, attr_hash)
        assert_equal 1, @product_datasheet.queries_failed
      end

      should 'add the size of the collection returned by the query to @records_matched' do
        attr_hash = {}
        @product_datasheet.update_variants(@key, @value, attr_hash)
        assert_equal 1, @product_datasheet.records_matched
      end

      should 'increment @records_updated when the Variant successfully updates with the attr_hash and saves' do
        attr_hash = {:price => 90210.00}
        @product_datasheet.update_variants(@key, @value, attr_hash)
        assert_equal 90210.00, @variant.reload.price
        assert_equal 1, @product_datasheet.records_updated
      end

      should 'increment @records_failed when the Variant fails to save' do
        attr_hash = {:cost_price => 'not a number'}
        @product_datasheet.update_variants(@key, @value, attr_hash)
        assert_equal 1, @product_datasheet.records_failed
      end
    end
  end
end
