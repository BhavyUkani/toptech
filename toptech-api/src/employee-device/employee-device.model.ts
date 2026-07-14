import {
  Table,
  Column,
  Model,
  DataType,
  ForeignKey,
  BelongsTo,
  Index,
} from 'sequelize-typescript';
import { Employee } from '../employee/employee.model';

@Table({ tableName: 'employee_devices', timestamps: true })
export class EmployeeDevice extends Model<EmployeeDevice> {
  @Column({
    type: DataType.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  })
  declare id: number;

  @ForeignKey(() => Employee)
  @Column({ type: DataType.INTEGER, allowNull: false })
  declare employeeId: number;

  @BelongsTo(() => Employee)
  employee: Employee;

  @Index({ name: 'unique_player_id', unique: true })
  @Column({ type: DataType.STRING(512), allowNull: false })
  declare onesignalPlayerId: string;
}
