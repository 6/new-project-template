describe "template" do
  it "runs" do
    system("rails new new-project-example -m ~/new-project-template/template/template.rb -d postgresql -T --skip-turbolinks --webpack=react")
  end
end
