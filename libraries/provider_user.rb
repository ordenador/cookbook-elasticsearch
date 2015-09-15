require 'poise'

class Chef
  # Chef Provider for creating a user and group for Elasticsearch
  class Provider::ElasticsearchUser < Provider
    include Poise

    def action_create
      converge_by("create elasticsearch_user resource #{new_resource.name}") do
        notifying_block do
          unless new_resource.homedir
            # if unset, default it to a calculated value
            new_resource.homedir ::File.join(new_resource.homedir_parent, new_resource.homedir_name)
          end


          group new_resource.groupname do
            gid new_resource.gid
            action :create
            system true
          end

          user new_resource.username do
            comment new_resource.comment
            home    new_resource.homedir
            shell   new_resource.shell
            uid     new_resource.uid
            gid     new_resource.groupname
            supports manage_home: false
            action  :create
            system true
          end
        end
      end
    end

    def action_remove
      converge_by("remove elasticsearch_user resource #{new_resource.name}") do
        notifying_block do
          # delete user before deleting the group
          user new_resource.username do
            action  :remove
          end

          group new_resource.groupname do
            action :remove
          end
        end
      end
    end
  end
end
