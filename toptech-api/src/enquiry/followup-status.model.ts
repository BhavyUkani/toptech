import { Column, Model, Table, DataType } from 'sequelize-typescript';

@Table({ tableName: 'followup_statuses', timestamps: true })
export class FollowupStatus extends Model<FollowupStatus> {
  @Column({
    type: DataType.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  })
  declare id: number;

  @Column({
    type: DataType.STRING,
    allowNull: false,
    unique: "unique_status_name",
  })
  name: string;

  @Column({
    type: DataType.INTEGER,
    allowNull: false,
    defaultValue: 0,
  })
  displayOrder: number;
}
