import { Table, Column, Model, DataType, Index } from 'sequelize-typescript';

@Table({ tableName: 'employees', timestamps: true })
export class Employee extends Model<Employee> {
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
  declare name: string;

  @Index({ name: 'username_unique_idx' })
  @Column({
    type: DataType.STRING,
    allowNull: false,
    unique: "username_unique",
  })
  declare username: string;

  @Index({ name: 'number_unique_idx' })
  @Column({
    type: DataType.STRING,
    allowNull: false,
  })
  declare number: string;

  @Index({ name: 'email_unique_idx' })
  @Column({
    type: DataType.STRING,
    allowNull: false,
  })
  declare email: string;

  @Column({
    type: DataType.STRING,
    allowNull: false,
  })
  declare password: string;

  @Column({
    type: DataType.STRING,
    allowNull: false,
    defaultValue: 'Employee',
  })
  declare role: string;

  @Column({
    type: DataType.STRING,
    allowNull: true,
  })
  declare onesignalPlayerId: string;
}
