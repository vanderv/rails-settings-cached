module RailsSettings
  class CachedSettings < Settings
    after_update :rewrite_cache    
    after_create :rewrite_cache
    def rewrite_cache
      locale = I18n.locale
      Rails.cache.write("settings:#{locale}:#{self.var}", self.value)
    end
    
    after_destroy { |record| Rails.cache.delete("settings:#{I18n.locale}:#{record.var}") }
    
    def self.[](var_name)
      locale = I18n.locale
      cache_key = "settings:#{locale}:#{var_name}"
      obj = Rails.cache.fetch(cache_key) {
        super(var_name)
      }
      obj == nil ? @@defaults[var_name.to_s] : obj
    end    
    
    def self.save_default(key,value)
      if self.send(key) == nil
        self.send("#{key}=",value)
      end
    end
  end
end