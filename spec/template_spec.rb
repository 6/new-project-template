describe "template" do
  it "runs" do
    system("rails new new-project-example -m ~/repo/new-project-template/template/template.rb -d postgresql -T --skip-turbolinks --webpack=react") or raise "Something went wrong"
  end
end
