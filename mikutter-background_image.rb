#coding: utf-8

Plugin.create(:"mikutter-background_image") {
  UserConfig[:background_file] ||= ""
  UserConfig[:background_transparency] ||= 30

  # モンキーパッチ
  class Gdk::MiraclePainter
    alias render_background_orig render_background

    def render_background(context)
      render_background_orig context

      if !File.exist?(UserConfig[:background_file])
        return
      end

      context.save {
        begin
          pixbuf = Gdk::Pixbuf.new(UserConfig[:background_file])

          image = Cairo::ImageSurface.new(pixbuf.width, pixbuf.height)

          image_context = Cairo::Context.new(image)

          image_context.save {
            image_context.set_source_pixbuf(pixbuf)            
            image_context.paint
          }

          pattern = Cairo::SurfacePattern.new(image)
          pattern.set_extend(Cairo::EXTEND_REPEAT)

          context.set_source(pattern)
          context.paint(UserConfig[:background_transparency].to_f / 100.0)
        rescue => e
          puts e
          puts e.backtrace
        end
      }
    end
  end

  # 設定
  settings(_("背景画像")) {
    fileselect(_("PNGファイル"), :background_file)
    adjustment(_("濃さ(%)"), :background_transparency, 0, 100)
  }
}
