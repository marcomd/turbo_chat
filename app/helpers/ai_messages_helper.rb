# frozen_string_literal: true

module AiMessagesHelper
  # Returns the CSS classes for the message element
  # @param [Hash] local_assigns
  # @param [AiMessage] ai_message
  # @return [String]
  def build_message_css_classes(local_assigns:, ai_message:)
    [].tap do |classes|
      classes << " new" if local_assigns[:is_new]
      classes << " excluded" if ai_message.excluded?
    end.join
  end

  # Returns the data properties for the message element
  # @return [Hash]
  def bootstrap_data_properties
    {} # Leave it blank for now
  end
end
