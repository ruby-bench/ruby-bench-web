module ReposHelper
  def show_gem_tip
    @repo &&
    @repo.name == 'rails' &&
    @benchmark &&
    @benchmark.category !~ /^discourse_/
  end
end
