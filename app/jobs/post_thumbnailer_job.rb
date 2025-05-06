# frozen_string_literal: true

class PostThumbnailerJob < ApplicationJob
  queue_as :video
  sidekiq_options lock: :until_executed, lock_args_method: :lock_args, retry: 1

  def self.lock_args(args)
    [args[0]]
  end

  def perform(id)
    post = Post.find(id)

    Post.transaction do
      samples = generate_images(post)
      post.reload # Make sure post had not been deleted in the meantime

      move_images(post, samples)
      post.reload
    end
  end

  # Handles the image generation process.
  # Returns a hash of processed files.
  def generate_images(post)
    # if post is a video, we have to generate a screencap using ffmpeg first
    if post.is_video?
      image = Vips::Image.new_from_file generate_video_base_image(post).path
    else
      image = Vips::Image.new_from_file post.file_path
    end

    {
      thumbnails: generate_thumbnails(post, image),
      sample: generate_sample(post, image),
    }
  end

  # Generates a full-size screencap of the first frame of the video.
  # It is necessary to generate smaller images down the line.
  def generate_video_base_image(post)
    output_file = Tempfile.new(["video-preview", ".webp"], binmode: true)
    stdout, stderr, status = Open3.capture3(Danbooru.config.ffmpeg_path, "-y", "-i", post.file_path, "-vf", "thumbnail,scale=#{post.image_width}:-1", "-frames:v", "1", output_file.path)

    unless status == 0
      Rails.logger.warn("[FFMPEG PREVIEW STDOUT] #{stdout.chomp!}")
      Rails.logger.warn("[FFMPEG PREVIEW STDERR] #{stderr.chomp!}")
      raise CorruptFileError, "could not generate thumbnail"
    end

    output_file
  end

  def bg_color(post)
    @bg_color ||= begin
      color = post.bg_color || "152f56"
      [
        color[0..1].to_i(16),
        color[2..3].to_i(16),
        color[4..5].to_i(16),
      ]
    end
  end

  def calculate_scale(post, limit, crop: false)
    limit = limit.to_f
    if post.image_width < post.image_height # vertical
      new_scale = limit / post.image_width
      crop_area = [limit, limit * 2] if crop && post.image_height * new_scale > limit * 2
    elsif post.image_width > post.image_height # horizontal
      new_scale = limit / post.image_height
      crop_area = [limit * 2, limit] if crop && post.image_width * new_scale > limit * 2
    else # square
      new_scale = limit / post.image_width
    end

    [new_scale, crop_area]
  end

  # Generates thumbnails for the post.
  # This includes both the jpg and webp versions.
  def generate_thumbnails(post, image)
    # scale
    new_scale, crop_area = calculate_scale(post, Danbooru.config.small_image_width, crop: true)
    result = image.resize(new_scale)

    # crop
    unless crop_area.nil?
      result = result.smartcrop(crop_area[0], crop_area[1], interesting: :entropy)
    end

    # save
    jpg_thumb = Tempfile.new(["image-thumb", ".jpg"], binmode: true)
    webp_thumb = Tempfile.new(["image-thumb", ".webp"], binmode: true)
    result.jpegsave(jpg_thumb.path, Q: 90, background: bg_color(post), strip: true, interlace: true, optimize_coding: true)
    result.webpsave(webp_thumb.path, Q: 90)

    {
      jpg: jpg_thumb,
      webp: webp_thumb,
    }
  end

  def generate_sample(post, image)
    return nil unless post.is_video? || post.file_ext == "gif" || [post.image_width, post.image_height].min > 850

    # scale
    new_scale, _crop_area = calculate_scale(post, Danbooru.config.large_image_width)
    result = image.resize(new_scale)

    # save
    jpg_thumb = Tempfile.new(["image-thumb", ".jpg"], binmode: true)
    result.jpegsave(jpg_thumb.path, Q: 90, background: bg_color(post), strip: true, interlace: true, optimize_coding: true)

    jpg_thumb
  end

  # Moves the generated images to their final location.
  def move_images(post, outputs)
    md5 = post.md5
    sm = Danbooru.config.storage_manager

    outputs[:thumbnails].each do |ext, image|
      path = sm.file_path(md5, ext, :preview, post.is_deleted?)
      sm.store(image, path)
      image.close!
    end

    unless outputs[:sample].nil?
      path = sm.file_path(md5, "jpg", :large, post.is_deleted?)
      sm.store(outputs[:sample], path)
      outputs[:sample].close!
    end
  end
end
