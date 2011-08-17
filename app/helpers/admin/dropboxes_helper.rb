module Admin::DropboxesHelper

  def file_template
    template_for(:file_template) do
      <<-DB_FILE
        <img src='https://api.dropbox/0/links<%= path %>'/>
        <ul>
          <li class='path'><%= path %>
          <li class='revision'><%= revision %>
        </ul>
      DB_FILE
    end
  end

  def directory_template
    template_for(:directory_template) do
      <<-DB_DIRECTORY
          <a class='path' href='#cd<%= path %>'><%= path %></a>
          <ul>
            <li class='revision'><%= revision %></li>
          </ul>
        </div>
      DB_DIRECTORY
    end
  end

  def dropbox_template
    template_for(:dropbox_template) do
      <<-DB_FILE
        <button data-url='dropboxes/sync' class='sync'>Sync</button>
        <div id='dropbox_items'>
      DB_FILE
    end
  end

  private

  def template_for(id)
    raw <<-TAGS
      <script id=#{id} type='text/template'>
        #{yield}
      </script>
    TAGS
  end

end
