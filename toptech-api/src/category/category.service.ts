import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/sequelize';
import { Category } from './category.model';

@Injectable()
export class CategoryService {
  constructor(
    @InjectModel(Category)
    private categoryModel: typeof Category,
  ) {}

  async findAll(): Promise<Category[]> {
    return this.categoryModel.findAll({ order: [['name', 'ASC']] });
  }

  async create(name: string): Promise<Category> {
    return this.categoryModel.create({ name } as any);
  }

  async delete(id: number): Promise<void> {
    const cat = await this.categoryModel.findByPk(id);
    if (cat) {
      await cat.destroy();
    }
  }

  async update(id: number, name: string): Promise<Category | null> {
    const cat = await this.categoryModel.findByPk(id);
    if (cat) {
      await cat.update({ name });
    }
    return cat;
  }
}
