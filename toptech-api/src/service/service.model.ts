import { Table, Column, Model, DataType, HasMany } from 'sequelize-typescript';
import { Enquiry } from '../enquiry/enquiry.model';

@Table({
  tableName: 'services',
  timestamps: true,
})
export class Service extends Model<Service> {
  @Column({
    type: DataType.STRING,
    allowNull: false,
  })
  serviceName: string;

  @HasMany(() => Enquiry)
  enquiries: Enquiry[];
}
