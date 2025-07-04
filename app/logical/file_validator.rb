# frozen_string_literal: true

class FileValidator
  attr_reader :record, :file_path

  def initialize(record, file_path)
    @record = record
    @file_path = file_path
  end

  def validate(max_file_sizes: Danbooru.config.max_file_sizes, max_width: Danbooru.config.max_image_width, max_height: Danbooru.config.max_image_height, min_width: Danbooru.config.small_image_width)
    validate_file_ext(max_file_sizes)
    validate_file_size(max_file_sizes)
    validate_file_integrity
    if record.is_video?
      video = record.video(file_path)
      validate_container_format(video)
      validate_audio_codec(video)
      validate_duration(video)
      validate_colorspace(video)
      validate_sar(video)
    end
    validate_resolution(max_width, max_height, min_width)
  end

  def validate_file_integrity
    if record.is_image? && record.is_corrupt?(file_path)
      record.errors.add(:file, "is corrupt")
    end
  end

  def validate_file_ext(max_file_sizes)
    if max_file_sizes.keys.exclude? record.file_ext
      record.errors.add(:file_ext, "#{record.file_ext} is invalid (only #{max_file_sizes.keys.to_sentence} files are allowed)")
      throw :abort
    end
  end

  def validate_file_size(max_file_sizes)
    if record.file_size <= 16
      record.errors.add(:file_size, "is too small")
    end
    max_size = max_file_sizes.fetch(record.file_ext, 0)
    if record.file_size > max_size
      record.errors.add(:file_size, "is too large. Maximum allowed for this file type is #{ApplicationController.helpers.number_to_human_size(max_size)}")
    end
    if record.is_animated_png?(file_path) && record.file_size > Danbooru.config.max_apng_file_size
      record.errors.add(:file_size, "is too large. Maximum allowed for this file type is #{ApplicationController.helpers.number_to_human_size(Danbooru.config.max_apng_file_size)}")
    end
  end

  def validate_resolution(max_width, max_height, min_width)
    resolution = record.image_width.to_i * record.image_height.to_i

    if resolution > Danbooru.config.max_image_resolution
      record.errors.add(:base, "image resolution is too large (resolution: #{(resolution / 1_000_000.0).round(1)} megapixels (#{record.image_width}x#{record.image_height}); max: #{Danbooru.config.max_image_resolution / 1_000_000} megapixels)")
    elsif record.image_width > max_width
      record.errors.add(:image_width, "is too large (width: #{record.image_width}; max width: #{max_width})")
    elsif record.image_height > max_height
      record.errors.add(:image_height, "is too large (height: #{record.image_height}; max height: #{max_height})")
    end

    if record.image_width < min_width
      record.errors.add(:image_width, "is too small (width: #{record.image_width}; min width: #{min_width})")
    elsif record.image_height < min_width
      record.errors.add(:image_height, "is too small (height: #{record.image_height}; min height: #{min_width})")
    end
  end

  def validate_duration(video)
    if video.duration > Danbooru.config.max_video_duration
      record.errors.add(:base, "video must not be longer than #{Danbooru.config.max_video_duration} seconds")
    end
  end

  def validate_container_format(video)
    unless video.valid?
      record.errors.add(:base, "video isn't valid")
      return
    end
    valid_webm = video.container == "matroska,webm" && %w[vp8 vp9].include?(video.video_codec)
    # In the future, we want to allow "h264".
    valid_mp4  = video.container == "mov,mp4,m4a,3gp,3g2,mj2" && %w[av1].include?(video.video_codec)
    unless valid_webm || valid_mp4
      record.errors.add(:base, "video must be WebM with VP8/VP9 or MP4 with AV1, but found #{video.container} with #{video.video_codec}")
    end
  end

  def validate_audio_codec(video)
    return unless video.video_codec == "av1"

    allowed_audio_codecs = %w[opus aac mp3]
    if video.audio_codec.present? && allowed_audio_codecs.exclude?(video.audio_codec)
      record.errors.add(:base, "video uses AV1 and must use Opus, AAC, or MP3 audio codec, but found #{video.audio_codec}")
    end
  end

  def validate_colorspace(video)
    record.errors.add(:base, "video colorspace must be yuv420p, was #{video.colorspace}") unless video.colorspace == "yuv420p"
  end

  def validate_sar(video)
    if video.sar.present? && video.sar != "1:1"
      record.errors.add(:base, "video is anamorphic (SAR is #{video.sar})")
    end
  end
end
