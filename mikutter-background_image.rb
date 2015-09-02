#coding: utf-8

Plugin.create(:"mikutter-background_image") {
  UserConfig[:background_file] ||= ""
  UserConfig[:background_transparency] ||= 30

  # モンキーパッチ
  class Gdk::MiraclePainter
    alias render_background_orig render_background

    @@pattern = nil

    def self.load_pattern!
      begin
        pixbuf = Gdk::Pixbuf.new(UserConfig[:background_file])

        image = Cairo::ImageSurface.new(pixbuf.width, pixbuf.height)

        image_context = Cairo::Context.new(image)

        image_context.save {
          image_context.set_source_pixbuf(pixbuf)            
          image_context.paint
        }

        @@pattern = Cairo::SurfacePattern.new(image)
        @@pattern.set_extend(Cairo::EXTEND_REPEAT)
      rescue => e
        puts e
        puts e.backtrace
      end
     end

    def render_background(context)
      render_background_orig context

      if !File.exist?(UserConfig[:background_file])
        return
      end

      if !@@pattern
        Gdk::MiraclePainter::load_pattern!
      end

      context.save {
        begin
          context.set_source(@@pattern)
          context.paint(UserConfig[:background_transparency].to_f / 100.0)
        rescue => e
          puts e
          puts e.backtrace
        end
      }
    end
  end

  UserConfig.connect(:background_file) {
    Gdk::MiraclePainter::load_pattern!
  }

  # 設定
  settings(_("背景画像")) {
    fileselect(_("画像ファイル"), :background_file)
    adjustment(_("濃さ(%)"), :background_transparency, 0, 100)
  }
}
