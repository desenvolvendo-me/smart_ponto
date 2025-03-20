class TimeEntriesController < ApplicationController
  before_action :authenticate_user!

  def new
    @time_entry = current_user.time_entries.new
  end

  def create
    @time_entry = current_user.time_entries.new(time_entry_params)

    if @time_entry.save
      redirect_to time_sheets_path, notice: 'Ponto registrado com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def quick_register
    date = Date.today
    time = Time.current

    # Determinar tipo de entrada (entrada/saída)
    last_entry = current_user.time_entries.where(date: date).order(:time).last
    entry_type = last_entry && last_entry.entry_type == 'entrada' ? 'saída' : 'entrada'

    @time_entry = current_user.time_entries.new(
      date: date,
      time: time,
      entry_type: entry_type,
      status: 'registrado'
    )

    if @time_entry.save
      redirect_to time_sheets_path, notice: 'Ponto registrado com sucesso.'
    else
      redirect_to time_sheets_path, alert: 'Erro ao registrar ponto.'
    end
  end

  private

  def time_entry_params
    params.require(:time_entry).permit(:date, :time, :entry_type, :observation)
          .merge(status: 'registrado')
  end
end
