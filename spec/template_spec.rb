describe "template" do
  it "runs" do
    output = `rails new new-project-example -m ~/new-project-template/template/template.rb -d postgresql -T --skip-turbolinks --webpack=react`
    expect(output).not_to include("rails aborted!")
  end
end
