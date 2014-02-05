ActiveAdmin.register_page "Dashboard" do

  controller do
    actions :all, :except => [:edit, :destroy]
  end

  menu :priority => 1, :label => proc{ I18n.t("active_admin.dashboard") }

  content :title => proc{ I18n.t("active_admin.dashboard") } do
    div :class => "blank_slate_container", :id => "dashboard_default_message" do
      span :class => "blank_slate" do
        span "Wecome to the Orient Mobile Dashboard"
      end
    end

    # Here is an example of a simple dashboard with columns and panels.
    #
    columns do
      column do 
      end
    end

    columns do
      column do
        panel "Links" do
          ul do
            li link_to("Corporate Quotes", new_quote_path)
          end
        end
      end

      column do
      end

      column do
      end

    end
  end # content

  #action_item do
  #  link_to "Download Records", reports_path
  #end
end
