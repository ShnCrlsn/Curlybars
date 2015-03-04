describe "{{#each collection}}...{{/each}}" do
  let(:post) { double("post") }
  let(:presenter) { IntegrationTest::Presenter.new(double("view_context"), post: post) }

  it "uses each_template when collection is not empty" do
    allow(presenter).to receive(:allows_method?).with(:non_empty_collection) { true }
    allow(presenter).to receive(:non_empty_collection) { [presenter] }

    template = Curlybars.compile(<<-HBS)
      {{#each non_empty_collection}}
        each_template
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      each_template
    HTML
  end

  it "doesn't use each_template when collection is empty" do
    allow(presenter).to receive(:allows_method?).with(:empty_collection) { true }
    allow(presenter).to receive(:empty_collection) { [] }

    template = Curlybars.compile(<<-HBS)
      {{#each empty_collection}}
        each_template
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "allows empty each_template" do
    allow(presenter).to receive(:allows_method?).with(:non_empty_collection) { true }
    allow(presenter).to receive(:non_empty_collection) { [presenter] }

    template = Curlybars.compile(<<-HBS)
      {{#each non_empty_collection}}{{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "uses each_template when collection is not empty" do
    path_presenter_class = Class.new(Curlybars::Presenter) do
      presents :path
      allow_methods :path
      def path
        @path
      end
    end

    a_path_presenter = path_presenter_class.new(nil, path: 'a_path')
    another_path_presenter = path_presenter_class.new(nil, path: 'another_path')

    allow(presenter).to receive(:allows_method?).with(:non_empty_collection) { true }
    allow(presenter).to receive(:non_empty_collection) { [a_path_presenter, another_path_presenter] }

    template = Curlybars.compile(<<-HBS)
      {{#each non_empty_collection}}
        {{path}}
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
      a_path
      another_path
    HTML
  end

  it "raises an error if the context is not an array-like object" do
    allow(presenter).to receive(:allows_method?).with(:not_a_collection) { true }
    allow(presenter).to receive(:not_a_collection) { "string" }

    template = Curlybars.compile(<<-HBS)
      {{#each not_a_collection}}{{/each}}
    HBS

    expect do
      eval(template)
    end.to raise_error(Curlybars::Error::Render)
  end

  it "renders nothing if the context is nil" do
    template = Curlybars.compile(<<-HBS)
      {{#each return_nil}}
        text
      {{/each}}
    HBS

    expect(eval(template)).to resemble(<<-HTML)
    HTML
  end

  it "raises an error if the objects inside of the context array are not presenters" do
    allow(presenter).to receive(:allows_method?).with(:not_a_presenter_collection) { true }
    allow(presenter).to receive(:not_a_presenter_collection) { [:an_element] }

    template = Curlybars.compile(<<-HBS)
      {{#each not_a_presenter_collection}}{{/each}}
    HBS

    expect do
      eval(template)
    end.to raise_error(Curlybars::Error::Render)
  end
end
