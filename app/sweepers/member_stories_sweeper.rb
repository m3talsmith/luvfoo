class MemberStoriesSweeper < ActionController::Caching::Sweeper
  observe NewsItem

  def after_create(news_item)
    expire_cache_for(news_item)
  end
  
  def after_update(news_item)
    expire_cache_for(news_item)
  end
  
  def after_destroy(news_item)
    expire_cache_for(news_item)
  end
          
  private
  
  def expire_cache_for(news_item)
    if news_item.newsable_type == 'Widget' && news_item.newsable.name = 'member_stories'
      expire_fragment(:controller => '/home', :action => 'home')
    end
  end
end