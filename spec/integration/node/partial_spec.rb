describe "{{> partial}}" do
  describe "#compile" do
    let(:post) { double("post") }
    let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

    it "evaluates the methods chain call" do
      template = Curlybars.compile(<<-HBS)
        {{> partial}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
        partial
      HTML
    end

    it "renders nothing when the partial returns `nil`" do
      template = Curlybars.compile(<<-HBS)
        {{> return_nil}}
      HBS

      expect(eval(template)).to resemble(<<-HTML)
      HTML
    end
  end

  describe "#validate" do
    let(:presenter_class) { double(:presenter_class) }

    it "validates the path with errors" do
      allow(presenter_class).to receive(:dependency_tree) do
        {}
      end

      source = <<-HBS
        {{> unallowed_partial}}
      HBS

      errors = Curlybars.validate(presenter_class, source)

      expect(errors).not_to be_empty
    end
  end
end
