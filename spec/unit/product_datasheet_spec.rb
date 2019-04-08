require 'spec_helper'

describe Spree::ProductDatasheet do

  context 'with file attachments' do
    before(:each) do
      @not_deleted_product_datasheet = Spree::ProductDatasheet.new(:spreadsheet_file_name => 'does_not_exist.csv')
      @not_deleted_product_datasheet.save

      @deleted_product_datasheet = Spree::ProductDatasheet.new(:spreadsheet_file_name => 'does_not_exist.csv', :deleted_at => Time.now)
      @deleted_product_datasheet.save
    end

    it 'should return all ProductDatasheets with nil :deleted_at attribute on scope :not_deleted call' do
      collection = Spree::ProductDatasheet.not_deleted
      collection.should include(@not_deleted_product_datasheet)
      collection.should_not include(@deleted_product_datasheet)
    end

    it 'should return all ProductDatasheets with non-nil :deleted_at attribute on scope :deleted call' do
      collection = Spree::ProductDatasheet.deleted
      collection.should_not include(@not_deleted_product_datasheet)
      collection.should include(@deleted_product_datasheet)
    end
  end

  context 'in general' do
    before(:each) do
      @product_datasheet = Spree::ProductDatasheet.new
    end

    it 'should update its statistic attributes :before_save' do
      product_datasheet = Spree::ProductDatasheet.new(:spreadsheet_file_name => 'does_not_exist.csv')
      product_datasheet.save
      product_datasheet.matched_records.should_not be_nil
      product_datasheet.failed_records.should_not be_nil
      product_datasheet.updated_records.should_not be_nil
      product_datasheet.failed_queries.should_not be_nil
    end

    it 'should set its dummy tracking variables to 0 :after_find and :after_initialize' do
      product_datasheet = Spree::ProductDatasheet.new(:spreadsheet_file_name => 'does_not_exist.csv')
      product_datasheet.records_matched.should == 0
      product_datasheet.records_failed.should == 0
      product_datasheet.records_updated.should == 0
      product_datasheet.queries_failed.should == 0
    end

    it 'should return true on call to #processed? when :processed_at is not nil' do
      @product_datasheet.processed_at = Time.now
      @product_datasheet.processed?.should be true
    end

    it 'should return false on call to #processed? when :processed_at is nil' do
      @product_datasheet.processed?.should be false
    end

    it 'should return true on call to #deleted? when :deleted_at is not nil' do
      @product_datasheet.deleted_at = Time.now
      @product_datasheet.deleted?.should be true
    end

    it 'should return false on call to #deleted? when :deleted_at is nil' do
      @product_datasheet.deleted?.should be false
    end

    context 'creating new Products' do
      it 'should create a new Product when using a valid attr_hash' do
        @shipping_category = FactoryGirl.create(:shipping_category)
        attr_hash = {:name => 'test_product_name', :slug => 'test-product-permalink', :price => 902.10, :shipping_category_id => @shipping_category.id}
        @product_datasheet.create_product(attr_hash)
        @product_datasheet.queries_failed.should == 0
      end

      it 'should increment @failed_queries when using an invalid attr_hash' do
        attr_hash = {}
        @product_datasheet.create_product(attr_hash)
        @product_datasheet.queries_failed.should == 1
      end
    end

    context 'creating new Variants' do

      it 'should create a new Variant when using a valid attr_hash' do
        product = FactoryGirl.create(:product, {:name => 'test_product_name', :slug => 'test-product-permalink', :price => 902.10})
        attr_hash = {:product_id => product.id}
        @product_datasheet.create_variant(attr_hash)
        @product_datasheet.queries_failed.should == 0
      end

      it 'should increment @failed_queries when using an invalid attr_hash' do
        attr_hash = {}
        @product_datasheet.create_variant(attr_hash)
        @product_datasheet.queries_failed.should == 1
      end
    end

    context 'updating Products' do
      before(:each) do
        @product = FactoryGirl.create(:product, {:name => 'test_product_name', :slug => 'test-product-permalink', :price => 777})
        @key = 'slug'
        @value = 'test-product-permalink'
      end

      let(:products){ @product_datasheet.find_products(@key, @value) }

      it 'should increment @failed_queries when the query returns an empty collection' do
        value = 'chunky bacon chunky bacon chunky bacon'
        @product_datasheet.find_products(@key, value)
        @product_datasheet.queries_failed.should == 1
      end

      it 'should add the size of the collection returned by the query to @records_matched' do
        products
        @product_datasheet.records_matched.should == 1
      end

      it 'should increment @records_updated when the Product successfully updates with the attr_hash and saves' do
        attr_hash = {:price => 666}
        @product.reload.price.to_f.should == 777
        @product_datasheet.update_products products, attr_hash
        @product.master.reload.price.to_f.should == 666
        @product_datasheet.records_updated.should == 1
      end

      it 'should increment @records_failed when the Product fails to save' do
        attr_hash = {:slug => ''}
        @product_datasheet.update_products products, attr_hash
        @product_datasheet.records_failed.should == 1
      end

      it 'should recognize the sentinel string value \'nil\'' do
        @product_datasheet.stub(:headers).and_return([@key, :description])
        @product_datasheet.stub(:primary_key).and_return(@key)
        @product_datasheet.touched_product_ids = []
        row = [@value, 'nil']
        @product_datasheet.handle_line row
        @product.reload.description.should == nil
      end
    end

    context 'updating Variants' do
      before(:each) do
        @product = FactoryGirl.create(:product, {:name => 'test_product_name', :slug => 'test-product-permalink', :sku => 'testvariantsku', :price => 902.10})
        @variant = @product.master

        @key = 'sku'
        @value = 'testvariantsku'
      end

      let(:products){ @product_datasheet.find_products_by_variant(@key, @value) }

      it 'should increment @failed_queries when the query returns an empty collection' do
        value = 'chunky bacon chunky bacon chunky bacon'
        @product_datasheet.find_products_by_variant(@key, value)
        @product_datasheet.queries_failed.should == 1
      end

      it 'should add the size of the collection returned by the query to @records_matched' do
        products
        @product_datasheet.records_matched.should == 1
      end

      it 'should increment @records_updated when the Variant successfully updates with the attr_hash and saves' do
        attr_hash = {:price => 666}
        @product_datasheet.update_products(products, attr_hash)
        @product_datasheet.records_updated.should == 1
        @variant.reload.price.to_f.should == 666
        @product.reload.price.to_f.should == 666
      end

    end
  end
end
