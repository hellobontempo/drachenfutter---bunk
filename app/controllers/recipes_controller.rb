class RecipesController < ApplicationController
  
  def index
    @recipes = Recipe.order(:title)
    if params[:q]
        @recipes = @recipes.search_by_ingredient(params[:q])
    elsif params[:category]
      @recipes = @recipes.search_by_category(params[:category])
    end
  end

  def new
    redirect_if_not_logged_in
    @recipe = Recipe.new
    @recipe_ingredient = @recipe.recipe_ingredients.build 
    @ingredient = @recipe_ingredient.build_ingredient 
  end

  def create
    @recipe = Recipe.new(recipe_params)
    test = true
    @recipe.recipe_ingredients.each do |i|
      if i.ingredient_id.nil?
        test = false
        i.build_ingredient
      end
    end

    if params[:add_ingredient]
      if test
        @recipe_ingredient = @recipe.recipe_ingredients.build 
        @ingredient = @recipe_ingredient.build_ingredient
      end
    elsif params[:remove_ingredient]

    else
      @recipe.creator = current_user
      @recipe.titlecase_title
      if !@recipe.ingredients.present?
        render :new and return
      elsif @recipe.save
        flash[:notice] = "Successfully created recipe."
        redirect_to @recipe and return
      end
    end
    render :new
  end

  def show
    @recipe = Recipe.find(params[:id])
  end

  def edit
    @recipe = Recipe.find(params[:id])
    redirect_to recipe_path(@recipe) unless @recipe.creator ==  current_user
  end

  def update
    @recipe = Recipe.find(params[:id])
    test = true
    @recipe.recipe_ingredients.each do |i|
      if i.ingredient_id.nil?
        test = false
        i.build_ingredient
      end
    end
    if params[:add_ingredient]
      unless recipe_params[:recipe_ingredients_attributes].blank?
        for attribute in recipe_params[:recipe_ingredients_attributes]
          @recipe.recipe_ingredients.build(attribute.last.except(:_destroy)) unless attribute.last.has_key?(:recipe_ingredient_id)
        end
      end
      if test
        @recipe_ingredient = @recipe.recipe_ingredients.build 
        @ingredient = @recipe_ingredient.build_ingredient
      end
    else
      if recipe_params[:recipe_ingredients_attributes].values.collect{|v| v[:_destroy] == 1}.all?
        redirect_to edit_recipe_path(@recipe), alert: "Cannot delete all ingredients." and return
      elsif !recipe_params[:instructions].present? || !recipe_params[:title].present?
        redirect_to edit_recipe_path(@recipe), alert: "Required fields cannot be blank." and return
      else
        @recipe.update(recipe_params)
        flash[:alert] = "Successfully updated recipe."
        redirect_to @recipe and return
      end
    end
    render :edit
  end

  def destroy
    Recipe.find(params[:id]).destroy
    redirect_to recipes_path
  end

  private


  def recipe_params
    params.require(:recipe).permit(
      :title, 
      :source, 
      :instructions,
      :category,  
      :photo,
      ingredient_ids:[], 
      recipe_ingredients_attributes: [
        :id,
        :amount,
        :_destroy,
        ingredient_attributes: [
          :name, 
          :id
        ]
      ]
      )
  end


end
