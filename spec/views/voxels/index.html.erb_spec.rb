require 'spec_helper'

describe "voxels/index" do
  before(:each) do
    assign(:voxels, [
      stub_model(Voxel,
        :user_id => 1,
        :title => "Title",
        :voxeljson => "MyText"
      ),
      stub_model(Voxel,
        :user_id => 1,
        :title => "Title",
        :voxeljson => "MyText"
      )
    ])
  end

  it "renders a list of voxels" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Title".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end
