require 'spec_helper'

describe "voxels/show" do
  before(:each) do
    @voxel = assign(:voxel, stub_model(Voxel,
      :user_id => 1,
      :title => "Title",
      :voxeljson => "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/1/)
    rendered.should match(/Title/)
    rendered.should match(/MyText/)
  end
end
