describe LandingPagesController, type: :controller do
  describe "GET #show" do
    it "returns 200" do
      get :show
      expect(response).to be_ok
    end
  end
end
