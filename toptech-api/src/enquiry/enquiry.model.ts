import { Table, Column, Model, DataType, ForeignKey, BelongsTo } from 'sequelize-typescript';
import { Employee } from '../employee/employee.model';
import { Service } from '../service/service.model';

@Table({ tableName: 'enquiries', timestamps: true })
export class Enquiry extends Model<Enquiry> {
  @ForeignKey(() => Service)
  @Column({
    type: DataType.INTEGER,
    allowNull: true,
  })
  declare serviceId: number;

  @BelongsTo(() => Service)
  service: Service;
  @Column({
    type: DataType.INTEGER,
    primaryKey: true,
    autoIncrement: true,
  })
  declare id: number;

  @Column({
    type: DataType.STRING,
    allowNull: false,
  })
  declare client: string;

  @Column({
    type: DataType.STRING,
    allowNull: false,
  })
  declare number: string;

  @Column({
    type: DataType.STRING,
    allowNull: false,
  })
  declare product: string;



  @Column({
    type: DataType.STRING,
    allowNull: false,
    defaultValue: 'New',
  })
  declare status: string;

  @Column({
    type: DataType.STRING,
    allowNull: true,
  })
  declare date: string;

  @Column({
    type: DataType.TEXT,
    allowNull: true,
    defaultValue: '[]',
  })
  declare followups: string;

  @Column({
    type: DataType.STRING,
    allowNull: true,
  })
  declare reminderDate: string;



  @ForeignKey(() => Employee)
  @Column({
    type: DataType.INTEGER,
    allowNull: true,
  })
  declare assignedToId: number;

  @BelongsTo(() => Employee, 'assignedToId')
  assignedEmployee: Employee;

  @ForeignKey(() => Employee)
  @Column({
    type: DataType.INTEGER,
    allowNull: true,
  })
  declare assignedById: number;

  @BelongsTo(() => Employee, 'assignedById')
  creatorEmployee: Employee;

  @Column({
    type: DataType.TEXT,
    allowNull: true,
  })
  declare notes: string;
}
