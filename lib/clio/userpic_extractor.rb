# encoding: utf-8
class UserpicExtractor < Component
    def run
        load_users!
        extract_userpics
        copy_userpics
    end

    private

    def load_users!
        log.info "Загружаем имена пользователей"

        @users = context.entries.map{|e|
            [e, *e.likes, *e.comments].map(&:from).map(&:id)
        }.flatten.uniq.sort

        @users |= [context.feed_name] # для групп, у них в самих записях юзерпик не встретится

        log.info "Загружено #{@users.count} пользователей"
    end

    def extract_userpics
        to_extract = @users.reject{|u| File.exists?(userpic_path(u))}
        if to_extract.empty?
            log.info "Все нужные юзерпики закешированы"
        else
            log.info "Не закешировано: #{to_extract.count} юзерпиков, загружаем"
            to_extract.each_with_progress do |u|
                extract_userpic(u)
            end
        end
    end

    def copy_userpics
        context.path!('images/userpics/')
        
        log.info "Копирование юзерпиков в папку пользователя"
        @users.each do |u|
            FileUtils.cp userpic_path(u), context.path('images/userpics/')
        end
    end

    def cache_path
        @cache_path ||= File.join(context.clio.result_path, 'userpics').tap{|p| FileUtils.mkdir_p p}
    end

    def userpic_path(user)
        File.join(cache_path, "#{user}.jpg")
    end

    def extract_userpic(user, size='large')
        img = client.raw_request("picture/#{user}", 'size' => size)
        File.write userpic_path(user), img
    end
end