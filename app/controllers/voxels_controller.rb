class VoxelsController < ApplicationController
  before_action :set_voxel, only: [:show, :edit, :update, :destroy]

  # GET /voxels
  # GET /voxels.json
  def index
    @voxels = Voxel.all
  end

  # GET /voxels/1
  # GET /voxels/1.json
  def show
  end

  # GET /voxels/new
  def new
    @voxel = Voxel.new
  end

  # GET /voxels/1/edit
  def edit
  end

  # POST /voxels
  # POST /voxels.json
  def create
    @voxel = Voxel.new(voxel_params)

    respond_to do |format|
      if @voxel.save
        flash[:notice] = '作成されました！'
        format.html { redirect_to action: 'index' }
        format.json { render action: 'show', status: :created, location: @voxel }
      else
        format.html { render action: 'new' }
        format.json { render json: @voxel.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /voxels/1
  # PATCH/PUT /voxels/1.json
  def update
    respond_to do |format|
      if @voxel.update(voxel_params)
        format.html { redirect_to @voxel, notice: '更新されました！' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @voxel.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /voxels/1
  # DELETE /voxels/1.json
  def destroy
    @voxel.destroy
    respond_to do |format|
      format.html { redirect_to voxels_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_voxel
      @voxel = Voxel.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def voxel_params
      params.require(:voxel).permit(:user_id, :title, :voxeljson)
    end
end
