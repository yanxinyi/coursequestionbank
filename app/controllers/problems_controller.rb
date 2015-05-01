class ProblemsController < ApplicationController
  before_filter :set_filter_options
 @@defaults = HashWithIndifferentAccess.new({'tags' => "", 'collections' => {}, 'last_exported_begin' => "", 'last_exported_end' => '', 'per_page' => 5 }) #default arguments hash, not sure about the proper styling for this

  def set_filter_options
    session[:filters] ||= HashWithIndifferentAccess.new(@@defaults)
    session[:filters] = session[:filters].merge params.slice(:tags, :collections, :last_exported_begin, :last_exported_end, :search, :page, :per_page)

  end

  def home
      redirect_to problems_path
  end

  def index
    @collections = @current_user.collections
    @chosen_collections = @collections.map { |c| c.name }
    if params[:collections]
      @chosen_collections = params[:collections].keys
    end
    problems = Problem.filter(@current_user, session[:filters].clone) #for some reason session[:filters] was being passed by reference? i have no clue why wtf
    @problems = problems.results
  end

  #eventually this will be an AJAX call. ALSO WE NEED TO CHANGE OUR HABTM ASSOCIATION TO HAS_MANY: THROUGH SO WE CAN USE VALIDATIONS AND STUFF
  # def add_to_collection
  #   collection = Collection.find(params[:collection_id])
  #   if not collection
  #     render :json => {:status => false}
  #     return
  #   end
  #   problem_to_add = Problem.find(params[:id])
  #   if not collection.problems.include? problem_to_add
  #     collection.problems << problem_to_add
  #     render :json => {:status => true}
  #   else 
  #     render :json => {:status => false}
  #   end
  # end

  def remove_from_collection
    collection = Collection.find(params[:collection_id])
    problem_to_remove = Problem.find(params[:id])
    if collection.problems.include? problem_to_remove
      collection.problems.delete(problem_to_remove)
      collection.save
      flash[:notice] = "problem successfully removed from #{collection.name}"
    else 
      flash[:notice] = "the problem you attempted to remove does not exist in #{collection.name}"
    end
    flash.keep
    redirect_to edit_collection_path(:id => collection.id)
  end

  def add_tag
    @problem = Problem.find(params[:id])
    @tag = @problem.tags.find_by_name(params[:tag])
    if !@tag
      @tag = Tag.create(name: params[:tag])
      @problem.tags << @tag
    end
    render :partial => "tags", locals: { tags: @problem.tags}
  end

  def remove_tag
    @problem = Problem.find(params[:id])
    @tag = Tag.find(params[:tid])
    @problem.tags.delete(@tag)
    render :partial => "tags", locals: { tags: @problem.tags}
  end
end
