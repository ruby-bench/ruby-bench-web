module ViewHelper
  # Generate an HTML string representing the `hash`, with each pair on a new line
  def hash_to_html(hash)
    hash.map do |k, v|
      if k == :environment
        v
      else
        new_key = k.to_s.split('_').map { |word| word.capitalize }.join(' ')
        "#{new_key}: #{v}" 
      end
    end.join("<br>")
  end
end
