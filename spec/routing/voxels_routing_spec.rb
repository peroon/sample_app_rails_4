require "spec_helper"

describe VoxelsController do
  describe "routing" do

    it "routes to #index" do
      get("/voxels").should route_to("voxels#index")
    end

    it "routes to #new" do
      get("/voxels/new").should route_to("voxels#new")
    end

    it "routes to #show" do
      get("/voxels/1").should route_to("voxels#show", :id => "1")
    end

    it "routes to #edit" do
      get("/voxels/1/edit").should route_to("voxels#edit", :id => "1")
    end

    it "routes to #create" do
      post("/voxels").should route_to("voxels#create")
    end

    it "routes to #update" do
      put("/voxels/1").should route_to("voxels#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/voxels/1").should route_to("voxels#destroy", :id => "1")
    end

  end
end
