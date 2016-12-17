module PDF
  class Burst
    def initialize(pdf_path, options={})
      @pdf_path = pdf_path
      @output_path = options[:output] || "."
      @page_name = options[:filename] || "page_%d"
      @initial_page_number = options[:initial_page_number] || 1
      @bundle_size = options[:bundle_size] || 1
    end
    
    def run!
      (page_count / @bundle_size.to_f).ceil.times do |i|
        start_page = (@bundle_size * i) + 1
        end_page = (@bundle_size * i) + @bundle_size

        if end_page > page_count
          end_page = page_count
        end

        system burst_command(start_page, end_page, @initial_page_number + i)
      end
    end
    
    def page_count
      `#{page_count_command}`.to_i
    end
    
    private
    
    def page_count_command
      "pdfinfo '#{@pdf_path}' | grep 'Pages:' | grep -o '[0-9].*'"
    end
    
    def burst_command(start_page, end_page, page_number)
      "gs -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -dFirstPage=#{start_page} -dAutoFilterColorImages=false -dAutoFilterGrayImage=false -dColorImageFilter=/FlateEncode -dLastPage=#{end_page} -sOutputFile='#{output_file_path(page_number)}' '#{@pdf_path}'"
    end    
    
    def page_filename(page_number, extension="pdf")
      @page_name % page_number + ".#{extension}"
    end
    
    def output_file_path(page_number, extension="pdf")
      File.expand_path("#{@output_path}/#{page_filename(page_number, extension)}")
    end
  end
end
