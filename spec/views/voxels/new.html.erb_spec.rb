require 'spec_helper'

describe "voxels/new" do
  before(:each) do
    assign(:voxel, stub_model(Voxel,
      :user_id => 1,
      :title => "MyString",
      :voxeljson => "MyText"
    ).as_new_record)
  end

  it "renders new voxel form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", voxels_path, "post" do
      assert_select "input#voxel_user_id[name=?]", "voxel[user_id]"
      assert_select "input#voxel_title[name=?]", "voxel[title]"
      assert_select "textarea#voxel_voxeljson[name=?]", "voxel[voxeljson]"
    end
  end
end
