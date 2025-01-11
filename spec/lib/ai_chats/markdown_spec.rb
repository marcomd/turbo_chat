# frozen_string_literal: true

require 'rails_helper'

describe AiChats::Markdown do
  describe '.new' do
    it 'returns a Markdown instance' do
      is_expected.to be_a(described_class)
    end
  end

  describe '#render' do
    let(:result) { subject.render(input) }

    context 'when input contains markdown text' do
      let(:input) { '# Hello World' }
      let(:expected) { "<h1>Hello World</h1>\n" }

      it 'renders markdown to HTML' do
        expect(result).to eq(expected)
      end
    end

    context 'when input contains code' do
      let(:input) do
        <<~MARKDOWN
          ```ruby
          def hello_world
            puts 'Hello World!'
          end
          ```
        MARKDOWN
      end

      it 'renders code blocks' do
        expect(result).to include('<div class="highlight"><pre class="highlight ruby"><code>')
        expect(result).to include('hello_world')
      end
    end
  end

  describe '#markdown' do
    it 'returns the internal Redcarpet::Markdown instance' do
      expect(subject.markdown).to be_a(Redcarpet::Markdown)
    end
  end
end
