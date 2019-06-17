module ReposHelper
  def show_gem_tip
    @repo &&
    @repo.name == 'rails' &&
    @benchmark &&
    @benchmark.category !~ /^discourse_/
  end

  def script_name
    @benchmark.script_url.match(/\/([^\/]+)$/)[1]
  end
end
