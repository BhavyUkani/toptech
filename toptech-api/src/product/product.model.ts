import { Column, Model, Table, DataType } from 'sequelize-typescript';

@Table({ tableName: 'products', timestamps: true })
export class Product extends Model<Product> {
  @Column({
    type: DataType.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  })
  declare id: number;

  @Column({
    type: DataType.STRING,
    allowNull: false,
  })
  name: string;

  @Column({
    type: DataType.STRING,
    allowNull: false,
    unique: "unique_product",
  })
  code: string;

  @Column({
    type: DataType.STRING,
    allowNull: false,
  })
  lsp: string;

  @Column({
    type: DataType.STRING,
    allowNull: false,
  })
  hsp: string;

  @Column({
    type: DataType.STRING,
    allowNull: false,
  })
  category: string;
}
