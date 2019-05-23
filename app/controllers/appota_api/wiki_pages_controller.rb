class AppotaApi::WikiPagesController < AppotaApiController
  before_action :set_project
  before_action :set_wiki_page, only: [:show, :history, :update, :destroy]

  def index
    wiki = @project.wiki
    pages = wiki.pages
    total = pages.count
    
    # pagination
    offset = params[:offset] || 0
    limit = params[:limit] || 30
    pages = pages.offset(offset).limit(limit)

    render json: render_wiki_pages(pages, total)
  end

  def show
    render json: render_wiki_page(@wiki_page)
  end

  def history
    limit = params[:limit].present? ? params[:page].to_i : 30
    page = params[:page].present? ? params[:page].to_i : 1

    offset = (page - 1) * limit

    @versions = @wiki_page
      .content
      .versions
      .select(:id, :user_id, :notes, :created_at, :version)
      .order(Arel.sql('version DESC'))
      .offset(offset)
      .limit(limit)

    render json: {
      "_type": "Collection",
      "items": @versions.as_json
    }
  end

  def create
    wiki_page_params = parse_params
    WikiPage.transaction do
      @wiki_page = @project.wiki.pages.create({
        title: wiki_page_params[:title],
        slug: wiki_page_params[:slug]
      })
      @wiki_page.content = WikiContent.create({
        author_id: @current_user_id,
        text: wiki_page_params[:content],
        page_id: @wiki_page.id
      })
    end

    render json: render_wiki_page(@wiki_page)
  end

  def update
    wiki_page_params = parse_params
    WikiPage.transaction do
      @wiki_page.title = wiki_page_params[:title] if wiki_page_params[:title].present?
      @wiki_page.slug = wiki_page_params[:slug] if wiki_page_params[:slut].present?
      @wiki_page.save
      @content = @wiki_page.content
      @content.comments = wiki_page_params[:notes]
      @content.text = wiki_page_params[:content]
      @content.save
    end
    render json: render_wiki_page(@wiki_page)
  end

  def destroy
    begin
      @wiki_page.descendants.each(&:destroy)
      render json: {
        success: true
      }
    rescue
      render status: 403, json: {
        success: false,
        message: "Unable to delete wiki page"
      }
    end
  end

  private

  def parse_params
    allowed_params = [:title, :slug, :content, :notes]
    request_params = params.permit!.to_h.deep_symbolize_keys
    return request_params.select { |k, v| allowed_params.include? k }
  end

  def set_project
    @project_id = params[:project_id]
    if @project_id.present?
      if @project_id.to_i.to_s == @project_id
        @project = Project.where(id: @project_id).first
      else
        @project = Project.where(identifier: @project_id).first
      end
    end
    @project ||= @workspace
  end

  def set_wiki_page
    wiki_page_id = params[:id]
    if wiki_page_id.to_i.to_s == wiki_page_id
      @wiki_page = WikiPage.where(id: wiki_page_id).first
    else
      @wiki_page = WikiPage.where(slug: wiki_page_id).first
    end
    unless @wiki_page.present?
      render status: 404, json: {
        _type: "Error",
        message: "Wiki Page ID: #{wiki_page_id} was not found"
      }
    end
  end

  def render_wiki_page wiki_page
    if wiki_page.errors.present?
      return {
        "_type": "Error",
        message: wiki_page.errors
      }
    else
      wiki_page_json = {
        _type: "WikiPage"
      }
      wiki_page_json = wiki_page_json.merge!(wiki_page.as_json)
      wiki_page_json[:content] = wiki_page.content.as_json
      return wiki_page_json
    end
  end

  def render_wiki_pages wiki_pages, total = 0
    return {
      "_type": "Collection",
      "total": total,
      "items": wiki_pages.map { |v| render_wiki_page(v) }
    }
  end

end
