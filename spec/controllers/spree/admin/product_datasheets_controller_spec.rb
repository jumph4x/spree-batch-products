require 'spec_helper'

describe Spree::Admin::ProductDatasheetsController, type: :controller do
  render_views

  before do
    controller.stub :spree_current_user => FactoryGirl.create(:admin_user)
  end

  describe "on :index" do
    it "renders index" do
      get :index, :use_route => :spree
    end
  end

  describe "on :new" do
    it "renders index" do
      get :new, :use_route => :spree
    end
  end

end
