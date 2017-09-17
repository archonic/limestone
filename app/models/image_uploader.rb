require "image_processing/mini_magick"

class ImageUploader < Shrine
  include ImageProcessing::MiniMagick
  plugin :processing
  plugin :versions

  process(:store) do |io, context|
    size_256 = resize_to_limit(io.download, 256, 256)
    size_128 = resize_to_limit(size_256, 128, 128)
    size_64  = resize_to_limit(size_128, 64, 64)
    size_32  = resize_to_limit(size_64, 32, 32)
    size_21  = resize_to_limit(size_32, 21, 21)
    size_16  = resize_to_limit(size_32, 16, 16)
    {xs: size_16, nav: size_21, sm: size_32, md: size_64, lg: size_128, xl: size_256}
  end
end
