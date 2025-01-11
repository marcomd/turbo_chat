# frozen_string_literal: true

module AiChats
  require "redcarpet"
  require "rouge"
  require "rouge/plugins/redcarpet"

  class Markdown
    class RougeHTML < Redcarpet::Render::HTML
      include Rouge::Plugins::Redcarpet
    end

    EXTENSIONS = {
      autolink: true,
      hightlight: true,
      superscript: true,
      fenced_code_blocks: true,
      no_intra_emphasis: true,
      lax_spacing: true,
      strikethrough: true,
      tables: true
    }

    OPTIONS = {
      filter_html: true,
      hard_wrap: true,
      link_attributes: { rel: "nofollow", target: "_blank" }
    }

    attr_reader :markdown

    def initialize(options: OPTIONS, extensions: EXTENSIONS)
      renderer = RougeHTML.new(options)
      @markdown = Redcarpet::Markdown.new(renderer, extensions)
    end

    delegate :render, to: :markdown
  end
end
