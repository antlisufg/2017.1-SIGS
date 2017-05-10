class CreateJoinTableDaysSchedules < ActiveRecord::Migration[5.0]
  def change
    create_join_table :days, :schedules do |t|
      t.index [:day_id, :schedule_id]
      t.index [:schedule_id, :day_id]
    end
  end
end
