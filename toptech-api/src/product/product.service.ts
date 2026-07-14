import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Product } from './product.model';

@Injectable()
export class ProductService {
  constructor(
    @InjectModel(Product)
    private productModel: typeof Product,
  ) {}

  async findAll(): Promise<Product[]> {
    return this.productModel.findAll({ order: [['createdAt', 'DESC']] });
  }

  async create(data: Partial<Product>): Promise<Product> {
    return this.productModel.create(data as any);
  }

  async update(id: number, data: Partial<Product>): Promise<Product | null> {
    const prod = await this.productModel.findByPk(id);
    if (prod) {
      return prod.update(data as any);
    }
    return null;
  }

  async delete(id: number): Promise<void> {
    const prod = await this.productModel.findByPk(id);
    if (prod) {
      await prod.destroy();
    }
  }
}
