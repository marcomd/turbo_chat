# frozen_string_literal: true

class CreateAiImageService
  prepend SimpleCommand
  include AiChats::Messageable

  def initialize(prompt:,
                 ai_chat_id: nil,
                 auth_token: ENV.fetch("IMAGE_GENERATION_AUTH_TOKEN"))
    @ai_chat_id = ai_chat_id
    @prompt = prompt
    @auth_token = auth_token
  end

  def call
    errors.add(:prompt, "is required") if prompt.blank?
    errors.add(:ai_chat_id, "is required") if ai_chat_id.blank?
    errors.add(:ai_chat, "not found") if ai_chat.blank?

    if errors.any?
      notify_error(message: errors.full_messages.to_sentence) if ai_chat
      return
    end

    show_spinner
    response = image_generation_service

    ai_message = nil
    if response.success?
      image_data = response.body # Returns binary image data
      # Create and start propagating the AI message with a spinner
      ai_message = ai_chat.ai_messages.create!(prompt:, answer: "")
      add_ai_message(ai_message:)
    else
      errors.add(:prompt, "Image generation failed: #{response.status}")
    end

    if errors.any?
      notify_error(message: errors.full_messages.to_sentence)
      return
    elsif !image_data
      notify_error(message: "Image generation failed: no image data")
      return
    end

    # Attach the generated image using Active Storage
    ai_message.generated_image.attach(
      io: StringIO.new(image_data),
      filename: "generated_#{Time.current.to_i}.jpg",
      content_type: "image/jpg"
    )

    remove_spinner

    # Broadcast update to show the image
    update_ai_message(ai_message: ai_message)

    true
  rescue StandardError => e
    remove_spinner
    errors.add(:generic, e.message)
    notify_error(message: e.message)
  end

  private

  attr_reader :ai_chat_id, :prompt, :auth_token

  def ai_chat
    @ai_chat ||= AiChat.find_by(id: ai_chat_id) if ai_chat_id
  end

  def image_generation_service
    Faraday.post(ENV.fetch("IMAGE_GENERATION_URL"),
                 {
                   prompt:,
                   model_type: ai_chat.ai_model_name,
                   width: ENV.fetch("IMAGE_GENERATION_WIDTH", 512),
                   height: ENV.fetch("IMAGE_GENERATION_HEIGHT", 512)
                 }.to_json,
                 { "Authorization" => auth_token, "Content-Type" => "application/json" }) do |request|
      request.options.timeout = ENV.fetch("IMAGE_GENERATION_TIMEOUT", 60).to_i
    end
  end
end
